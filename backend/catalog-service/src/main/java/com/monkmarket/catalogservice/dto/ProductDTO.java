package com.monkmarket.catalogservice.dto;

import java.util.UUID;

public record ProductDTO(
        UUID id,
        String title,
        String description,
        Long priceInPaise,
        String currency,
        String category,
        Integer stockQty,
        String imageUrl,
        boolean agentVisible
) {}