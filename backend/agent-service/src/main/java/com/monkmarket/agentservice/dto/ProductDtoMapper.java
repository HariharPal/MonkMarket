package com.monkmarket.agentservice.dto;

public final class ProductDtoMapper {

    private ProductDtoMapper() {
    }

    public static ProductDto from(
            ProductSummary product
    ) {

        return new ProductDto(
                product.id(),
                product.title(),
                product.description(),
                product.priceInPaise(),
                product.currency(),
                product.category(),
                product.stockQty(),
                product.imageUrl()
        );
    }
}