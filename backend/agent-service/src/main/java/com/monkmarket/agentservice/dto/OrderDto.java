
package com.monkmarket.agentservice.dto;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record OrderDto(

        UUID orderId,

        String status,

        List<CartItemDto> items,

        Long totalInPaise,

        String currency,

        LocalDateTime createdAt

) {
}