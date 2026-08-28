package com.monkmarket.catalogservice.repository;

import com.monkmarket.catalogservice.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface ProductRepository
        extends JpaRepository<Product, UUID> {

    List<Product>
    findByAgentVisibleTrueAndStockQtyGreaterThan(
            Integer stockQty
    );

    @Query("""
        SELECT p
        FROM Product p
        WHERE p.agentVisible = true
          AND p.stockQty > 0
          AND (
                LOWER(p.title)
                    LIKE LOWER(CONCAT('%', :query, '%'))
                OR
                LOWER(p.description)
                    LIKE LOWER(CONCAT('%', :query, '%'))
              )
        ORDER BY p.priceInPaise ASC
    """)
    List<Product> searchByQuery(
            @Param("query")
            String query
    );

    @Query("""
        SELECT p
        FROM Product p
        WHERE p.agentVisible = true
          AND p.stockQty > 0
          AND (
                LOWER(p.title)
                    LIKE LOWER(CONCAT('%', :query, '%'))
                OR
                LOWER(p.description)
                    LIKE LOWER(CONCAT('%', :query, '%'))
              )
          AND UPPER(p.category) = UPPER(:category)
        ORDER BY p.priceInPaise ASC
    """)
    List<Product> searchByQueryAndCategory(
            @Param("query")
            String query,

            @Param("category")
            String category
    );

    @Query("""
        SELECT p
        FROM Product p
        WHERE p.agentVisible = true
          AND p.stockQty > 0
          AND (
                LOWER(p.title)
                    LIKE LOWER(CONCAT('%', :query, '%'))
                OR
                LOWER(p.description)
                    LIKE LOWER(CONCAT('%', :query, '%'))
              )
          AND p.priceInPaise <= :maxPricePaise
        ORDER BY p.priceInPaise ASC
    """)
    List<Product> searchByQueryAndMaxPrice(
            @Param("query")
            String query,

            @Param("maxPricePaise")
            Long maxPricePaise
    );

    @Query("""
        SELECT p
        FROM Product p
        WHERE p.agentVisible = true
          AND p.stockQty > 0
          AND (
                LOWER(p.title)
                    LIKE LOWER(CONCAT('%', :query, '%'))
                OR
                LOWER(p.description)
                    LIKE LOWER(CONCAT('%', :query, '%'))
              )
          AND UPPER(p.category) = UPPER(:category)
          AND p.priceInPaise <= :maxPricePaise
        ORDER BY p.priceInPaise ASC
    """)
    List<Product> searchByQueryCategoryAndMaxPrice(
            @Param("query")
            String query,

            @Param("category")
            String category,

            @Param("maxPricePaise")
            Long maxPricePaise
    );

    List<Product>
    findByAgentVisibleTrueAndStockQtyGreaterThanAndCategoryIgnoreCase(
            Integer stockQty,
            String category
    );

    List<Product>
    findByAgentVisibleTrueAndStockQtyGreaterThanAndCategoryIgnoreCaseAndPriceInPaiseLessThanEqual(
            Integer stockQty,
            String category,
            Long maxPricePaise
    );

    List<Product>
    findByAgentVisibleTrueAndStockQtyGreaterThanAndPriceInPaiseLessThanEqual(
            Integer stockQty,
            Long maxPricePaise
    );

    @Query("""
        SELECT DISTINCT p.category
        FROM Product p
        WHERE p.agentVisible = true
          AND p.stockQty > 0
        ORDER BY p.category
    """)
    List<String> findAvailableCategories();

    List<Product>
    findTop20ByAgentVisibleTrueAndStockQtyGreaterThanAndIdNotOrderByPriceInPaiseAsc(
            Integer stockQty,
            UUID productId
    );
}