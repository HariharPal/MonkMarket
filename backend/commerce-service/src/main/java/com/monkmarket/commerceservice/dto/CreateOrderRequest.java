package com.monkmarket.commerceservice.dto;

import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record CreateOrderRequest(
        @NotNull UUID cartId,
        @NotNull String idempotencyKey,
        boolean humanConfirmed
) {
}
