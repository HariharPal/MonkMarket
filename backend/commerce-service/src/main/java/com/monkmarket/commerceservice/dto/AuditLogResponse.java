package com.monkmarket.commerceservice.dto;

import com.monkmarket.commerceservice.model.AuditAction;
import com.monkmarket.commerceservice.model.AuditLog;

import java.time.LocalDateTime;
import java.util.UUID;

public record AuditLogResponse(
        UUID id,
        UUID userId,
        AuditAction action,
        String service,
        String resourceType,
        UUID resourceId,
        String details,
        String ipAddress,
        LocalDateTime createdAt
) {
    public static AuditLogResponse from(AuditLog log) {
        return new AuditLogResponse(
                log.getId(),
                log.getUserId(),
                log.getAction(),
                log.getService(),
                log.getResourceType(),
                log.getResourceId(),
                log.getDetails(),
                log.getIpAddress(),
                log.getCreatedAt()
        );
    }
}
