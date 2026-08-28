package com.monkmarket.agentservice.dto;

import java.util.UUID;

public record CheckoutItem(
        UUID productId,
        String productName,
        Integer quantity,
        Long priceInPaise,
        Long totalPriceInPaise
) {
}