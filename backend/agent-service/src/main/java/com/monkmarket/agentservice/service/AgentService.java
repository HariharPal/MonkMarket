package com.monkmarket.agentservice.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.monkmarket.agentservice.client.CartClient;
import com.monkmarket.agentservice.client.OrderClient;
import com.monkmarket.agentservice.client.PaymentClient;
import com.monkmarket.agentservice.dto.*;
import com.monkmarket.agentservice.model.ChatMessage;
import com.monkmarket.agentservice.model.ChatSession;
import com.monkmarket.agentservice.model.CheckoutState;
import com.monkmarket.agentservice.model.MessageRole;
import com.monkmarket.agentservice.repository.ChatMessageRepository;
import com.monkmarket.agentservice.repository.ChatSessionRepository;
import com.monkmarket.agentservice.tool.AgentTools;
import com.monkmarket.agentservice.tool.OrderTools;
import lombok.RequiredArgsConstructor;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.Message;
import org.springframework.ai.chat.messages.UserMessage;
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
    private final OrderClient orderClient;
    private final CartClient cartClient;
    private final PaymentClient paymentClient;
    private final OrderTools orderTools;

    private final ChatSessionRepository chatSessionRepository;
    private final ChatMessageRepository chatMessageRepository;

    private final ObjectMapper objectMapper;

    @Transactional
    public AgentChatResponse chat(
            UUID userId,
            AgentChatRequest request
    ) {

        ChatSession session =
                getOrCreateSession(
                        userId,
                        request.sessionId()
                );

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
                            request.message()
                    );

            if (decision.confirmed()) {

                String orderJson =
                        orderClient.createOrder(
                                userId,
                                session.getPendingCheckoutCartId(),
                                session.getPendingCheckoutIdempotencyKey(),
                                true
                        );

                UUID orderId =
                        extractOrderId(
                                orderJson
                        );

                PaymentOrderResponse payment =
                        paymentClient.createPaymentOrder(
                                userId,
                                orderId
                        );

                session.setCheckoutState(
                        CheckoutState.COMPLETED
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
                    cartClient.getCart(
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
                        .findBySessionIdOrderByCreatedAtAsc(
                                session.getId()
                        );

        List<Message> messages =
                new ArrayList<>();

        for (ChatMessage message : history) {

            if (message.getRole()
                    == MessageRole.USER) {

                messages.add(
                        new UserMessage(
                                message.getContent()
                        )
                );

            } else {

                messages.add(
                        new AssistantMessage(
                                message.getContent()
                        )
                );
            }
        }

        String response =
                chatClient
                        .prompt()
                        .system("""
                                You are Sahayak, an AI shopping assistant for MonkMarket.

                                ========================================
                                CORE BEHAVIOR
                                ========================================

                                - Use tools whenever real application data is required.
                                - Never invent database values.
                                - Never claim an action succeeded unless the corresponding
                                  tool actually succeeded.
                                - Be concise and clear.
                                - Never expose internal implementation details, tool names,
                                  backend errors, JWTs, API keys, or secrets.

                                ========================================
                                PRODUCT RULES
                                ========================================

                                - Use searchCatalog whenever the user asks about products.
                                - searchCatalog accepts natural-language product intent.
                                - Never invent product names, prices, stock, categories,
                                  or product IDs.
                                - Only recommend products returned by searchCatalog.
                                - Never invent a category.
                                - The catalog service resolves semantic intent against
                                  real merchant categories.
                                - For broad requests, pass the user's natural-language
                                  intent directly to searchCatalog.
                                - If searchCatalog returns no products, do not fabricate
                                  alternatives.

                                ========================================
                                CART RULES
                                ========================================

                                - Use getCart when the user asks about their cart.
                                - Use addToCart only when explicitly asked.
                                - Use removeFromCart only when explicitly asked.
                                - Use updateCartQuantity when the user asks to change quantity.
                                - Use clearCart when explicitly asked to empty the cart.
                                - Never invent product IDs.
                                - Quantity must be greater than zero.
                                - Never automatically add complementary recommendations.
                                - When the user says "add it", "add that", "add the first one",
                                  or similar, resolve the reference against actual products
                                  returned by searchCatalog or actual cart contents.
                                - Never create an ID from a product name.

                                ========================================
                                RECOMMENDATION RULES
                                ========================================
                                - After a successful addToCart, you may call
                                  getComplementaryProducts.
                                - Recommendations must be genuinely complementary
                                  to the PRODUCT THAT WAS ACTUALLY ADDED.
                                - Never recommend random catalog products.
                                - Never automatically add recommendations.
                                - The user must explicitly request adding a recommendation.

                                ========================================
                                MULTI-INTENT REQUESTS
                                ========================================

                                When the user performs multiple actions in one message,
                                complete each valid action.

                                Example:

                                "Add the shoes and show me earbuds"

                                means:

                                1. Add the referenced shoe.
                                2. Search the catalog for earbuds.
                                3. Return the cart update.
                                4. Return the earbuds search results.
                                5. Return relevant recommendations for the added shoe.

                                Do not replace specific product search results with an
                                entire category.

                                ========================================
                                CHECKOUT RULES
                                ========================================

                                - Use proposeCheckout when the user explicitly asks to:
                                  checkout, buy, purchase, place an order,
                                  or proceed to payment.
                                - proposeCheckout performs backend guardrails.
                                - If confirmation is required, do not create an order.
                                - Wait for the user's confirmation.
                                - If checkout is allowed, order and payment creation
                                  happen in the backend.
                                - Creating a payment session does NOT mean payment
                                  has been completed.
                                - Never claim payment success without backend confirmation.

                                ========================================
                                PAYMENT RULES
                                ========================================

                                - CREATED = payment pending.
                                - VERIFIED = payment signature verified.
                                - PAID = backend confirms payment captured.
                                - FAILED = payment failed.
                                - EXPIRED = payment session expired.
                                - Never invent payment IDs or status.
                                - Never bypass payment verification.

                                ========================================
                                ORDER RULES
                                ========================================

                                - Use getMyOrders for order history.
                                - Use getOrder for a specific order.
                                - Never invent order IDs.
                                - Never claim an order is PAID unless backend confirms it.
                                - Never claim an expired order is active.

                                ========================================
                                CONVERSATION RULES
                                ========================================

                                - Use conversation history to understand:
                                  "that one",
                                  "the first one",
                                  "add it",
                                  "remove that",
                                  "make it 3",
                                  "the order I just placed".

                                - Resolve references using actual tool results.
                                - When ambiguous, ask for clarification.
                                - Never reuse an expired payment session.

                                ========================================
                                SAFETY
                                ========================================

                                - Deterministic backend guardrails are authoritative.
                                - Never override merchant policies.
                                - Never bypass confirmation requirements.
                                - Never authorize payment manually.
                                - Never fabricate backend actions.

                                ========================================
                                RESPONSE RULES
                                ========================================

                                - response is for the user.
                                - Structured response fields are handled by the application.
                                - Clearly distinguish product discovery, cart changes,
                                  checkout, payment pending, and payment completion.
                                """)
                        .messages(messages)
                        .tools(
                                agentTools,
                                orderTools
                        )
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
                        cartClient.getCart(
                                userId
                        );

                return confirmationResponse(
                        session,
                        checkout.message(),
                        CartDtoMapper.from(cart)
                );
            }

            if (session.getCheckoutState()
                    == CheckoutState.COMPLETED
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
            String message
    ) {

        return chatClient
                .prompt()
                .system("""
                        You classify whether a user confirms or rejects
                        a pending checkout.

                        Return ONLY JSON:

                        {
                          "confirmed": true,
                          "rejected": false
                        }

                        CONFIRMED means the user clearly wants the
                        pending checkout to proceed.

                        Examples:
                        "yes"
                        "yes please"
                        "yes I want to order it"
                        "go ahead"
                        "go ahead with it"
                        "proceed"
                        "place the order"
                        "buy it"
                        "do it"
                        "I want it"

                        REJECTED means the user clearly wants to cancel.

                        Examples:
                        "no"
                        "cancel"
                        "cancel it"
                        "don't buy it"
                        "do not proceed"
                        "stop"

                        Ambiguous examples:
                        "maybe"
                        "wait"
                        "what happens next?"
                        "how much is it?"
                        "I'm thinking about it"

                        For ambiguous messages:

                        {
                          "confirmed": false,
                          "rejected": false
                        }

                        Never set both to true.
                        """)
                .user(message)
                .call()
                .entity(
                        ConfirmationDecision.class
                );
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

        if (sessionId != null
                && !sessionId.isBlank()) {

            UUID id =
                    UUID.fromString(
                            sessionId
                    );

            return chatSessionRepository
                    .findByIdAndUserId(
                            id,
                            userId
                    )
                    .orElseThrow(
                            () -> new IllegalArgumentException(
                                    "Chat session not found"
                            )
                    );
        }

        LocalDateTime now =
                LocalDateTime.now();

        ChatSession session =
                ChatSession.builder()
                        .userId(userId)
                        .createdAt(now)
                        .updatedAt(now)
                        .checkoutState(
                                CheckoutState.NONE
                        )
                        .build();

        return chatSessionRepository.save(
                session
        );
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