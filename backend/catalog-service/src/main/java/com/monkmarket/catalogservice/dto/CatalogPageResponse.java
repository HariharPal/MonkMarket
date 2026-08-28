package com.monkmarket.catalogservice.dto;

import java.util.List;

public record CatalogPageResponse(
        List<ProductDTO> products,
        int page,
        int size,
        long totalElements,
        int totalPages
) {}