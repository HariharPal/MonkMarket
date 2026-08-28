package com.monkmarket.agentservice.client;

import com.monkmarket.agentservice.dto.ProductSummary;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.Arrays;
import java.util.List;
import java.util.UUID;

@Component
@RequiredArgsConstructor
public class CatalogClient {

    private final RestClient restClient;

    public List<String> getAvailableCategories() {

        String[] categories =
                restClient
                        .get()
                        .uri(
                                "http://localhost:8082/api/v1/catalog/categories"
                        )
                        .retrieve()
                        .body(String[].class);

        if (categories == null) {
            return List.of();
        }

        return Arrays.asList(categories);
    }

    public List<ProductSummary> getRecommendationCandidates(
            UUID productId
    ) {

        ProductSummary[] products =
                restClient
                        .get()
                        .uri(
                                "http://localhost:8082/api/v1/catalog/recommendation-candidates/{productId}",
                                productId
                        )
                        .retrieve()
                        .body(ProductSummary[].class);

        if (products == null) {
            return List.of();
        }

        return Arrays.asList(products);
    }

    public List<ProductSummary> search(
            String query,
            String category,
            Long maxPricePaise
    ) {

        ProductSummary[] products = restClient
                .get()
                .uri(uriBuilder -> {

                    uriBuilder
                            .scheme("http")
                            .host("localhost")
                            .port(8082)
                            .path("/api/v1/catalog/search")
                            .queryParam("query", query);

                    if (category != null && !category.isBlank()) {
                        uriBuilder.queryParam(
                                "category",
                                category
                        );
                    }

                    if (maxPricePaise != null) {
                        uriBuilder.queryParam(
                                "maxPricePaise",
                                maxPricePaise
                        );
                    }

                    return uriBuilder.build();
                })
                .retrieve()
                .body(ProductSummary[].class);

        if (products == null) {
            return List.of();
        }

        return Arrays.asList(products);
    }

    public ProductSummary getProduct(
            UUID productId
    ) {

        return restClient
                .get()
                .uri(
                        "http://localhost:8082/api/v1/catalog/products/{productId}",
                        productId
                )
                .retrieve()
                .body(ProductSummary.class);
    }
}