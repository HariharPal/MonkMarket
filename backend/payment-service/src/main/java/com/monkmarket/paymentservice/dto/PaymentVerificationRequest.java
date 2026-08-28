package com.monkmarket.paymentservice.dto;

import java.util.UUID;

public record PaymentVerificationRequest(
        UUID orderId,
        String razorpayPaymentId,
        String razorpaySignature
) {
}