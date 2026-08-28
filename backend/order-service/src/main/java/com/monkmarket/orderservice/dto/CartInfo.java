package com.monkmarket.orderservice.dto;

import java.util.List;
import java.util.UUID;

public record CartInfo(

        UUID id,

        UUID userId,

        String status,

        List<CartItemInfo> items,

        Long totalAmountInPaise

) {
}