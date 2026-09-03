package com.monkmarket.agentservice.tool;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.monkmarket.agentservice.client.CommerceClient;
import com.monkmarket.agentservice.dto.*;
import com.monkmarket.agentservice.guardrail.GuardrailDecision;
import com.monkmarket.agentservice.guardrail.GuardrailResult;
import com.monkmarket.agentservice.guardrail.GuardrailService;
import com.monkmarket.agentservice.model.ChatSession;
import com.monkmarket.agentservice.model.CheckoutState;
import com.monkmarket.agentservice.repository.ChatSessionRepository;
import com.monkmarket.agentservice.service.AgentTurnContext;
import com.monkmarket.agentservice.service.CheckoutResponseState;
import lombok.RequiredArgsConstructor;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.model.ToolContext;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class AgentTools {

    private final CommerceClient commerceClient;
    private final GuardrailService guardrailService;
    private final ChatClient chatClient;
    private final ChatSessionRepository chatSessionRepository;
    private final ObjectMapper objectMapper;
    private final AgentTurnContext turnContext;

    @Tool(
            name = "searchCatalog",
            description = """
        Search the real merchant catalog for products matching
        the user's meaning.

        Interpret natural language semantically, not literally.

        Examples:
        - "something I can wear on my wrist"
          -> watches, smart watches, fitness watches,
             fitness trackers

        - "cloth" or "something to wear"
          -> clothing, shirts, t-shirts, apparel

        - "something for my feet"
          -> shoes, sneakers, footwear

        - "something to carry water"
          -> bottles or flasks

        - "something that tracks heart rate"
          -> smart watches or fitness trackers

        Search the real catalog before saying nothing exists.

        Return only real products from the catalog.

        Never invent product names, prices, stock,
        categories, or IDs.

        Return the most relevant products first.
        """
    )
    public List<ProductSummary> searchCatalog(
            @ToolParam(description = "Natural-language product request")
            String query,

            @ToolParam(
                    description = "Optional maximum price in Indian paise",
                    required = false
            )
            Long maxPricePaise,

            ToolContext toolContext
    ) {

        UUID sessionId = getSessionId(toolContext);

        List<String> availableCategories =
                commerceClient.getAvailableCategories();

        if (availableCategories.isEmpty()) {

            turnContext.setProducts(List.of());

            return List.of();
        }

        CatalogSearchIntent intent =
                resolveCatalogIntent(
                        query,
                        availableCategories
                );

        List<ProductSummary> results =
                new ArrayList<>();

        if (intent.categories() == null
                || intent.categories().isEmpty()) {

            List<String> searchTerms =
                    intent.searchTerms() == null
                            || intent.searchTerms().isEmpty()

                            ? List.of(intent.searchQuery())

                            : intent.searchTerms();

            Set<UUID> seen =
                    new LinkedHashSet<>();

            for (String term : searchTerms) {

                if (term == null || term.isBlank()) {
                    continue;
                }

                List<ProductSummary> found =
                        commerceClient.search(
                                term,
                                null,
                                maxPricePaise
                        );

                for (ProductSummary product : found) {

                    if (product != null
                            && seen.add(product.id())) {

                        results.add(product);
                    }
                }
            }

        } else if (intent.categoryOnly()) {

            Set<UUID> seen =
                    new LinkedHashSet<>();

            for (String category : intent.categories()) {

                if (category == null || category.isBlank()) {
                    continue;
                }

                List<ProductSummary> found =
                        commerceClient.search(
                                "",
                                category,
                                maxPricePaise
                        );

                for (ProductSummary product : found) {

                    if (product != null
                            && seen.add(product.id())) {

                        results.add(product);
                    }
                }
            }

        } else {

            Set<UUID> seen =
                    new LinkedHashSet<>();

            List<String> searchTerms =
                    intent.searchTerms() == null
                            || intent.searchTerms().isEmpty()

                            ? List.of(intent.searchQuery())

                            : intent.searchTerms();

            for (String category : intent.categories()) {

                if (category == null || category.isBlank()) {
                    continue;
                }

                for (String term : searchTerms) {

                    if (term == null || term.isBlank()) {
                        continue;
                    }

                    List<ProductSummary> found =
                            commerceClient.search(
                                    term,
                                    category,
                                    maxPricePaise
                            );

                    for (ProductSummary product : found) {

                        if (product != null
                                && seen.add(product.id())) {

                            results.add(product);
                        }
                    }
                }
            }
        }

        List<ProductSummary> finalResults =
                results.stream()
                        .filter(Objects::nonNull)
                        .collect(
                                Collectors.toMap(
                                        ProductSummary::id,
                                        product -> product,
                                        (a, b) -> a,
                                        LinkedHashMap::new
                                )
                        )
                        .values()
                        .stream()
                        .limit(5)
                        .toList();

        turnContext.setProducts(
                finalResults.stream()
                        .map(ProductDtoMapper::from)
                        .toList()
        );

        storeLastSearchResults(
                sessionId,
                finalResults
        );


        if (finalResults.size() == 1) {

            setLastReferencedProduct(
                    sessionId,
                    finalResults.get(0).id()
            );
        }

        return finalResults;
    }

    @Tool(name = "getCart", description = "Return the authenticated user's current cart.")
    public CartResponse getCart(ToolContext toolContext) {
        UUID userId = getUserId(toolContext);
        CartResponse cart = commerceClient.getCart(userId);
        turnContext.setCart(CartDtoMapper.from(cart));
        return cart;
    }

    @Tool(
            name = "addToCart",
            description = """
                Add a real catalog product to the user's cart.

                The product reference may be:
                - an exact product UUID
                - an exact product title
                - "it"
                - "that"
                - "the first one"
                - "the second one"
                - another reference to a product from recent conversation

                Never invent product IDs.
                """
    )
    public Object addToCart(
            @ToolParam(
                    description = "Exact product ID, product title, or conversational reference"
            )
            String productReference,

            @ToolParam(
                    description = "Quantity to add"
            )
            Integer quantity,

            ToolContext toolContext
    ) {

        if (quantity == null || quantity <= 0) {
            return new ToolError(
                    "Quantity must be greater than zero."
            );
        }

        UUID userId =
                getUserId(toolContext);

        UUID sessionId =
                getSessionId(toolContext);

        UUID productId =
                resolveProductReference(
                        productReference,
                        userId,
                        sessionId
                );

        if (productId == null) {

            return new ToolError(
                    "I could not identify that product. "
                            + "Please specify which product you mean."
            );
        }

        try {

            CartResponse cart =
                    commerceClient.addToCart(
                            userId,
                            productId,
                            quantity
                    );

            turnContext.setCart(
                    CartDtoMapper.from(cart)
            );

            turnContext.setRecommendations(
                    List.of()
            );


            setLastReferencedProduct(
                    sessionId,
                    productId
            );

            try {

                storeRecommendations(
                        getComplementaryProductsInternal(
                                productId
                        )
                );

            } catch (Exception ignored) {

                turnContext.setRecommendations(
                        List.of()
                );
            }

            return cart;

        } catch (Exception e) {

            return new ToolError(
                    "Unable to add the product to the cart."
            );
        }
    }

    @Tool(
            name = "removeFromCart",
            description = """
        Remove ONE specific product from the user's cart.

        The product reference may be:
        - an exact product UUID
        - an exact product title
        - "it"
        - "that"
        - "that one"
        - "the first one"
        - "the second one"
        - "the watch"
        - "the shirt"
        - another unambiguous reference to a product
          from the recent conversation or cart.

        IMPORTANT:
        This tool removes only the referenced product.

        If the user says:
        - "remove it" -> remove the referenced product
        - "remove that" -> remove the referenced product

        Do NOT use this tool for:
        - "remove all"
        - "clear my cart"
        - "empty my cart"

        Those requests must use clearCart.

        Never invent a product ID.
        If the reference is ambiguous, ask for clarification.
        """
    )    public Object removeFromCart(
            @ToolParam(
                    description = """
        Product reference to remove from the cart.

        The reference can be:
        - an exact product UUID
        - an exact product title
        - "it"
        - "that"
        - "that one"
        - "this one"
        - "the first one"
        - "the second one"
        - another unambiguous reference from the recent conversation

        "remove it" means remove the referenced product only.

        Do NOT interpret "remove it" as clearing the entire cart.

        "remove all", "clear my cart", and "empty my cart"
        must use the clearCart operation instead.

        Do not invent a product ID.
        If the reference is ambiguous, ask the user to clarify.
        """
            )
            String productReference,
            ToolContext toolContext
    ) {
        UUID userId = getUserId(toolContext);
        UUID productId = resolveProductReference(productReference, userId, getSessionId(toolContext));

        if (productId == null) {
            return new ToolError("I could not identify that product. Please use getCart first.");
        }

        try {
            CartResponse cart = commerceClient.removeFromCart(userId, productId);
            turnContext.setCart(CartDtoMapper.from(cart));
            return cart;
        } catch (Exception e) {
            return new ToolError("Unable to remove the product from the cart.");
        }
    }

    @Tool(
            name = "updateCartQuantity",
            description = """
        SET the final quantity of ONE existing cart item.

        The product reference may be:
        - an exact product UUID
        - an exact product title
        - "it"
        - "that"
        - "that one"
        - "the first one"
        - "the second one"
        - another unambiguous reference from the conversation.

        IMPORTANT:
        This tool SETS the final quantity.

        Examples:
        "make it 3" -> final quantity = 3
        "change it to 2" -> final quantity = 2
        "set the watch to 4" -> final quantity = 4

        This is NOT an incremental operation.

        "add 3 more" is an ADD operation and should use addToCart.

        Never invent a product ID.
        If the product reference is ambiguous, ask for clarification.
        """
    )    public Object updateCartQuantity(
            @ToolParam(description ="""
        Product reference to update.

        The reference can be:
        - an exact product UUID
        - an exact product title
        - "it"
        - "that"
        - "that one"
        - "this one"
        - "the first one"
        - "the second one"
        - another unambiguous reference from the recent conversation

        Resolve conversational references using the current
        session context and most recently referenced product.

        Do not invent a product ID.
        If multiple products could match, ask the user to clarify.
        """
            ) String productReference,
            @ToolParam(description = "New quantity") Integer quantity,
            ToolContext toolContext
    ) {
        if (quantity == null || quantity <= 0) {
            return new ToolError("Quantity must be greater than zero.");
        }

        UUID userId = getUserId(toolContext);
        UUID productId = resolveProductReference(productReference, userId, getSessionId(toolContext));

        if (productId == null) {
            return new ToolError("I could not identify that product in the cart.");
        }

        try {
            CartResponse cart = commerceClient.updateCartQuantity(userId, productId, quantity);
            turnContext.setCart(CartDtoMapper.from(cart));
            return cart;
        } catch (Exception e) {
            return new ToolError("Unable to update the product quantity.");
        }
    }

    @Tool(name = "clearCart", description = "Remove all products from the authenticated user's cart.")
    public Object clearCart(ToolContext toolContext) {
        UUID userId = getUserId(toolContext);

        try {
            CartResponse cart = commerceClient.clearCart(userId);
            turnContext.setCart(CartDtoMapper.from(cart));
            return cart;
        } catch (Exception e) {
            return new ToolError("Unable to clear the cart.");
        }
    }

    @Tool(
            name = "proposeCheckout",
            description = """
        Start checkout only when the shopper explicitly wants to buy or checkout.

        Never mark payment as completed here.
        This method only creates the order and payment session.
        The resulting checkout state must be PAYMENT_REQUIRED until
        the payment is actually confirmed.
        """
    )
    public Object proposeCheckout(ToolContext toolContext) {

        UUID userId = getUserId(toolContext);
        UUID sessionId = getSessionId(toolContext);

        try {

            CartResponse cart = commerceClient.getCart(userId);
            turnContext.setCart(
                    cart == null ? null : CartDtoMapper.from(cart)
            );

            if (cart == null
                    || cart.items() == null
                    || cart.items().isEmpty()) {

                turnContext.setCheckout(
                        new CheckoutResponseState(
                                false,
                                cart == null ? null : cart.id(),
                                0L,
                                "Cannot checkout because the cart is empty."
                        )
                );

                return new GuardrailResult(
                        GuardrailDecision.BLOCKED,
                        "Cannot checkout because the cart is empty.",
                        List.of("cartNotEmpty=FAIL")
                );
            }

            List<CheckoutItem> items = cart.items()
                    .stream()
                    .map(item -> new CheckoutItem(
                            item.productId(),
                            item.productName(),
                            item.quantity(),
                            item.priceSnapshotInPaise(),
                            item.totalPriceInPaise()
                    ))
                    .toList();

            CheckoutProposal checkout = new CheckoutProposal(
                    cart.id(),
                    cart.totalAmountInPaise(),
                    items
            );

            MerchantPolicyResponse policy =
                    commerceClient.getPolicy();

            GuardrailResult result =
                    guardrailService.evaluate(
                            checkout,
                            policy
                    );

            ChatSession session =
                    getSession(sessionId, userId);

            if (result.decision() == GuardrailDecision.BLOCKED) {

                session.setCheckoutState(
                        CheckoutState.BLOCKED
                );

                session.setPendingCheckoutCartId(null);
                session.setPendingCheckoutIdempotencyKey(null);
                session.setUpdatedAt(LocalDateTime.now());

                chatSessionRepository.save(session);

                turnContext.setCheckout(
                        new CheckoutResponseState(
                                false,
                                cart.id(),
                                cart.totalAmountInPaise(),
                                result.reason()
                        )
                );

                return result;
            }

            if (result.decision() == GuardrailDecision.NEEDS_CONFIRMATION) {

                String idempotencyKey =
                        "agent-checkout-" + UUID.randomUUID();

                session.setCheckoutState(
                        CheckoutState.CONFIRMATION_REQUIRED
                );

                session.setPendingCheckoutCartId(
                        cart.id()
                );

                session.setPendingCheckoutIdempotencyKey(
                        idempotencyKey
                );

                session.setUpdatedAt(LocalDateTime.now());

                chatSessionRepository.save(session);

                turnContext.setCheckout(
                        new CheckoutResponseState(
                                true,
                                cart.id(),
                                cart.totalAmountInPaise(),
                                result.reason()
                        )
                );

                return result;
            }

            String idempotencyKey =
                    "agent-checkout-" + UUID.randomUUID();

            System.out.println(
                    "CHECKOUT: creating order, cartId="
                            + cart.id()
            );

            CommerceClient.CommerceOrderResponse order =
                    commerceClient.createOrder(
                            userId,
                            cart.id(),
                            idempotencyKey,
                            true
                    );

            if (order == null || order.id() == null) {
                throw new IllegalStateException(
                        "Commerce service returned no order"
                );
            }

            System.out.println(
                    "CHECKOUT: order created, orderId="
                            + order.id()
            );

            System.out.println(
                    "CHECKOUT: creating payment order, orderId="
                            + order.id()
            );

            PaymentOrderResponse payment =
                    commerceClient.createPaymentOrder(
                            userId,
                            order.id()
                    );

            if (payment == null
                    || payment.paymentId() == null
                    || payment.razorpayOrderId() == null) {

                throw new IllegalStateException(
                        "Commerce service returned invalid payment data"
                );
            }

            System.out.println(
                    "CHECKOUT: payment created, razorpayOrderId="
                            + payment.razorpayOrderId()
            );

            /*
             * IMPORTANT:
             * Order/payment session has been created,
             * but the user has NOT paid yet.
             */
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

            session.setPendingCheckoutCartId(null);
            session.setPendingCheckoutIdempotencyKey(null);
            session.setUpdatedAt(LocalDateTime.now());

            chatSessionRepository.save(session);

            String response =
                    "Your order is ready for payment.\n\n"
                            + "Order ID: "
                            + payment.orderId()
                            + "\nAmount: ₹"
                            + (payment.amountInPaise() / 100.0)
                            + "\nPayment Status: "
                            + payment.status()
                            + "\nPlease complete payment within 15 minutes.";

            turnContext.setCheckout(
                    new CheckoutResponseState(
                            false,
                            cart.id(),
                            payment.amountInPaise(),
                            response
                    )
            );

            return new CheckoutResult(
                    payment.orderId(),
                    payment.paymentId(),
                    payment.razorpayOrderId(),
                    payment.amountInPaise(),
                    payment.currency(),
                    payment.status(),
                    response
            );

        } catch (Exception e) {

            System.err.println(
                    "CHECKOUT FAILED: "
                            + e.getClass().getName()
                            + " - "
                            + e.getMessage()
            );

            e.printStackTrace();

            turnContext.setCheckout(
                    new CheckoutResponseState(
                            false,
                            null,
                            0L,
                            "Checkout could not be started."
                    )
            );

            return new ToolError(
                    "Checkout failed. The payment session could not be created."
            );
        }
    }

    @Tool(name = "getMyOrders", description = "Get the authenticated user's previous orders and order history.")
    public List<OrderDto> getMyOrders(ToolContext toolContext) {
        UUID userId = getUserId(toolContext);

        return commerceClient.getMyOrders(userId)
                .stream()
                .map(this::toOrderDto)
                .toList();
    }

    @Tool(name = "getOrder", description = "Get details of a specific real order. Never invent an order ID.")
    public OrderDto getOrder(
            @ToolParam(description = "UUID of the order") UUID orderId,
            ToolContext toolContext
    ) {
        UUID userId = getUserId(toolContext);
        return toOrderDto(commerceClient.getOrder(userId, orderId));
    }

    @Tool(name = "getCatalogCategories", description = "Return the real categories currently available.")
    public List<String> getCatalogCategories() {
        return commerceClient.getAvailableCategories();
    }

    @Tool(name = "getComplementaryProducts", description = "Find real complementary products for a real catalog product.")
    public List<ComplementaryRecommendation> getComplementaryProducts(
            @ToolParam(description = """
        Product for which complementary products should be found.

        The reference can be:
        - an exact product UUID
        - an exact product title
        - "it"
        - "that"
        - "that one"
        - "the first one"
        - "the second one"
        - another unambiguous reference from the recent conversation.

        Resolve the reference using the current session context.

        Never invent a product ID.
        """)
            String productReference,
            ToolContext toolContext
    ) {


        UUID userId = getUserId(toolContext);
        UUID sessionId = getSessionId(toolContext);

        UUID productId = resolveProductReference(productReference, userId, sessionId);
        if (productId == null) {
            return List.of();
        }

        return getComplementaryProductsInternal(productId);
    }

    private List<ComplementaryRecommendation> getComplementaryProductsInternal(
            UUID productId
    ) {
        ProductSummary sourceProduct = commerceClient.getProduct(productId);
        List<ProductSummary> candidates =
                commerceClient.getRecommendationCandidates(productId);

        if (sourceProduct == null || candidates.isEmpty()) {
            return List.of();
        }

        try {
            String prompt = """
                    You are a product recommendation engine.

                    SOURCE PRODUCT:
                    %s

                    CANDIDATE PRODUCTS:
                    %s

                    Choose at most 3 genuinely complementary products.

                    Rules:
                    - Only choose candidates.
                    - Never invent products or IDs.
                    - Prefer genuinely complementary products.
                    - Return an empty array when nothing is complementary.

                    Return only JSON:
                    [
                      {
                        "productId": "EXACT CANDIDATE ID",
                        "reason": "short reason"
                      }
                    ]
                    """.formatted(
                    objectMapper.writeValueAsString(sourceProduct),
                    objectMapper.writeValueAsString(candidates)
            );

            String result = chatClient.prompt()
                    .user(prompt)
                    .call()
                    .content();

            if (result == null || result.isBlank()) {
                return List.of();
            }

            List<ComplementaryRecommendation> recommendations =
                    objectMapper.readValue(
                            result,
                            objectMapper.getTypeFactory()
                                    .constructCollectionType(
                                            List.class,
                                            ComplementaryRecommendation.class
                                    )
                    );

            return recommendations == null
                    ? List.of()
                    : recommendations.stream()
                    .filter(Objects::nonNull)
                    .filter(r -> r.productId() != null)
                    .filter(r -> candidates.stream().anyMatch(
                            candidate -> candidate.id().toString().equals(r.productId())
                    ))
                    .limit(1)
                    .toList();

        } catch (Exception e) {
            return List.of();
        }
    }

    private void storeLastSearchResults(
            UUID sessionId,
            List<ProductSummary> products
    ) {
        try {
            ChatSession session =
                    chatSessionRepository.findById(sessionId)
                            .orElse(null);

            if (session == null) {
                return;
            }

            session.setLastSearchResultsJson(
                    objectMapper.writeValueAsString(products)
            );

            session.setUpdatedAt(
                    LocalDateTime.now()
            );

            chatSessionRepository.save(session);

        } catch (Exception ignored) {
        }
    }

    private void storeRecommendations(
            List<ComplementaryRecommendation> recommendations
    ) {
        if (recommendations == null || recommendations.isEmpty()) {
            turnContext.setRecommendations(List.of());
            return;
        }

        List<ProductRecommendationDto> structured = new ArrayList<>();

        for (ComplementaryRecommendation recommendation : recommendations) {
            try {
                UUID productId = UUID.fromString(recommendation.productId());
                ProductSummary product = commerceClient.getProduct(productId);

                if (product != null) {
                    structured.add(
                            new ProductRecommendationDto(
                                    ProductDtoMapper.from(product),
                                    recommendation.reason()
                            )
                    );
                }
            } catch (Exception ignored) {
            }

            if (structured.size() >= 3) {
                break;
            }
        }

        turnContext.setRecommendations(structured);
    }

    private UUID resolveFromOrdinal(
            String reference,
            List<ProductSummary> products
    ) {

        if (products == null
                || products.isEmpty()) {
            return null;
        }

        String value =
                normalize(reference);

        int index = switch (value) {

            case "first", "1", "one",
                 "firstproduct",
                 "product1",
                 "1st" -> 0;

            case "second", "2", "two",
                 "secondproduct",
                 "product2",
                 "2nd" -> 1;

            case "third", "3", "three",
                 "thirdproduct",
                 "product3",
                 "3rd" -> 2;

            case "fourth", "4", "four",
                 "fourthproduct",
                 "product4",
                 "4th" -> 3;

            case "fifth", "5", "five",
                 "fifthproduct",
                 "product5",
                 "5th" -> 4;

            default -> -1;
        };

        if (index < 0 || index >= products.size()) {
            return null;
        }

        ProductSummary product =
                products.get(index);

        return product == null
                ? null
                : product.id();
    }

    private UUID resolveProductReference(
            String productReference,
            UUID userId,
            UUID sessionId
    ) {

        if (productReference == null
                || productReference.isBlank()) {

            return null;
        }

        String value =
                productReference.trim();

        try {

            return UUID.fromString(value);

        } catch (IllegalArgumentException ignored) {
        }

        String normalized =
                normalize(value);


        List<ProductSummary> previousResults =
                getLastSearchResults(sessionId);


        if (isPronounReference(value)) {

            UUID lastReferenced =
                    getLastReferencedProduct(
                            sessionId
                    );

            if (lastReferenced != null) {
                return lastReferenced;
            }


            if (previousResults.size() == 1
                    && previousResults.get(0) != null) {

                return previousResults
                        .get(0)
                        .id();
            }


            if (turnContext.getProducts() != null
                    && turnContext.getProducts().size() == 1
                    && turnContext.getProducts().get(0) != null) {

                return turnContext
                        .getProducts()
                        .get(0)
                        .id();
            }

            /*
             * Multiple possible products:
             * do not guess.
             */
            return null;
        }


        UUID result =
                resolveFromOrdinal(
                        value,
                        previousResults
                );

        if (result != null) {
            return result;
        }

        result =
                previousResults.stream()
                        .filter(Objects::nonNull)
                        .filter(product ->
                                normalize(
                                        product.title()
                                ).equals(normalized)
                        )
                        .map(ProductSummary::id)
                        .findFirst()
                        .orElse(null);

        if (result != null) {
            return result;
        }


        if (turnContext.getProducts() != null) {

            result =
                    turnContext
                            .getProducts()
                            .stream()
                            .filter(Objects::nonNull)
                            .filter(product ->
                                    normalize(
                                            product.title()
                                    ).equals(normalized)
                            )
                            .map(ProductDto::id)
                            .findFirst()
                            .orElse(null);

            if (result != null) {
                return result;
            }
        }


        if (turnContext.getCart() != null
                && turnContext.getCart().items() != null) {

            result =
                    turnContext
                            .getCart()
                            .items()
                            .stream()
                            .filter(Objects::nonNull)
                            .filter(item ->
                                    normalize(
                                            item.title()
                                    ).equals(normalized)
                            )
                            .map(CartItemDto::productId)
                            .findFirst()
                            .orElse(null);

            if (result != null) {
                return result;
            }
        }


        if (userId != null) {

            try {

                CartResponse cart =
                        commerceClient.getCart(
                                userId
                        );

                if (cart != null
                        && cart.items() != null) {

                    result =
                            cart.items()
                                    .stream()
                                    .filter(Objects::nonNull)
                                    .filter(item ->
                                            normalize(
                                                    item.productName()
                                            ).equals(normalized)
                                    )
                                    .map(
                                            CartItemResponse::productId
                                    )
                                    .findFirst()
                                    .orElse(null);

                    if (result != null) {
                        return result;
                    }
                }

            } catch (Exception ignored) {
            }
        }


        try {

            return commerceClient
                    .search(
                            value,
                            null,
                            null
                    )
                    .stream()
                    .filter(Objects::nonNull)
                    .filter(product ->
                            normalize(
                                    product.title()
                            ).equals(normalized)
                    )
                    .map(ProductSummary::id)
                    .findFirst()
                    .orElse(null);

        } catch (Exception ignored) {

            return null;
        }
    }

    private List<ProductSummary> getLastSearchResults(
            UUID sessionId
    ) {
        try {
            ChatSession session =
                    chatSessionRepository.findById(sessionId)
                            .orElse(null);

            if (session == null
                    || session.getLastSearchResultsJson() == null
                    || session.getLastSearchResultsJson().isBlank()) {
                return List.of();
            }

            ProductSummary[] products =
                    objectMapper.readValue(
                            session.getLastSearchResultsJson(),
                            ProductSummary[].class
                    );

            return products == null
                    ? List.of()
                    : Arrays.asList(products);

        } catch (Exception e) {
            return List.of();
        }
    }

    private boolean isPronounReference(String value) {

        String normalized =
                normalize(value);

        return normalized.equals("it")
                || normalized.equals("that")
                || normalized.equals("thatone")
                || normalized.equals("this")
                || normalized.equals("thisone")
                || normalized.equals("theone")
                || normalized.equals("sameone");
    }

    private void setLastReferencedProduct(
            UUID sessionId,
            UUID productId
    ) {

        if (sessionId == null
                || productId == null) {

            return;
        }

        try {

            ChatSession session =
                    chatSessionRepository
                            .findById(sessionId)
                            .orElse(null);

            if (session == null) {
                return;
            }

            session.setLastReferencedProductId(
                    productId
            );

            session.setUpdatedAt(
                    LocalDateTime.now()
            );

            chatSessionRepository.save(
                    session
            );

        } catch (Exception ignored) {


        }
    }

    private UUID getLastReferencedProduct(
            UUID sessionId
    ) {

        if (sessionId == null) {
            return null;
        }

        try {

            return chatSessionRepository
                    .findById(sessionId)
                    .map(
                            ChatSession
                                    ::getLastReferencedProductId
                    )
                    .orElse(null);

        } catch (Exception ignored) {

            return null;
        }
    }

    private String normalize(String value) {
        if (value == null) {
            return "";
        }

        return value
                .toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9]", "");
    }

    private CatalogSearchIntent resolveCatalogIntent(
            String query,
            List<String> availableCategories
    ) {
        try {
            String prompt = """
        You are the product search intent interpreter for an e-commerce system.

        REAL CATALOG CATEGORIES:
        %s

        USER REQUEST:
        "%s"

        Your job is NOT to answer the user.

        Your job is to convert the request into search terms that
        can be used against a real product catalog.

        IMPORTANT:
        Think about common-sense relationships and synonyms.

        Examples:

        User:
        "something I can wear on my wrist"

        Search terms:
        ["watch", "smartwatch", "fitness watch", "wrist wearable"]

        User:
        "something for my feet for running"

        Search terms:
        ["running shoes", "running footwear", "sports shoes"]

        User:
        "something to carry water while running"

        Search terms:
        ["water bottle", "hydration bottle", "sports bottle"]

        User:
        "give me a device that tracks my heart rate"

        Search terms:
        ["smartwatch", "fitness tracker", "heart rate monitor"]

        Rules:
        - Categories MUST come from the provided real categories.
        - Do not invent products.
        - Do not invent categories.
        - Preserve meaningful user constraints.
        - Generate 2-5 useful search terms when the request is semantic.
        - Prefer concrete product concepts over abstract descriptions.

        Return ONLY JSON:

        {
          "searchQuery": "primary search phrase",
          "searchTerms": [
            "term 1",
            "term 2"
          ],
          "categories": [],
          "categoryOnly": false
        }
        """.formatted(
                    objectMapper.writeValueAsString(availableCategories),
                    query
            );

            CatalogSearchIntent result = chatClient.prompt()
                    .system(prompt)
                    .user(query == null ? "" : query)
                    .call()
                    .entity(CatalogSearchIntent.class);

            if (result == null) {
                return new CatalogSearchIntent(
                        query == null ? "" : query.trim(),
                        List.of(),
                        List.of(),
                        false
                );
            }

            List<String> validCategories = result.categories() == null
                    ? List.of()
                    : result.categories().stream()
                    .filter(Objects::nonNull)
                    .map(candidate ->
                            availableCategories.stream()
                                    .filter(real -> real.equalsIgnoreCase(candidate))
                                    .findFirst()
                                    .orElse(null)
                    )
                    .filter(Objects::nonNull)
                    .distinct()
                    .toList();

            return new CatalogSearchIntent(
                    result.searchQuery() == null
                            ? ""
                            : result.searchQuery().trim(),

                    result.searchTerms() == null
                            ? List.of()
                            : result.searchTerms(),

                    validCategories,

                    result.categoryOnly()
            );
        } catch (Exception e) {

            return new CatalogSearchIntent(
                    query == null
                            ? ""
                            : query.trim(),

                    List.of(),

                    List.of(),

                    false
            );
        }
    }

    private OrderDto toOrderDto(
            CommerceClient.CommerceOrderResponse order
    ) {
        if (order == null) {
            return null;
        }

        List<CartItemDto> items = order.items() == null
                ? List.of()
                : order.items().stream()
                .map(item ->
                        new CartItemDto(
                                item.productId(),
                                item.productName(),
                                item.priceInPaise(),
                                item.quantity(),
                                item.imageUrl(),
                                item.totalPriceInPaise()
                        )
                )
                .toList();

        return new OrderDto(
                order.id(),
                order.status(),
                items,
                order.totalAmountInPaise(),
                order.currency(),
                order.createdAt()
        );
    }

    private UUID getUserId(ToolContext toolContext) {
        Object value = toolContext.getContext().get("userId");

        if (value == null) {
            throw new IllegalStateException("User ID missing from tool context");
        }

        return UUID.fromString(value.toString());
    }

    private UUID getSessionId(ToolContext toolContext) {
        Object value = toolContext.getContext().get("sessionId");

        if (value == null) {
            throw new IllegalStateException("Session ID missing from tool context");
        }

        return UUID.fromString(value.toString());
    }

    private ChatSession getSession(
            UUID sessionId,
            UUID userId
    ) {
        return chatSessionRepository.findByIdAndUserId(sessionId, userId)
                .orElseThrow(
                        () -> new IllegalStateException("Chat session not found")
                );
    }

    public record ToolError(String error) {
    }

    @Tool(
            name = "setReferencedProduct",
            description = "Set the product currently being discussed by the user."
    )
    public ToolError setReferencedProduct(
            @ToolParam(description = "Exact product UUID")
            UUID productId,
            ToolContext toolContext
    ) {
        UUID sessionId = getSessionId(toolContext);

        ProductSummary product =
                commerceClient.getProduct(productId);

        if (product == null) {
            return new ToolError("Product does not exist.");
        }

        setLastReferencedProduct(sessionId, productId);

        return null;
    }
}
