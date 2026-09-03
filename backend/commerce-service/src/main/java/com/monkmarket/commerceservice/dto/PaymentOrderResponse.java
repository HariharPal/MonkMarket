package com.monkmarket.commerceservice.dto;

import com.monkmarket.commerceservice.model.PaymentStatus;

import java.util.UUID;

public record PaymentOrderResponse(
        UUID paymentId,
        UUID orderId,
        String razorpayOrderId,
        Long amountInPaise,
        String currency,
        PaymentStatus status
) {
}
