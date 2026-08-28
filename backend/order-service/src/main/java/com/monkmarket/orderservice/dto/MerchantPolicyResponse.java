package com.monkmarket.orderservice.dto;

import java.util.List;
import java.util.UUID;

public record MerchantPolicyResponse(
        UUID id,
        Long maxOrderAmountInPaise,
        List<String> allowedCategories,
        Integer upsellMaxItems,
        Long humanConfirmAboveAmountInPaise,
        boolean agentEnabled
) {
}