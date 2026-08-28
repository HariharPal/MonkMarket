package com.monkmarket.orderservice.client;

import com.monkmarket.orderservice.dto.CartInfo;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class CartClient {

    private final RestClient restClient;

    public CartInfo getCart(
            UUID userId,
            UUID cartId
    ) {

        return restClient
                .get()
                .uri(
                        "http://localhost:8085/api/v1/cart",
                        cartId
                )
                .header(
                        "X-User-Id",
                        userId.toString()
                )
                .retrieve()
                .body(CartInfo.class);
    }
}