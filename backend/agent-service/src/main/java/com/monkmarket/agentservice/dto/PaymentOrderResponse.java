package com.monkmarket.agentservice.dto;

import java.util.UUID;

public record PaymentOrderResponse(
        UUID paymentId,
        UUID orderId,
        String razorpayOrderId,
        Long amountInPaise,
        String currency,
        String status
) {
}