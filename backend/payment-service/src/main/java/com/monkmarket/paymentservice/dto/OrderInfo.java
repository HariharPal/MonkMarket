package com.monkmarket.paymentservice.dto;

import java.util.UUID;

public record OrderInfo(

        UUID id,

        UUID userId,

        Long totalAmountInPaise,

        String currency,

        String status

) {
}