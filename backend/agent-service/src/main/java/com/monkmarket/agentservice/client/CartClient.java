package com.monkmarket.agentservice.client;

import com.monkmarket.agentservice.dto.CartResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class CartClient {

    private final RestClient restClient;

    public CartResponse getCart(UUID userId) {

        return restClient
                .get()
                .uri("http://localhost:8085/api/v1/cart")
                .header("X-User-Id", userId.toString())
                .retrieve()
                .body(CartResponse.class);
    }

    public CartResponse removeFromCart(
            UUID userId,
            UUID productId
    ) {

        return restClient
                .delete()
                .uri(
                        "http://localhost:8085/api/v1/cart/items/{productId}",
                        productId
                )
                .header("X-User-Id", userId.toString())
                .retrieve()
                .body(CartResponse.class);
    }




    public CartResponse addToCart(
            UUID userId,
            UUID productId,
            int quantity
    ) {

        AddCartItemRequest request =
                new AddCartItemRequest(
                        productId,
                        quantity
                );

        return restClient
                .post()
                .uri("http://localhost:8085/api/v1/cart/items")
                .header("X-User-Id", userId.toString())
                .body(request)
                .retrieve()
                .body(CartResponse.class);
    }

    public CartResponse updateCartQuantity(
            UUID userId,
            UUID productId,
            int quantity
    ) {

        UpdateCartItemRequest request =
                new UpdateCartItemRequest(quantity);

        return restClient
                .put()
                .uri(
                        "http://localhost:8085/api/v1/cart/items/{productId}",
                        productId
                )
                .header("X-User-Id", userId.toString())
                .body(request)
                .retrieve()
                .body(CartResponse.class);
    }

    private record UpdateCartItemRequest(
            int quantity
    ) {
    }

    private record AddCartItemRequest(
            UUID productId,
            int quantity
    ) {
    }

    public CartResponse clearCart(
            UUID userId
    ) {

        return restClient
                .delete()
                .uri(
                        "http://localhost:8085/api/v1/cart"
                )
                .header(
                        "X-User-Id",
                        userId.toString()
                )
                .retrieve()
                .body(CartResponse.class);
    }
}