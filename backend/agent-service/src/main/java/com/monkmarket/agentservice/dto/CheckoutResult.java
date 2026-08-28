package com.monkmarket.agentservice.dto;

import java.util.UUID;

public record CheckoutResult(
        UUID orderId,
        UUID paymentId,
        String razorpayOrderId,
        Long amountInPaise,
        String currency,
        String paymentStatus,
        String message
) {
}