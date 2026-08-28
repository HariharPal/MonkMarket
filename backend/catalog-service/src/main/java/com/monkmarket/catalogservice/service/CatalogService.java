package com.monkmarket.catalogservice.service;

import com.monkmarket.catalogservice.dto.ProductSummary;
import com.monkmarket.catalogservice.model.Product;
import com.monkmarket.catalogservice.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CatalogService {

    private final ProductRepository productRepository;

    public List<ProductSummary> search(
            String query,
            String category,
            Long maxPricePaise
    ) {

        String cleanQuery =
                query == null
                        ? ""
                        : query.trim();

        String cleanCategory =
                category == null || category.isBlank()
                        ? null
                        : category.trim();

        List<Product> products;

        if (cleanQuery.isBlank()
                && cleanCategory == null
                && maxPricePaise == null) {

            products =
                    productRepository
                            .findByAgentVisibleTrueAndStockQtyGreaterThan(
                                    0
                            );
        }

        else if (cleanQuery.isBlank()
                && cleanCategory != null
                && maxPricePaise != null) {

            products =
                    productRepository
                            .findByAgentVisibleTrueAndStockQtyGreaterThanAndCategoryIgnoreCaseAndPriceInPaiseLessThanEqual(
                                    0,
                                    cleanCategory,
                                    maxPricePaise
                            );
        }

        else if (cleanQuery.isBlank()
                && cleanCategory != null) {

            products =
                    productRepository
                            .findByAgentVisibleTrueAndStockQtyGreaterThanAndCategoryIgnoreCase(
                                    0,
                                    cleanCategory
                            );
        }

        else if (cleanQuery.isBlank()
                && maxPricePaise != null) {

            products =
                    productRepository
                            .findByAgentVisibleTrueAndStockQtyGreaterThanAndPriceInPaiseLessThanEqual(
                                    0,
                                    maxPricePaise
                            );
        }

        else if (cleanCategory != null
                && maxPricePaise != null) {

            products =
                    productRepository
                            .searchByQueryCategoryAndMaxPrice(
                                    cleanQuery,
                                    cleanCategory,
                                    maxPricePaise
                            );
        }

        else if (cleanCategory != null) {

            products =
                    productRepository
                            .searchByQueryAndCategory(
                                    cleanQuery,
                                    cleanCategory
                            );
        }

        else if (maxPricePaise != null) {

            products =
                    productRepository
                            .searchByQueryAndMaxPrice(
                                    cleanQuery,
                                    maxPricePaise
                            );
        }

        else {

            products =
                    productRepository
                            .searchByQuery(
                                    cleanQuery
                            );
        }

        return products
                .stream()
                .limit(5)
                .map(ProductSummary::from)
                .toList();
    }

    public List<String> getAvailableCategories() {

        return productRepository
                .findAvailableCategories();
    }

    public List<ProductSummary> getRecommendationCandidates(
            UUID productId
    ) {

        return productRepository
                .findTop20ByAgentVisibleTrueAndStockQtyGreaterThanAndIdNotOrderByPriceInPaiseAsc(
                        0,
                        productId
                )
                .stream()
                .map(ProductSummary::from)
                .toList();
    }
}