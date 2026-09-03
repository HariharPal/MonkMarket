package com.monkmarket.commerceservice.dto;

import com.monkmarket.commerceservice.model.OrderItem;

import java.util.UUID;

public record OrderItemResponse(
        UUID id,
        UUID productId,
        String productName,
        Long priceInPaise,
        Integer quantity,
        Long totalPriceInPaise,
        String imageUrl
) {
    public static OrderItemResponse from(OrderItem item) {
        return new OrderItemResponse(
                item.getId(),
                item.getProductId(),
                item.getProductName(),
                item.getPriceInPaise(),
                item.getQuantity(),
                item.getTotalPriceInPaise(),
                item.getImageUrl()
        );
    }
}
