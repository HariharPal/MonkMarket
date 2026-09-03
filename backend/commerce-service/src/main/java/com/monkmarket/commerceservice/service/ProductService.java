package com.monkmarket.commerceservice.service;

import com.monkmarket.commerceservice.dto.ProductRequest;
import com.monkmarket.commerceservice.dto.ProductResponse;
import com.monkmarket.commerceservice.model.Product;
import com.monkmarket.commerceservice.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;

    public ProductResponse create(ProductRequest request) {
        Product product = Product.builder()
                .title(request.title())
                .description(request.description())
                .priceInPaise(request.priceInPaise())
                .currency(request.currency())
                .category(request.category())
                .stockQty(request.stockQty())
                .imageUrl(request.imageUrl())
                .agentVisible(request.agentVisible())
                .build();

        return ProductResponse.from(productRepository.save(product));
    }

    public List<ProductResponse> findAll() {
        return productRepository.findAll()
                .stream()
                .map(ProductResponse::from)
                .toList();
    }

    public ProductResponse findById(UUID id) {
        return ProductResponse.from(findEntity(id));
    }

    public ProductResponse update(UUID id, ProductRequest request) {
        Product product = findEntity(id);
        product.setTitle(request.title());
        product.setDescription(request.description());
        product.setPriceInPaise(request.priceInPaise());
        product.setCurrency(request.currency());
        product.setCategory(request.category());
        product.setStockQty(request.stockQty());
        product.setImageUrl(request.imageUrl());
        product.setAgentVisible(request.agentVisible());
        return ProductResponse.from(productRepository.save(product));
    }

    public void delete(UUID id) {
        productRepository.delete(findEntity(id));
    }

    public Product findEntity(UUID id) {
        return productRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Product not found"));
    }
}
