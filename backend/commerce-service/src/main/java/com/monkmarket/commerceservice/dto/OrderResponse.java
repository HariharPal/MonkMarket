package com.monkmarket.commerceservice.dto;

import com.monkmarket.commerceservice.model.Order;
import com.monkmarket.commerceservice.model.OrderStatus;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record OrderResponse(
        UUID id,
        UUID userId,
        UUID cartId,
        Long totalAmountInPaise,
        String currency,
        OrderStatus status,
        List<OrderItemResponse> items,
        LocalDateTime createdAt
) {
    public static OrderResponse from(Order order) {
        return new OrderResponse(
                order.getId(),
                order.getUserId(),
                order.getCartId(),
                order.getTotalAmountInPaise(),
                order.getCurrency(),
                order.getStatus(),
                order.getItems().stream()
                        .map(OrderItemResponse::from)
                        .toList(),
                order.getCreatedAt()
        );
    }
}
