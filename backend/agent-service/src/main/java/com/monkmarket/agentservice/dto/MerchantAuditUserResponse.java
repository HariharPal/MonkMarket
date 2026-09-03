package com.monkmarket.agentservice.dto;

import java.util.UUID;

public record MerchantAuditUserResponse(
        UUID userId,
        int sessionCount,
        long messageCount
) {
}