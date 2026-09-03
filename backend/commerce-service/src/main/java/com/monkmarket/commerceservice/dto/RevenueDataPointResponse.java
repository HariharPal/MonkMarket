package com.monkmarket.commerceservice.dto;

import java.time.LocalDate;

public record RevenueDataPointResponse(
        LocalDate date,
        long revenueInPaise
) {
}