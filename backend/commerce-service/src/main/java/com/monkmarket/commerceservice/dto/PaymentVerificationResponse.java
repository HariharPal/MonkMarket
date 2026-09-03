package com.monkmarket.commerceservice.dto;

import java.util.UUID;

public record PaymentVerificationResponse(
        boolean success,
        String message,
        UUID orderId,
        UUID paymentId,
        String paymentStatus,
        String orderStatus
) {
}