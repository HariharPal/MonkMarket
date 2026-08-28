package com.monkmarket.agentservice.dto;

import java.util.UUID;

public record ComplementaryRecommendation(
        String productId,
        String reason
) {
}