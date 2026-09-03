package com.monkmarket.commerceservice.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public record ProductRequest(
        @NotBlank String title,
        String description,
        @NotNull @Min(1) Long priceInPaise,
        @NotBlank String currency,
        @NotBlank String category,
        @NotNull @Min(0) Integer stockQty,
        String imageUrl,
        boolean agentVisible
) {
}
