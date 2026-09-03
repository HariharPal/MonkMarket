package com.monkmarket.commerceservice.dto;

import com.monkmarket.commerceservice.model.Product;

import java.util.UUID;

public record ProductSummary(
        UUID id,
        String title,
        String description,
        Long priceInPaise,
        String currency,
        String category,
        Integer stockQty,
        String imageUrl
) {
    public static ProductSummary from(Product product) {
        return new ProductSummary(
                product.getId(),
                product.getTitle(),
                product.getDescription(),
                product.getPriceInPaise(),
                product.getCurrency(),
                product.getCategory(),
                product.getStockQty(),
                product.getImageUrl()
        );
    }
}
