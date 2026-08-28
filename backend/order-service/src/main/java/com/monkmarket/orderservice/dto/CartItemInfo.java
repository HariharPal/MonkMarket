
package com.monkmarket.orderservice.dto;

import java.util.UUID;

public record CartItemInfo(

        UUID id,

        UUID productId,

        String productName,

        Long priceSnapshotInPaise,

        Integer quantity,

        Long totalPriceInPaise,

        String imageUrl

) {
}