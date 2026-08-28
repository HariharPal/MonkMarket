package com.monkmarket.cartservice.dto;

import java.util.UUID;

public record ProductInfo(

        UUID id,

        String title,

        Long priceInPaise,

        String currency,

        Integer stockQty,

        String imageUrl

) {
}