
package com.monkmarket.agentservice.dto;

import java.util.UUID;

public record ProductInfo(

        UUID id,

        String title,

        String description,

        Long priceInPaise,

        String currency,

        String category,

        Integer stockQty,

        String imageUrl,

        boolean agentVisible

) {
}