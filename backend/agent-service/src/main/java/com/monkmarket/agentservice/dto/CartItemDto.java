
package com.monkmarket.agentservice.dto;

import java.util.UUID;

public record CartItemDto(

        UUID productId,

        String title,

        Long priceInPaise,

        Integer quantity,

        String imageUrl,

        Long lineTotalInPaise

) {
}