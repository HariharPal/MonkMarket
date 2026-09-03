package com.monkmarket.commerceservice.dto;

import com.monkmarket.commerceservice.model.CartItem;

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
    public static CartItemResponse from(CartItem item) {
        return new CartItemResponse(
                item.getId(),
                item.getProductId(),
                item.getProductName(),
                item.getPriceSnapshotInPaise(),
                item.getQuantity(),
                item.getPriceSnapshotInPaise() * item.getQuantity(),
                item.getImageUrl()
        );
    }
}
