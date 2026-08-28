package com.monkmarket.cartservice.client;

import com.monkmarket.cartservice.dto.ProductInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class CatalogClient {

    private final RestClient restClient;

    public ProductInfo getProduct(UUID productId) {

        return restClient
                .get()
                .uri(
                        "http://localhost:8080/api/v1/catalog/products/{id}",
                        productId
                )
                .retrieve()
                .body(ProductInfo.class);
    }
}