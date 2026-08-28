package com.monkmarket.paymentservice.client;

import com.monkmarket.paymentservice.dto.OrderInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class OrderClient {

    private final RestClient restClient;

    public OrderInfo getOrder(
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
                .body(OrderInfo.class);
    }

    public void markOrderPaid(
            UUID userId,
            UUID orderId
    ) {

        restClient
                .patch()
                .uri(
                        "http://localhost:8083/api/v1/orders/{orderId}/payment-status",
                        orderId
                )
                .header(
                        "X-User-Id",
                        userId.toString()
                )
                .retrieve()
                .toBodilessEntity();
    }

    public void expireOrder(
            UUID orderId
    ) {

        restClient
                .patch()
                .uri(
                        "http://localhost:8083/api/v1/orders/{orderId}/expire",
                        orderId
                )
                .retrieve()
                .toBodilessEntity();
    }
}