package com.monkmarket.agentservice.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.monkmarket.agentservice.client.CommerceClient;
import com.monkmarket.agentservice.dto.*;
import com.monkmarket.agentservice.model.ChatMessage;
import com.monkmarket.agentservice.model.ChatSession;
import com.monkmarket.agentservice.model.CheckoutState;
import com.monkmarket.agentservice.model.MessageRole;
import com.monkmarket.agentservice.repository.ChatMessageRepository;
import com.monkmarket.agentservice.repository.ChatSessionRepository;
import com.monkmarket.agentservice.tool.AgentTools;
import lombok.RequiredArgsConstructor;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AgentService {

    private final ChatClient chatClient;
    private final AgentTurnContext turnContext;

    private final AgentTools agentTools;
    private final CommerceClient commerceClient;
    private final AgentAuditService agentAuditService;


    private final ChatSessionRepository chatSessionRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final ResourceLoader resourceLoader;

    private final ObjectMapper objectMapper;

    @Transactional
    public AgentChatResponse chat(
            UUID userId,
            AgentChatRequest request
    ) {

        UUID requestId = UUID.randomUUID();

        turnContext.setRequestId(requestId);



        long start =
                System.nanoTime();

        try {

            AgentChatResponse response =
                    chatInternal(
                            userId,
                            request
                    );

            long latencyMs =
                    (System.nanoTime() - start)
                            / 1_000_000;

            agentAuditService.recordSuccess(
                    requestId,
                    userId,
                    response.sessionId(),
                    request.message(),
                    response,
                    latencyMs
            );

            return response;

        } catch (Exception e) {

            long latencyMs =
                    (System.nanoTime() - start)
                            / 1_000_000;

            UUID sessionId = null;

            try {
                if (request.sessionId() != null
                        && !request.sessionId().isBlank()) {

                    sessionId =
                            UUID.fromString(
                                    request.sessionId()
                            );
                }
            } catch (Exception ignored) {
            }

            agentAuditService.recordFailure(
                    requestId,
                    userId,
                    sessionId,
                    request.message(),
                    e,
                    latencyMs
            );

            throw e;
        }
    }

    public AgentChatResponse chatInternal(
            UUID userId,
            AgentChatRequest request
    ) {

        ChatSession session =
                getOrCreateSession(
                        userId,
                        request.sessionId()
                );

        turnContext.setUserId(userId);
        turnContext.setSessionId(session.getId());

        turnContext.clearProducts();
        turnContext.clearRecommendations();
        turnContext.clearCart();
        turnContext.clearCheckout();

        saveUserMessage(
                session.getId(),
                request.message()
        );

        if (session.getCheckoutState()
                == CheckoutState.CONFIRMATION_REQUIRED) {

            ConfirmationDecision decision =
                    classifyConfirmation(
                            request.message(),
                            session
                    );

            System.out.println(
                    "CHECKOUT DECISION => confirmed="
                            + decision.confirmed()
                            + ", rejected="
                            + decision.rejected()
            );

            if (decision.confirmed()) {

                CommerceClient.CommerceOrderResponse order =
                        commerceClient.createOrder(
                                userId,
                                session.getPendingCheckoutCartId(),
                                session.getPendingCheckoutIdempotencyKey(),
                                true
                        );

                UUID orderId = order.id();

                PaymentOrderResponse payment =
                        commerceClient.createPaymentOrder(
                                userId,
                                orderId
                        );

                session.setCheckoutState(
                        CheckoutState.PAYMENT_REQUIRED
                );

                session.setCheckoutOrderId(
                        payment.orderId()
                );

                session.setCheckoutPaymentId(
                        payment.paymentId()
                );

                session.setCheckoutRazorpayOrderId(
                        payment.razorpayOrderId()
                );

                session.setCheckoutAmountInPaise(
                        payment.amountInPaise()
                );

                session.setCheckoutCurrency(
                        payment.currency()
                );

                session.setCheckoutPaymentStatus(
                        payment.status()
                );

                session.setPendingCheckoutCartId(
                        null
                );

                session.setPendingCheckoutIdempotencyKey(
                        null
                );

                session.setUpdatedAt(
                        LocalDateTime.now()
                );

                chatSessionRepository.save(
                        session
                );

                String response =
                        "Your order is ready for payment.\n\n"
                                + "Order ID: "
                                + orderId
                                + "\nAmount: ₹"
                                + (payment.amountInPaise() / 100.0)
                                + "\nPayment Status: "
                                + payment.status()
                                + "\nPlease complete payment within 15 minutes.";

                saveAssistantMessage(
                        session.getId(),
                        response
                );

                return paymentRequiredResponse(
                        session,
                        response,
                        payment
                );
            }

            if (decision.rejected()) {

                session.setCheckoutState(
                        CheckoutState.NONE
                );

                session.setPendingCheckoutCartId(
                        null
                );

                session.setPendingCheckoutIdempotencyKey(
                        null
                );

                session.setCheckoutOrderId(
                        null
                );

                session.setCheckoutPaymentId(
                        null
                );

                session.setCheckoutRazorpayOrderId(
                        null
                );

                session.setCheckoutAmountInPaise(
                        null
                );

                session.setCheckoutCurrency(
                        null
                );

                session.setCheckoutPaymentStatus(
                        null
                );

                session.setUpdatedAt(
                        LocalDateTime.now()
                );

                chatSessionRepository.save(
                        session
                );

                String response =
                        "Checkout cancelled.";

                saveAssistantMessage(
                        session.getId(),
                        response
                );

                return normalResponse(
                        session,
                        response
                );
            }

            String response =
                    "Please confirm the checkout clearly. "
                            + "You can say yes to proceed or no to cancel.";

            saveAssistantMessage(
                    session.getId(),
                    response
            );

            session.setUpdatedAt(
                    LocalDateTime.now()
            );

            chatSessionRepository.save(
                    session
            );

            CartResponse cart =
                    commerceClient.getCart(
                            userId
                    );

            return confirmationResponse(
                    session,
                    response,
                    CartDtoMapper.from(cart)
            );
        }

        List<ChatMessage> history =
                chatMessageRepository
                        .findTop20BySessionIdOrderByCreatedAtDesc(
                                session.getId()
                        );

        java.util.Collections.reverse(history);

        List<Message> messages =
                new ArrayList<>();

        for (ChatMessage message : history) {
            if (message.getRole() == MessageRole.USER) {
                messages.add(
                        new UserMessage(
                                message.getContent()
                        )
                );
            } else if (message.getRole() == MessageRole.ASSISTANT) {
                messages.add(
                        new AssistantMessage(
                                message.getContent()
                        )
                );
            } else if (message.getRole() == MessageRole.TOOL) {
                messages.add(
                        new SystemMessage(
                                "Previous tool result from "
                                        + message.getToolName()
                                        + ":\n"
                                        + message.getToolOutput()
                        )
                );
            }
        }
        String memoryContext = buildMemoryContext(session);

        String systemPrompt = loadSystemPrompt();

        String fullSystemPrompt =
                systemPrompt
                        + "\n\n==============================\n"
                        + "CURRENT SESSION MEMORY\n"
                        + "==============================\n\n"
                        + memoryContext;

        String response =
                chatClient
                        .prompt()
                        .system(fullSystemPrompt)
                        .messages(messages)
                        .tools(agentTools)
                        .toolContext(
                                Map.of(
                                        "userId",
                                        userId.toString(),
                                        "sessionId",
                                        session.getId().toString()
                                )
                        )
                        .call()
                        .content();

        saveAssistantMessage(
                session.getId(),
                response
        );

        session.setUpdatedAt(
                LocalDateTime.now()
        );

        chatSessionRepository.save(
                session
        );

        if (turnContext.getCheckout() != null) {

            CheckoutResponseState checkout =
                    turnContext.getCheckout();

            if (checkout.confirmationRequired()) {

                CartResponse cart =
                        commerceClient.getCart(
                                userId
                        );

                return confirmationResponse(
                        session,
                        checkout.message(),
                        CartDtoMapper.from(cart)
                );
            }

            if (session.getCheckoutState()
                    == CheckoutState.PAYMENT_REQUIRED
                    && session.getCheckoutOrderId() != null) {

                CheckoutDto paymentCheckout =
                        new CheckoutDto(
                                session.getCheckoutOrderId(),
                                session.getCheckoutPaymentId(),
                                session.getCheckoutRazorpayOrderId(),
                                session.getCheckoutAmountInPaise(),
                                session.getCheckoutCurrency(),
                                session.getCheckoutPaymentStatus(),
                                null
                        );

                return new AgentChatResponse(
                        session.getId(),
                        ResponseType.PAYMENT_REQUIRED,
                        response,
                        turnContext.getProducts(),
                        turnContext.getRecommendations(),
                        turnContext.getCart(),
                        paymentCheckout,
                        null,
                        List.of(),
                        List.of(
                                new ActionDto(
                                        ActionType.PROCEED_TO_PAYMENT,
                                        "Proceed to Payment",
                                        new ActionPayload(
                                                null,
                                                session.getCheckoutOrderId()
                                        )
                                )
                        ),
                        defaultMeta()
                );
            }
        }

        return normalResponse(
                session,
                response
        );
    }

    private String loadSystemPrompt() {

        try {
            Resource resource = resourceLoader.getResource(
                    "classpath:prompts/system-prompt.st"
            );

            return resource.getContentAsString(
                    java.nio.charset.StandardCharsets.UTF_8
            );

        } catch (Exception e) {
            throw new IllegalStateException(
                    "Failed to load system prompt",
                    e
            );
        }
    }

    private String buildMemoryContext(ChatSession session) {

        String lastReferencedProduct =
                session.getLastReferencedProductId() == null
                        ? "NONE"
                        : session.getLastReferencedProductId().toString();

        String lastSearchResults =
                session.getLastSearchResultsJson();

        if (lastSearchResults == null || lastSearchResults.isBlank()) {
            lastSearchResults = "NONE";
        }

        return """
            PERSISTENT CONVERSATION STATE
            =============================

            Session ID:
            %s

            User ID:
            %s

            Last referenced product ID:
            %s

            Last catalog search results:
            %s

            REFERENCE RESOLUTION RULES
            ==========================

            When the user refers to:
            - "it"
            - "that"
            - "that one"
            - "this"
            - "this one"
            - "the one"
            - "same one"

            use the last referenced product only when it is an
            unambiguous reference.

            When the user says:
            - "first one"
            - "second one"
            - "third one"
            - etc.

            resolve the reference against the last catalog search
            results.

            Never invent a product ID.

            If the reference is ambiguous, ask the user to clarify.
            Do not guess.

            The persistent application state is authoritative for
            product identity. Conversation text may explain context,
            but must not override actual backend state.
            """.formatted(
                session.getId(),
                session.getUserId(),
                lastReferencedProduct,
                lastSearchResults
        );
    }

    private AgentChatResponse confirmationResponse(
            ChatSession session,
            String response,
            CartDto cart
    ) {

        long amount =
                cart == null
                        || cart.totalInPaise() == null
                        ? 0L
                        : cart.totalInPaise();

        CheckoutDto checkout =
                new CheckoutDto(
                        null,
                        null,
                        null,
                        amount,
                        cart == null
                                ? "INR"
                                : cart.currency(),
                        null,
                        null
                );

        return new AgentChatResponse(
                session.getId(),
                ResponseType.CHECKOUT_CONFIRMATION_REQUIRED,
                response,
                List.of(),
                List.of(),
                cart,
                checkout,
                null,
                List.of(),
                List.of(
                        new ActionDto(
                                ActionType.CONFIRM_CHECKOUT,
                                "Yes, place order",
                                new ActionPayload(
                                        null,
                                        null
                                )
                        ),
                        new ActionDto(
                                ActionType.REJECT_CHECKOUT,
                                "Cancel",
                                new ActionPayload(
                                        null,
                                        null
                                )
                        )
                ),
                new MetaDto(
                        LocalDateTime.now(),
                        true,
                        new GuardrailMeta(
                                GuardrailCode.HUMAN_CONFIRM_REQUIRED,
                                response
                        ),
                        null
                )
        );
    }

    private AgentChatResponse paymentRequiredResponse(
            ChatSession session,
            String response,
            PaymentOrderResponse payment
    ) {

        CheckoutDto checkout =
                new CheckoutDto(
                        payment.orderId(),
                        payment.paymentId(),
                        payment.razorpayOrderId(),
                        payment.amountInPaise(),
                        payment.currency(),
                        payment.status(),
                        null
                );

        return new AgentChatResponse(
                session.getId(),
                ResponseType.PAYMENT_REQUIRED,
                response,
                List.of(),
                List.of(),
                null,
                checkout,
                null,
                List.of(),
                List.of(
                        new ActionDto(
                                ActionType.PROCEED_TO_PAYMENT,
                                "Proceed to Payment",
                                new ActionPayload(
                                        null,
                                        payment.orderId()
                                )
                        )
                ),
                defaultMeta()
        );
    }

    private ResponseType determineResponseType() {

        if (turnContext.getCart() != null) {

            return ResponseType.CART_UPDATED;
        }

        if (!turnContext.getProducts().isEmpty()) {

            return ResponseType.PRODUCT_RESULTS;
        }

        return ResponseType.NORMAL;
    }

    private AgentChatResponse normalResponse(
            ChatSession session,
            String response
    ) {

        ResponseType type =
                determineResponseType();

        return new AgentChatResponse(
                session.getId(),
                type,
                response,
                turnContext.getProducts(),
                turnContext.getRecommendations(),
                turnContext.getCart(),
                null,
                null,
                List.of(),
                buildActions(type),
                defaultMeta()
        );
    }

    private List<ActionDto> buildActions(
            ResponseType type
    ) {

        List<ActionDto> actions =
                new ArrayList<>();

        for (ProductDto product :
                turnContext.getProducts()) {

            if (product == null) {
                continue;
            }

            actions.add(
                    new ActionDto(
                            ActionType.VIEW_PRODUCT,
                            "View",
                            new ActionPayload(
                                    product.id(),
                                    null
                            )
                    )
            );

            actions.add(
                    new ActionDto(
                            ActionType.ADD_TO_CART,
                            "Add",
                            new ActionPayload(
                                    product.id(),
                                    null
                            )
                    )
            );
        }

        for (ProductRecommendationDto recommendation :
                turnContext.getRecommendations()) {

            if (recommendation == null
                    || recommendation.product() == null) {

                continue;
            }

            ProductDto product =
                    recommendation.product();

            actions.add(
                    new ActionDto(
                            ActionType.VIEW_PRODUCT,
                            "View",
                            new ActionPayload(
                                    product.id(),
                                    null
                            )
                    )
            );

            actions.add(
                    new ActionDto(
                            ActionType.ADD_TO_CART,
                            "Add",
                            new ActionPayload(
                                    product.id(),
                                    null
                            )
                    )
            );
        }

        if (type == ResponseType.PAYMENT_REQUIRED) {

            actions.add(
                    new ActionDto(
                            ActionType.PROCEED_TO_PAYMENT,
                            "Proceed to Payment",
                            new ActionPayload(
                                    null,
                                    null
                            )
                    )
            );
        }

        return actions;
    }

    private MetaDto defaultMeta() {

        return new MetaDto(
                LocalDateTime.now(),
                false,
                null,
                null
        );
    }

    private ConfirmationDecision classifyConfirmation(
            String message,
            ChatSession session
    ) {

        try {

            List<ChatMessage> history =
                    chatMessageRepository
                            .findTop20BySessionIdOrderByCreatedAtDesc(
                                    session.getId()
                            );

            String previousAssistantMessage = "";

            for (ChatMessage chatMessage : history) {

                if (chatMessage.getRole()
                        == MessageRole.ASSISTANT) {

                    previousAssistantMessage =
                            chatMessage.getContent();

                    break;
                }
            }

            String input = """
                CHECKOUT CONFIRMATION DECISION

                CHECKOUT STATE:
                %s

                CART:
                %s

                AMOUNT:
                %s

                CURRENCY:
                %s

                PREVIOUS ASSISTANT MESSAGE:
                %s

                CURRENT USER MESSAGE:
                %s
                """.formatted(
                    session.getCheckoutState(),
                    session.getPendingCheckoutCartId(),
                    session.getCheckoutAmountInPaise(),
                    session.getCheckoutCurrency(),
                    previousAssistantMessage,
                    message == null ? "" : message
            );

            String rawResponse =
                    chatClient
                            .prompt()
                            .system("""
                                You are a strict intent classifier.

                                The application is waiting for the user
                                to decide whether a pending checkout
                                should continue.

                                Analyze the CURRENT USER MESSAGE together
                                with the PREVIOUS ASSISTANT MESSAGE.

                                Return EXACTLY ONE of these values:

                                CONFIRMED
                                REJECTED
                                AMBIGUOUS

                                CONFIRMED:
                                The user intends to proceed with the
                                pending checkout.

                                REJECTED:
                                The user intends to cancel the
                                pending checkout.

                                AMBIGUOUS:
                                The user's intent cannot be determined.

                                Interpret the current message
                                conversationally.

                                Do not execute anything.
                                Do not explain anything.
                                Do not return JSON.
                                Do not return markdown.
                                Return exactly one word:
                                CONFIRMED
                                REJECTED
                                or
                                AMBIGUOUS
                                """)
                            .user(input)
                            .call()
                            .content();

            System.out.println(
                    "CHECKOUT CLASSIFIER INPUT:"
                            + "\n"
                            + input
            );

            System.out.println(
                    "CHECKOUT CLASSIFIER RESPONSE: "
                            + rawResponse
            );

            if (rawResponse == null
                    || rawResponse.isBlank()) {

                return new ConfirmationDecision(
                        false,
                        false
                );
            }

            String decision =
                    rawResponse
                            .trim()
                            .toUpperCase(
                                    java.util.Locale.ROOT
                            );

            if (decision.contains("CONFIRMED")) {

                return new ConfirmationDecision(
                        true,
                        false
                );
            }

            if (decision.contains("REJECTED")) {

                return new ConfirmationDecision(
                        false,
                        true
                );
            }

            return new ConfirmationDecision(
                    false,
                    false
            );

        } catch (Exception e) {

            System.err.println(
                    "CHECKOUT CLASSIFICATION ERROR: "
                            + e.getClass().getName()
                            + " - "
                            + e.getMessage()
            );

            e.printStackTrace();

            return new ConfirmationDecision(
                    false,
                    false
            );
        }
    }
    private UUID extractOrderId(
            String orderJson
    ) {

        try {

            JsonNode json =
                    objectMapper.readTree(
                            orderJson
                    );

            JsonNode idNode =
                    json.get("id");

            if (idNode == null
                    || idNode.isNull()) {

                throw new IllegalStateException(
                        "Order response does not contain id"
                );
            }

            return UUID.fromString(
                    idNode.asText()
            );

        } catch (Exception e) {

            throw new IllegalStateException(
                    "Could not parse created order",
                    e
            );
        }
    }

    private void saveUserMessage(
            UUID sessionId,
            String content
    ) {

        ChatMessage message =
                ChatMessage.builder()
                        .sessionId(sessionId)
                        .requestId(turnContext.getRequestId())
                        .role(MessageRole.USER)
                        .content(content)
                        .createdAt(LocalDateTime.now())
                        .build();

        chatMessageRepository.save(
                message
        );
    }

    private void saveAssistantMessage(
            UUID sessionId,
            String content
    ) {

        ChatMessage message =
                ChatMessage.builder()
                        .sessionId(sessionId)
                        .requestId(turnContext.getRequestId())
                        .role(MessageRole.ASSISTANT)
                        .content(content)
                        .createdAt(LocalDateTime.now())
                        .build();

        chatMessageRepository.save(
                message
        );
    }

    private ChatSession getOrCreateSession(
            UUID userId,
            String sessionId
    ) {

        if (sessionId != null && !sessionId.isBlank()) {

            try {
                UUID id = UUID.fromString(sessionId);

                return chatSessionRepository
                        .findByIdAndUserId(id, userId)
                        .orElseGet(() -> createNewSession(userId));

            } catch (IllegalArgumentException e) {
                return createNewSession(userId);
            }
        }

        return createNewSession(userId);
    }

    private ChatSession createNewSession(UUID userId) {

        LocalDateTime now = LocalDateTime.now();

        ChatSession session = ChatSession.builder()
                .userId(userId)
                .createdAt(now)
                .updatedAt(now)
                .checkoutState(CheckoutState.NONE)
                .build();

        return chatSessionRepository.save(session);
    }

    @Transactional(readOnly = true)
    public List<ChatSessionResponse> getMySessions(
            UUID userId
    ) {

        return chatSessionRepository
                .findByUserIdOrderByUpdatedAtDesc(
                        userId
                )
                .stream()
                .map(
                        session ->
                                new ChatSessionResponse(
                                        session.getId(),
                                        session.getUserId(),
                                        session.getCreatedAt()
                                )
                )
                .toList();
    }

    @Transactional(readOnly = true)
    public ChatSessionResponse getSession(
            UUID userId,
            UUID sessionId
    ) {

        ChatSession session =
                chatSessionRepository
                        .findByIdAndUserId(
                                sessionId,
                                userId
                        )
                        .orElseThrow(
                                () -> new IllegalArgumentException(
                                        "Chat session not found"
                                )
                        );

        return new ChatSessionResponse(
                session.getId(),
                session.getUserId(),
                session.getCreatedAt()
        );
    }


}