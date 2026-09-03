package com.monkmarket.commerceservice.dto;

import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record CreatePaymentRequest(
        @NotNull UUID orderId
) {
}
