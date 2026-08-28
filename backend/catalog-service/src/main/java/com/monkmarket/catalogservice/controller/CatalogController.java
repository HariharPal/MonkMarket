package com.monkmarket.catalogservice.controller;

import com.monkmarket.catalogservice.dto.ProductSummary;
import com.monkmarket.catalogservice.service.CatalogService;
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
            @RequestParam(
                    required = false,
                    defaultValue = ""
            )
            String query,

            @RequestParam(
                    required = false
            )
            String category,

            @RequestParam(
                    required = false
            )
            Long maxPricePaise
    ) {

        return catalogService.search(
                query,
                category,
                maxPricePaise
        );
    }


    @GetMapping("/categories")
    public List<String> getAvailableCategories() {

        return catalogService.getAvailableCategories();
    }


    @GetMapping(
            "/recommendation-candidates/{productId}"
    )
    public List<ProductSummary> getRecommendationCandidates(
            @PathVariable UUID productId
    ) {

        return catalogService.getRecommendationCandidates(
                productId
        );
    }
}