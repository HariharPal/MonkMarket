package com.monkmarket.agentservice.client;
import com.monkmarket.agentservice.service.audit.AuditedCommerceOperation;
import com.monkmarket.agentservice.dto.CartResponse;
import com.monkmarket.agentservice.dto.MerchantPolicyResponse;
import com.monkmarket.agentservice.dto.PaymentOrderResponse;
import com.monkmarket.agentservice.dto.ProductSummary;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;
import org.springframework.web.util.UriComponentsBuilder;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class CommerceClient {

    private final RestClient restClient;



    @Value("${services.commerce.url}")
    private String commerceBaseUrl;

    @AuditedCommerceOperation(
            method = "GET",
            path = "/api/v1/catalog/categories"
    )
    public List<String> getAvailableCategories() {
        String[] categories = restClient.get()
                .uri(commerceBaseUrl + "/api/v1/catalog/categories")
                .retrieve()
                .body(String[].class);

        return categories == null ? List.of() : Arrays.asList(categories);
    }

    @AuditedCommerceOperation(
            method = "GET",
            path = "/api/v1/catalog/search"
    )
    public List<ProductSummary> search(
            String query,
            String category,
            Long maxPricePaise
    ) {
        String uri = UriComponentsBuilder
                .fromUriString(commerceBaseUrl + "/api/v1/catalog/search")
                .queryParam("query", query == null ? "" : query)
                .queryParamIfPresent(
                        "category",
                        category == null || category.isBlank()
                                ? java.util.Optional.empty()
                                : java.util.Optional.of(category)
                )
                .queryParamIfPresent(
                        "maxPricePaise",
                        maxPricePaise == null
                                ? java.util.Optional.empty()
                                : java.util.Optional.of(maxPricePaise)
                )
                .toUriString();

        ProductSummary[] products = restClient.get()
                .uri(uri)
                .retrieve()
                .body(ProductSummary[].class);

        return products == null ? List.of() : Arrays.asList(products);
    }

    @AuditedCommerceOperation(
            method = "GET",
            path = "/api/v1/catalog/products/{productId}"
    )
    public ProductSummary getProduct(UUID productId) {
        return restClient.get()
                .uri(
                        commerceBaseUrl + "/api/v1/catalog/products/{productId}",
                        productId
                )
                .retrieve()
                .body(ProductSummary.class);
    }

    @AuditedCommerceOperation(
            method = "GET",
            path = "/api/v1/catalog/recommendation-candidates/{productId}"
    )
    public List<ProductSummary> getRecommendationCandidates(UUID productId) {
        ProductSummary[] products = restClient.get()
                .uri(
                        commerceBaseUrl + "/api/v1/catalog/recommendation-candidates/{productId}",
                        productId
                )
                .retrieve()
                .body(ProductSummary[].class);

        return products == null ? List.of() : Arrays.asList(products);
    }
    @AuditedCommerceOperation(
            method = "GET",
            path = "/api/v1/catalog/policy"
    )
    public MerchantPolicyResponse getPolicy() {
        return restClient.get()
                .uri(commerceBaseUrl + "/api/v1/catalog/policy")
                .retrieve()
                .body(MerchantPolicyResponse.class);
    }

    @AuditedCommerceOperation(
            method = "GET",
            path = "/api/v1/cart"
    )
    public CartResponse getCart(UUID userId) {
        return restClient.get()
                .uri(commerceBaseUrl + "/api/v1/cart")
                .header("X-User-Id", userId.toString())
                .retrieve()
                .body(CartResponse.class);
    }

    @AuditedCommerceOperation(
            method = "POST",
            path = "/api/v1/cart/items"
    )
    public CartResponse addToCart(
            UUID userId,
            UUID productId,
            int quantity
    ) {
        return restClient.post()
                .uri(commerceBaseUrl + "/api/v1/cart/items")
                .header("X-User-Id", userId.toString())
                .body(new AddCartItemRequest(productId, quantity))
                .retrieve()
                .body(CartResponse.class);
    }

    @AuditedCommerceOperation(
            method = "DELETE",
            path = "/api/v1/cart/items/{productId}"
    )
    public CartResponse removeFromCart(
            UUID userId,
            UUID productId
    ) {
        return restClient.delete()
                .uri(
                        commerceBaseUrl + "/api/v1/cart/items/{productId}",
                        productId
                )
                .header("X-User-Id", userId.toString())
                .retrieve()
                .body(CartResponse.class);
    }

    @AuditedCommerceOperation(
            method = "PATCH",
            path = "/api/v1/cart/items/{cartItemId}"
    )
    public CartResponse updateCartQuantity(
            UUID userId,
            UUID productId,
            int quantity
    ) {
        CartResponse cart = getCart(userId);

        if (cart == null || cart.items() == null) {
            throw new IllegalStateException("Cart not found");
        }

        UUID cartItemId = cart.items()
                .stream()
                .filter(item -> productId.equals(item.productId()))
                .map(item -> item.id())
                .findFirst()
                .orElseThrow(
                        () -> new IllegalArgumentException("Product is not in cart")
                );

        return restClient.patch()
                .uri(
                        commerceBaseUrl + "/api/v1/cart/items/{cartItemId}",
                        cartItemId
                )
                .header("X-User-Id", userId.toString())
                .body(new UpdateCartItemRequest(quantity))
                .retrieve()
                .body(CartResponse.class);
    }

    @AuditedCommerceOperation(
            method = "DELETE",
            path = "/api/v1/cart"
    )
    public CartResponse clearCart(UUID userId) {
        return restClient.delete()
                .uri(commerceBaseUrl + "/api/v1/cart")
                .header("X-User-Id", userId.toString())
                .retrieve()
                .body(CartResponse.class);
    }

    @AuditedCommerceOperation(
            method = "POST",
            path = "/api/v1/orders"
    )
    public CommerceOrderResponse createOrder(
            UUID userId,
            UUID cartId,
            String idempotencyKey,
            boolean humanConfirmed
    ) {
        return restClient.post()
                .uri(commerceBaseUrl + "/api/v1/orders")
                .header("X-User-Id", userId.toString())
                .body(
                        new CreateOrderRequest(
                                cartId,
                                idempotencyKey,
                                humanConfirmed
                        )
                )
                .retrieve()
                .body(CommerceOrderResponse.class);
    }

    @AuditedCommerceOperation(
            method = "GET",
            path = "/api/v1/orders/{orderId}"
    )
    public CommerceOrderResponse getOrder(
            UUID userId,
            UUID orderId
    ) {
        return restClient.get()
                .uri(
                        commerceBaseUrl + "/api/v1/orders/{orderId}",
                        orderId
                )
                .header("X-User-Id", userId.toString())
                .retrieve()
                .body(CommerceOrderResponse.class);
    }

    @AuditedCommerceOperation(
            method = "GET",
            path = "/api/v1/orders/my"
    )
    public List<CommerceOrderResponse> getMyOrders(UUID userId) {
        CommerceOrderResponse[] orders = restClient.get()
                .uri(commerceBaseUrl + "/api/v1/orders/my")
                .header("X-User-Id", userId.toString())
                .retrieve()
                .body(CommerceOrderResponse[].class);

        return orders == null ? List.of() : Arrays.asList(orders);
    }

    @AuditedCommerceOperation(
            method = "POST",
            path = "/api/v1/payments/orders"
    )
    public PaymentOrderResponse createPaymentOrder(
            UUID userId,
            UUID orderId
    ) {
        return restClient.post()
                .uri(commerceBaseUrl + "/api/v1/payments/orders")
                .header("X-User-Id", userId.toString())
                .body(new CreatePaymentRequest(orderId))
                .retrieve()
                .body(PaymentOrderResponse.class);
    }

    private record AddCartItemRequest(
            UUID productId,
            int quantity
    ) {
    }

    private record UpdateCartItemRequest(
            int quantity
    ) {
    }

    private record CreateOrderRequest(
            UUID cartId,
            String idempotencyKey,
            boolean humanConfirmed
    ) {
    }

    private record CreatePaymentRequest(
            UUID orderId
    ) {
    }

    public record CommerceOrderResponse(
            UUID id,
            UUID userId,
            UUID cartId,
            Long totalAmountInPaise,
            String currency,
            String status,
            List<CommerceOrderItem> items,
            LocalDateTime createdAt
    ) {
    }

    public record CommerceOrderItem(
            UUID id,
            UUID productId,
            String productName,
            Long priceInPaise,
            Integer quantity,
            Long totalPriceInPaise,
            String imageUrl
    ) {
    }
}
