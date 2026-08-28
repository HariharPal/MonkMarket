package com.monkmarket.agentservice.client;

import com.monkmarket.agentservice.dto.PaymentOrderResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class PaymentClient {

    private final RestClient restClient;

    public PaymentOrderResponse createPaymentOrder(
            UUID userId,
            UUID orderId
    ) {

        CreatePaymentRequest request =
                new CreatePaymentRequest(
                        orderId
                );

        return restClient
                .post()
                .uri(
                        "http://localhost:8088/api/v1/payments/orders"
                )
                .header(
                        "X-User-Id",
                        userId.toString()
                )
                .body(request)
                .retrieve()
                .body(PaymentOrderResponse.class);
    }

    private record CreatePaymentRequest(
            UUID orderId
    ) {
    }
}