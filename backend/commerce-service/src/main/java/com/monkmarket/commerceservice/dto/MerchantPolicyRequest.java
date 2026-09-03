package com.monkmarket.commerceservice.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.util.List;

public record MerchantPolicyRequest(
        @NotNull @Min(1) Long maxOrderAmountInPaise,
        @NotEmpty List<String> allowedCategories,
        @NotNull @Min(0) Integer upsellMaxItems,
        @NotNull @Min(1) Long humanConfirmAboveAmountInPaise,
        boolean agentEnabled
) {
}
