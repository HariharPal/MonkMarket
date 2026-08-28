package com.monkmarket.agentservice.client;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class OrderClient {

    private final RestClient restClient;

    public String getMyOrders(UUID userId) {

        return restClient
                .get()
                .uri("http://localhost:8083/api/v1/orders/my")
                .header(
                        "X-User-Id",
                        userId.toString()
                )
                .retrieve()
                .body(String.class);
    }

    public String getOrder(
            UUID userId,
            UUID orderId
    ) {

        return restClient
                .get()
                .uri(
                        "http://localhost:8083/api/v1/orders/{orderId}",
                        orderId
                )
                .header(
                        "X-User-Id",
                        userId.toString()
                )
                .retrieve()
                .body(String.class);
    }

    public String createOrder(
            UUID userId,
            UUID cartId,
            String idempotencyKey,
            boolean humanConfirmed
    ) {

        CreateOrderRequest request =
                new CreateOrderRequest(
                        cartId,
                        idempotencyKey,
                        humanConfirmed
                );

        return restClient
                .post()
                .uri(
                        "http://localhost:8083/api/v1/orders"
                )
                .header(
                        "X-User-Id",
                        userId.toString()
                )
                .body(request)
                .retrieve()
                .body(String.class);
    }

    private record CreateOrderRequest(
            UUID cartId,
            String idempotencyKey,
            boolean humanConfirmed
    ) {
    }
}