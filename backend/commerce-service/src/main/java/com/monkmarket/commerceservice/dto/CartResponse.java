package com.monkmarket.commerceservice.dto;

import com.monkmarket.commerceservice.model.Cart;
import com.monkmarket.commerceservice.model.CartStatus;

import java.util.List;
import java.util.UUID;

public record CartResponse(
        UUID id,
        UUID userId,
        CartStatus status,
        List<CartItemResponse> items,
        Long totalAmountInPaise
) {
    public static CartResponse from(Cart cart) {
        List<CartItemResponse> items = cart.getItems()
                .stream()
                .map(CartItemResponse::from)
                .toList();

        long total = items.stream()
                .mapToLong(CartItemResponse::totalPriceInPaise)
                .sum();

        return new CartResponse(
                cart.getId(),
                cart.getUserId(),
                cart.getStatus(),
                items,
                total
        );
    }
}
