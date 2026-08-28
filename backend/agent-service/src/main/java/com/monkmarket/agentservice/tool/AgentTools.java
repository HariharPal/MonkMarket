package com.monkmarket.agentservice.tool;

import com.monkmarket.agentservice.client.*;
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
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;

import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;

@Component
@RequiredArgsConstructor
public class AgentTools {

    private final CatalogClient catalogClient;
    private final CartClient cartClient;
    private final PolicyClient policyClient;
    private final GuardrailService guardrailService;
    private final OrderClient orderClient;
    private final ChatClient chatClient;
    private final ChatSessionRepository chatSessionRepository;
    private final PaymentClient paymentClient;
    private final ObjectMapper objectMapper;
    private final AgentTurnContext turnContext;

    @Tool(
            name = "searchCatalog",
            description = """
                Search the merchant catalog.

                Use this whenever the user asks for products,
                product recommendations, a specific product,
                or a semantic product category.

                Pass the user's natural-language request directly.

                Examples:
                "earbuds"
                "running shoes"
                "wearable stuff"
                "college products"
                "something for travel"

                Never invent products or categories.
                """
    )
    public List<ProductSummary> searchCatalog(

            @ToolParam(
                    description =
                            "Natural-language product request"
            )
            String query,

            @ToolParam(
                    description =
                            "Optional maximum price in Indian paise",
                    required = false
            )
            Long maxPricePaise
    ) {

        List<String> availableCategories =
                catalogClient.getAvailableCategories();

        if (availableCategories == null
                || availableCategories.isEmpty()) {

            turnContext.setProducts(
                    List.of()
            );

            return List.of();
        }

        CatalogSearchIntent intent =
                resolveCatalogIntent(
                        query,
                        availableCategories
                );

        List<ProductSummary> results =
                new ArrayList<>();

        List<String> categories =
                intent.categories();

        String searchQuery =
                intent.searchQuery();

        if (categories == null
                || categories.isEmpty()) {

            results.addAll(
                    catalogClient.search(
                            searchQuery,
                            null,
                            maxPricePaise
                    )
            );
        }

        else if (intent.categoryOnly()) {

            for (String category : categories) {

                results.addAll(
                        catalogClient.search(
                                "",
                                category,
                                maxPricePaise
                        )
                );
            }
        }

        else {

            for (String category : categories) {

                results.addAll(
                        catalogClient.search(
                                searchQuery,
                                category,
                                maxPricePaise
                        )
                );
            }
        }

        List<ProductSummary> finalResults =
                results
                        .stream()
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
                finalResults
                        .stream()
                        .map(
                                ProductDtoMapper::from
                        )
                        .toList()
        );

