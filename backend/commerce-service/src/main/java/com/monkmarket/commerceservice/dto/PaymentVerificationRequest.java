package com.monkmarket.commerceservice.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record PaymentVerificationRequest(
        @NotNull UUID orderId,
        @NotBlank String razorpayPaymentId,
        @NotBlank String razorpaySignature
) {
}
