package com.monkmarket.agentservice.dto;

import java.util.List;
import java.util.UUID;

public record CartResponse(
        UUID id,
        UUID userId,
        String status,
        List<CartItemResponse> items,
        Long totalAmountInPaise
) {
}