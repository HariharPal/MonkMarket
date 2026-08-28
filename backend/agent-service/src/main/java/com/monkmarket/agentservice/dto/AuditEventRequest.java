package com.monkmarket.agentservice.dto;

import java.util.UUID;

public record AuditEventRequest(
        UUID userId,
        String eventType,
        String entityType,
        UUID entityId,
        String message
) {
}