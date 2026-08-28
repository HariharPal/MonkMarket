package com.monkmarket.catalogservice.dto;

import com.monkmarket.catalogservice.model.Product;

import java.util.UUID;

public record ProductResponse(

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

    public static ProductResponse from(Product product) {

        return new ProductResponse(

                product.getId(),

                product.getTitle(),

                product.getDescription(),

                product.getPriceInPaise(),

                product.getCurrency(),

                product.getCategory(),

                product.getStockQty(),

                product.getImageUrl(),

                product.isAgentVisible()
        );
    }
}