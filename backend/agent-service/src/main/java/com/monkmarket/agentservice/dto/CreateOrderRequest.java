package com.monkmarket.agentservice.dto;

import java.util.UUID;

public record CreateOrderRequest(
        UUID cartId,
        String idempotencyKey
) {
}