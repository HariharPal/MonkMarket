package com.monkmarket.catalogservice.service;

import com.monkmarket.catalogservice.dto.*;
import com.monkmarket.catalogservice.utils.ProductNotFoundException;
import com.monkmarket.catalogservice.model.Product;
import com.monkmarket.catalogservice.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ProductService {

    private final ProductRepository productRepository;


    public ProductResponse createProduct(
            CreateProductRequest request
    ) {

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

        productRepository.save(product);

        return ProductResponse.from(product);
    }


    public List<ProductResponse> getAllProducts() {

        return productRepository.findAll()
                .stream()
                .map(ProductResponse::from)
                .toList();
    }


    public ProductResponse getProductById(
            UUID id
    ) {

        Product product = productRepository
                .findById(id)
                .orElseThrow(
                        () -> new ProductNotFoundException(
                                "Product not found"
                        )
                );

        return ProductResponse.from(product);
    }


    public ProductResponse updateProduct(
            UUID id,
            UpdateProductRequest request
    ) {

        Product product = productRepository
                .findById(id)
                .orElseThrow(
                        () -> new ProductNotFoundException(
                                "Product not found"
                        )
                );

        product.setTitle(request.title());

        product.setDescription(request.description());

        product.setPriceInPaise(
                request.priceInPaise()
        );

        product.setCurrency(
                request.currency()
        );

        product.setCategory(
                request.category()
        );

        product.setStockQty(
                request.stockQty()
        );

        product.setImageUrl(
                request.imageUrl()
        );

        product.setAgentVisible(
                request.agentVisible()
        );

        productRepository.save(product);

        return ProductResponse.from(product);
    }


    public void deleteProduct(UUID id) {

        Product product = productRepository
                .findById(id)
                .orElseThrow(
                        () -> new ProductNotFoundException(
                                "Product not found"
                        )
                );

        productRepository.delete(product);
    }
}