        return finalResults;
    }

    @Tool(
            name = "getCart",
            description = """
                    Return the authenticated user's current cart.

                    REQUIRED when the user asks:
                    - what is in my cart
                    - show my cart
                    - cart total
                    - what have I added
                    - is this in my cart

                    Never guess cart contents.
                    """
    )
    public CartResponse getCart(
            ToolContext toolContext
    ) {

        UUID userId =
                getUserId(toolContext);

        CartResponse cart =
                cartClient.getCart(
                        userId
                );

        turnContext.setCart(
                CartDtoMapper.from(cart)
        );

        return cart;
    }

    @Tool(
            name = "addToCart",
            description = """
                Add a product to the user's cart.

                The product reference must come from:
                - searchCatalog
                - getCart
                - a product shown in the conversation

                Never invent an ID.
                """
    )
    public Object addToCart(

            @ToolParam(
                    description =
                            "Exact product ID or product title"
            )
            String productId,

            @ToolParam(
                    description =
                            "Quantity to add"
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

        UUID realProductId =
                resolveProductReference(
                        productId,
                        userId
                );

        if (realProductId == null) {

            return new ToolError(
                    "I could not identify that product. "
                            + "Please search for it again."
            );
        }

        try {

            CartResponse cart =
                    cartClient.addToCart(
                            userId,
                            realProductId,
                            quantity
                    );

            turnContext.setCart(
                    CartDtoMapper.from(cart)
            );

            turnContext.setRecommendations(
                    List.of()
            );

            try {

                List<ComplementaryRecommendation>
                        recommendations =
                        getComplementaryProductsInternal(
                                realProductId
                        );

                storeRecommendations(
                        recommendations
                );

            } catch (Exception e) {

                turnContext.setRecommendations(
                        List.of()
                );
            }

            return cart;

        } catch (Exception e) {

            System.err.println(
                    "Add to cart failed: "
                            + e.getMessage()
            );

            return new ToolError(
                    "Unable to add the product to the cart."
            );
        }
    }

    @Tool(
            name = "removeFromCart",
            description = """
                    Remove a product from the authenticated user's cart.

                    The product reference may be:
                    - exact product ID
                    - exact product title

                    It must come from real cart/catalog data.

                    NEVER invent a product ID.
                    """
    )
    public Object removeFromCart(

            @ToolParam(
                    description =
                            "Exact product ID or product title"
            )
            String productId,

            ToolContext toolContext
    ) {

        UUID userId =
                getUserId(toolContext);

        UUID realProductId =
                resolveProductReference(
                        productId,
                        userId
                );

        if (realProductId == null) {

            return new ToolError(
                    "I could not identify that product. "
                            + "Please use getCart first."
            );
        }

        try {

            CartResponse cart =
                    cartClient.removeFromCart(
                            userId,
                            realProductId
                    );

            turnContext.setCart(
                    CartDtoMapper.from(cart)
            );

            return cart;

        } catch (Exception e) {

            return new ToolError(
                    "Unable to remove the product from the cart."
            );
        }
    }

    @Tool(
            name = "updateCartQuantity",
            description = """
                    Update the quantity of a product already in the cart.

                    The product reference may be:
                    - exact product ID
                    - exact product title

                    Quantity must be greater than zero.
                    """
    )
    public Object updateCartQuantity(

            @ToolParam(
                    description =
                            "Exact product ID or product title"
            )
            String productId,

            @ToolParam(
                    description =
                            "New quantity"
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

        UUID realProductId =
                resolveProductReference(
                        productId,
                        userId
                );

        if (realProductId == null) {

            return new ToolError(
                    "I could not identify that product in the cart."
            );
        }

        try {

            CartResponse cart =
                    cartClient.updateCartQuantity(
                            userId,
                            realProductId,
                            quantity
                    );

            turnContext.setCart(
                    CartDtoMapper.from(cart)
            );

            return cart;

        } catch (Exception e) {

            return new ToolError(
                    "Unable to update the product quantity."
            );
        }
    }

    @Tool(
            name = "clearCart",
            description = """
                    Remove ALL products from the authenticated user's cart.

                    Use ONLY when the user explicitly asks:
                    - clear cart
                    - empty cart
                    - remove everything
                    - delete everything

                    Do not use for a single product.
                    """
    )
    public Object clearCart(
            ToolContext toolContext
    ) {

        UUID userId =
                getUserId(toolContext);

        try {

            CartResponse cart =
                    cartClient.clearCart(
                            userId
                    );

            turnContext.setCart(
                    CartDtoMapper.from(cart)
            );

            return cart;

        } catch (Exception e) {

            return new ToolError(
                    "Unable to clear the cart."
            );
        }
    }

    @Tool(
            name = "proposeCheckout",
            description = """
                    Start checkout when the shopper explicitly asks to:

                    - checkout
                    - check out
                    - buy
                    - purchase
                    - place the order
                    - proceed to payment

                    This tool:
                    1. Reads the current cart.
                    2. Gets merchant policy.
                    3. Runs deterministic guardrails.
                    4. Stores pending checkout if confirmation is needed.
                    5. Creates order/payment only when allowed.

                    Never claim payment completed.
                    Never bypass guardrails.
                    """
    )
    public Object proposeCheckout(
            ToolContext toolContext
    ) {

        UUID userId =
                getUserId(toolContext);

        UUID sessionId =
                getSessionId(toolContext);

        CartResponse cart =
                cartClient.getCart(
                        userId
                );

        turnContext.setCart(
                CartDtoMapper.from(cart)
        );

        if (cart.items() == null
                || cart.items().isEmpty()) {

            turnContext.setCheckout(
                    new CheckoutResponseState(
                            false,
                            cart.id(),
                            0L,
                            "Cannot checkout because the cart is empty."
                    )
            );

            return new GuardrailResult(
                    GuardrailDecision.BLOCKED,
                    "Cannot checkout because the cart is empty.",
                    List.of(
                            "cartNotEmpty=FAIL"
                    )
            );
        }

        List<CheckoutItem> items =
                cart.items()
                        .stream()
                        .map(
                                item ->
                                        new CheckoutItem(
                                                item.productId(),
                                                item.productName(),
                                                item.quantity(),
                                                item.priceSnapshotInPaise(),
                                                item.totalPriceInPaise()
                                        )
                        )
                        .toList();

        CheckoutProposal checkout =
                new CheckoutProposal(
                        cart.id(),
                        cart.totalAmountInPaise(),
                        items
                );

        MerchantPolicyResponse policy =
                policyClient.getPolicy();

        GuardrailResult result =
                guardrailService.evaluate(
                        checkout,
                        policy
                );

        if (result.decision()
                == GuardrailDecision.BLOCKED) {

            ChatSession session =
                    getSession(
                            sessionId,
                            userId
                    );

            session.setCheckoutState(
                    CheckoutState.BLOCKED
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

            turnContext.setCheckout(
                    new CheckoutResponseState(
                            false,
                            cart.id(),
                            cart.totalAmountInPaise(),
                            result.reason()
                    )
            );

            chatSessionRepository.save(
                    session
            );

            return result;
        }

        if (result.decision()
                == GuardrailDecision.NEEDS_CONFIRMATION) {

            String idempotencyKey =
                    "agent-checkout-" +
                            UUID.randomUUID();

            ChatSession session =
                    getSession(
                            sessionId,
                            userId
                    );

            session.setCheckoutState(
                    CheckoutState.CONFIRMATION_REQUIRED
            );

            session.setPendingCheckoutCartId(
                    cart.id()
            );

            session.setPendingCheckoutIdempotencyKey(
                    idempotencyKey
            );

            session.setUpdatedAt(
                    LocalDateTime.now()
            );

            turnContext.setCheckout(
                    new CheckoutResponseState(
                            true,
                            cart.id(),
                            cart.totalAmountInPaise(),
                            result.reason()
                    )
            );

            chatSessionRepository.save(
                    session
            );

            return result;
        }

        String idempotencyKey =
                "agent-checkout-" +
                        UUID.randomUUID();

        String orderJson =
                orderClient.createOrder(
                        userId,
                        cart.id(),
                        idempotencyKey,
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

        ChatSession session =
                getSession(
                        sessionId,
                        userId
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

        turnContext.setCheckout(
                new CheckoutResponseState(
                        false,
                        cart.id(),
                        payment.amountInPaise(),
                        "Order created. "
                                + "Please complete payment within 15 minutes."
                )
        );

        return new CheckoutResult(
                orderId,
                payment.paymentId(),
                payment.razorpayOrderId(),
                payment.amountInPaise(),
                payment.currency(),
                payment.status(),
                "Order created. Please complete payment within 15 minutes."
        );
    }

    @Tool(
            name = "getCatalogCategories",
            description = """
                    Return the REAL categories available in the merchant catalog.

                    Use this when needed to understand broad semantic requests.

                    Never invent categories.
                    """
    )
    public List<String> getCatalogCategories() {

        return catalogClient
                .getAvailableCategories();
    }

    @Tool(
            name = "getComplementaryProducts",
            description = """
                    Find REAL products that may complement a product.

                    The product reference must come from real catalog/cart data.

                    Recommendations are optional.

                    Never invent:
                    - products
                    - prices
                    - IDs
                    """
    )
    public List<ComplementaryRecommendation>
    getComplementaryProducts(

            @ToolParam(
                    description =
                            "Exact product ID or product title"
            )
            String productId
    ) {

        UUID realProductId =
                resolveProductReference(
                        productId,
                        null
                );

        if (realProductId == null) {
            return List.of();
        }

        return getComplementaryProductsInternal(
                realProductId
        );
    }

    private List<ComplementaryRecommendation>
    getComplementaryProductsInternal(
            UUID productId
    ) {

        ProductSummary sourceProduct =
                catalogClient.getProduct(
                        productId
                );

        List<ProductSummary> candidates =
                catalogClient.getRecommendationCandidates(
                        productId
                );

        if (candidates == null
                || candidates.isEmpty()) {

            return List.of();
        }

        try {

            String sourceJson =
                    objectMapper.writeValueAsString(
                            sourceProduct
                    );

            String candidatesJson =
                    objectMapper.writeValueAsString(
                            candidates
                    );

            String prompt =
                    """
                    You are a product recommendation engine.

                    SOURCE PRODUCT:
                    %s

                    CANDIDATE PRODUCTS:
                    %s

                    Choose at most 3 genuinely complementary products.

                    RULES:

                    - ONLY choose products from CANDIDATE PRODUCTS.
                    - Never invent products.
                    - Never invent IDs.
                    - Prefer complementary products.
                    - Do not recommend duplicates.
                    - Recommendations are optional.
                    - If no product is genuinely complementary,
                      return an empty array.

                    Return ONLY JSON:

                    [
                      {
                        "productId": "EXACT CANDIDATE ID",
                        "reason": "short reason"
                      }
                    ]
                    """.formatted(
                            sourceJson,
                            candidatesJson
                    );

            String result =
                    chatClient
                            .prompt()
                            .user(prompt)
                            .call()
                            .content();

            if (result == null
                    || result.isBlank()) {

                return List.of();
            }

            List<ComplementaryRecommendation>
                    recommendations =
                    objectMapper.readValue(
                            result,
                            objectMapper
                                    .getTypeFactory()
                                    .constructCollectionType(
                                            List.class,
                                            ComplementaryRecommendation.class
                                    )
                    );

            if (recommendations == null) {
                return List.of();
            }

            List<ComplementaryRecommendation>
                    validated =

                    recommendations
                            .stream()
                            .filter(
                                    Objects::nonNull
                            )
                            .filter(
                                    recommendation ->
                                            recommendation.productId()
                                                    != null
                            )
                            .filter(
                                    recommendation ->
                                            candidates
                                                    .stream()
                                                    .anyMatch(
                                                            candidate ->
                                                                    candidate.id()
                                                                            .toString()
                                                                            .equals(
                                                                                    recommendation.productId()
                                                                            )
                                                    )
                            )
                            .limit(3)
                            .toList();

            return validated;

        } catch (Exception e) {

            System.err.println(
                    "Recommendation generation failed: "
                            + e.getMessage()
            );

            return List.of();
        }
    }

    private void storeRecommendations(
            List<ComplementaryRecommendation> recommendations
    ) {

        if (recommendations == null
                || recommendations.isEmpty()) {

            turnContext.setRecommendations(
                    List.of()
            );

            return;
        }

        List<ProductRecommendationDto> structured =
                new ArrayList<>();

        for (ComplementaryRecommendation recommendation
                : recommendations) {

            if (recommendation == null
                    || recommendation.productId() == null) {

                continue;
            }

            try {

                UUID productId =
                        UUID.fromString(
                                recommendation.productId()
                        );

                ProductSummary product =
                        catalogClient.getProduct(
                                productId
                        );

                if (product == null) {
                    continue;
                }

                structured.add(
                        new ProductRecommendationDto(
                                ProductDtoMapper.from(product),
                                recommendation.reason()
                        )
                );

            } catch (Exception e) {
            }

            if (structured.size() >= 3) {
                break;
            }
        }

        turnContext.setRecommendations(
                structured
        );
    }

    private UUID resolveProductReference(
            String productReference,
            UUID userId
    ) {

        if (productReference == null
                || productReference.isBlank()) {

            return null;
        }

        String value =
                productReference.trim();

        try {

            return UUID.fromString(
                    value
            );

        } catch (IllegalArgumentException ignored) {
        }

        String normalized =
                normalize(
                        value
                );

        UUID result =
                turnContext
                        .getProducts()
                        .stream()
                        .filter(
                                Objects::nonNull
                        )
                        .filter(
                                product ->
                                        normalize(
                                                product.title()
                                        )
                                                .equals(
                                                        normalized
                                                )
                        )
                        .map(
                                ProductDto::id
                        )
                        .findFirst()
                        .orElse(null);

        if (result != null) {
            return result;
        }

        if (turnContext.getCart() != null
                && turnContext.getCart().items() != null) {

            result =
                    turnContext
                            .getCart()
                            .items()
                            .stream()
                            .filter(
                                    Objects::nonNull
                            )
                            .filter(
                                    item ->
                                            normalize(
                                                    item.title()
                                            )
                                                    .equals(
                                                            normalized
                                                    )
                            )
                            .map(
                                    CartItemDto::productId
                            )
                            .findFirst()
                            .orElse(null);

            if (result != null) {
                return result;
            }
        }

        if (userId != null) {

            try {

                CartResponse cart =
                        cartClient.getCart(
                                userId
                        );

                if (cart != null
                        && cart.items() != null) {

                    result =
                            cart.items()
                                    .stream()
                                    .filter(Objects::nonNull)
                                    .filter(
                                            item ->
                                                    normalize(
                                                            item.productName()
                                                    )
                                                            .equals(
                                                                    normalized
                                                            )
                                    )
                                    .map(
                                            item ->
                                                    item.productId()
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

            List<ProductSummary> products =
                    catalogClient.search(
                            value,
                            null,
                            null
                    );

            if (products != null) {

                result =
                        products
                                .stream()
                                .filter(
                                        Objects::nonNull
                                )
                                .filter(
                                        product ->
                                                normalize(
                                                        product.title()
                                                )
                                                        .equals(
                                                                normalized
                                                        )
                                )
                                .map(
                                        ProductSummary::id
                                )
                                .findFirst()
                                .orElse(null);

                if (result != null) {
                    return result;
                }
            }

        } catch (Exception ignored) {
        }

        return null;
    }

    private String normalize(
            String value
    ) {

        if (value == null) {
            return "";
        }

        return value
                .toLowerCase(Locale.ROOT)
                .replaceAll(
                        "[^a-z0-9]",
                        ""
                );
    }

    private CatalogSearchIntent resolveCatalogIntent(
            String query,
            List<String> availableCategories
    ) {

        try {

            String categoriesJson =
                    objectMapper.writeValueAsString(
                            availableCategories
                    );

            String prompt =
                    """
                    You are a shopping intent classifier.

                    REAL CATALOG CATEGORIES:
                    %s

                    USER REQUEST:
                    "%s"

                    Decide whether the request is:

                    A) CATEGORY-LEVEL
                    Example:
                    "wearable"
                    "fashion"
                    "college stuff"
                    "travel stuff"

                    B) SPECIFIC PRODUCT SEARCH
                    Example:
                    "earbuds"
                    "running shoes"
                    "wireless mouse"
                    "black backpack"

                    Rules:

                    - ONLY return categories from REAL CATALOG CATEGORIES.
                    - NEVER invent categories.
                    - Semantic understanding is allowed.
                    - For CATEGORY-LEVEL requests:
                      searchQuery = ""
                      categoryOnly = true

                    - For SPECIFIC PRODUCT searches:
                      preserve the specific product keyword in searchQuery.
                      categoryOnly = false

                    Example:

                    User: "wearable stuff"

                    {
                      "searchQuery": "",
                      "categories": ["SHOES", "ACCESSORIES"],
                      "categoryOnly": true
                    }

                    User: "earbuds"

                    {
                      "searchQuery": "earbuds",
                      "categories": ["ELECTRONICS"],
                      "categoryOnly": false
                    }

                    User: "running shoes"

                    {
                      "searchQuery": "running shoes",
                      "categories": ["SHOES"],
                      "categoryOnly": false
                    }

                    Return ONLY JSON.
                    """.formatted(
                            categoriesJson,
                            query == null ? "" : query
                    );

            CatalogSearchIntent result =
                    chatClient
                            .prompt()
                            .system(prompt)
                            .user(
                                    query == null
                                            ? ""
                                            : query
                            )
                            .call()
                            .entity(
                                    CatalogSearchIntent.class
                            );

            if (result == null) {

                return new CatalogSearchIntent(
                        query == null
                                ? ""
                                : query.trim(),
                        List.of(),
                        false
                );
            }

            List<String> validCategories =
                    result.categories() == null
                            ? List.of()
                            : result.categories()
                            .stream()
                            .filter(
                                    Objects::nonNull
                            )
                            .filter(
                                    candidate ->
                                            availableCategories
                                                    .stream()
                                                    .anyMatch(
                                                            real ->
                                                                    real.equalsIgnoreCase(
                                                                            candidate
                                                                    )
                                                    )
                            )
                            .map(
                                    candidate ->
                                            availableCategories
                                                    .stream()
                                                    .filter(
                                                            real ->
                                                                    real.equalsIgnoreCase(
                                                                            candidate
                                                                    )
                                                    )
                                                    .findFirst()
                                                    .orElse(null)
                            )
                            .filter(
                                    Objects::nonNull
                            )
                            .distinct()
                            .toList();

            return new CatalogSearchIntent(
                    result.searchQuery() == null
                            ? ""
                            : result.searchQuery().trim(),

                    validCategories,

                    result.categoryOnly()
            );

        } catch (Exception e) {

            System.err.println(
                    "Catalog intent resolution failed: "
                            + e.getMessage()
            );

            return new CatalogSearchIntent(
                    query == null
                            ? ""
                            : query.trim(),
                    List.of(),
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

            JsonNode id =
                    json.get("id");

            if (id == null
                    || id.isNull()) {

                throw new IllegalStateException(
                        "Order response does not contain id"
                );
            }

            return UUID.fromString(
                    id.asText()
            );

        } catch (Exception e) {

            throw new IllegalStateException(
                    "Could not parse order response",
                    e
            );
        }
    }

    private UUID getUserId(
            ToolContext toolContext
    ) {

        Object value =
                toolContext
                        .getContext()
                        .get("userId");

        if (value == null) {

            throw new IllegalStateException(
                    "User ID missing from tool context"
            );
        }

        return UUID.fromString(
                value.toString()
        );
    }

    private UUID getSessionId(
            ToolContext toolContext
    ) {

        Object value =
                toolContext
                        .getContext()
                        .get("sessionId");

        if (value == null) {

            throw new IllegalStateException(
                    "Session ID missing from tool context"
            );
        }

        return UUID.fromString(
                value.toString()
        );
    }

    private ChatSession getSession(
            UUID sessionId,
            UUID userId
    ) {

        return chatSessionRepository
                .findByIdAndUserId(
                        sessionId,
                        userId
                )
                .orElseThrow(
                        () ->
                                new IllegalStateException(
                                        "Chat session not found"
                                )
                );
    }

    public record ToolError(
            String error
    ) {
    }
}