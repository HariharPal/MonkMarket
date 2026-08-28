
package com.monkmarket.agentservice.dto;

import java.util.UUID;

public record ProductDto(

        UUID id,

        String title,

        String description,

        Long priceInPaise,

        String currency,

        String category,

        Integer stockQty,

        String imageUrl

) {
}