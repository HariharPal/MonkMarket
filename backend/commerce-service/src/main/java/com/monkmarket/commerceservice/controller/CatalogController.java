package com.monkmarket.commerceservice.controller;

import com.monkmarket.commerceservice.dto.ProductSummary;
import com.monkmarket.commerceservice.service.CatalogService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/catalog")
@RequiredArgsConstructor
public class CatalogController {

    private final CatalogService catalogService;

    @GetMapping("/search")
    public List<ProductSummary> search(
            @RequestParam(required = false, defaultValue = "") String query,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) Long maxPricePaise
    ) {
        return catalogService.search(query, category, maxPricePaise);
    }

    @GetMapping("/categories")
    public List<String> categories() {
        return catalogService.categories();
    }

    @GetMapping("/recommendation-candidates/{productId}")
    public List<ProductSummary> recommendationCandidates(
            @PathVariable UUID productId
    ) {
        return catalogService.recommendationCandidates(productId);
    }
}
