package com.monkmarket.agentservice.dto;

import java.util.UUID;

public record CartItemResponse(
        UUID id,
        UUID productId,
        String productName,
        Long priceSnapshotInPaise,
        Integer quantity,
        Long totalPriceInPaise,
        String imageUrl
) {
}