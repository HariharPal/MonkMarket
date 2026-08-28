
package com.monkmarket.auditservice.dto;

import com.monkmarket.auditservice.model.AuditAction;
import com.monkmarket.auditservice.model.AuditLog;

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

    public static AuditLogResponse from(AuditLog auditLog) {

        return new AuditLogResponse(
                auditLog.getId(),
                auditLog.getUserId(),
                auditLog.getAction(),
                auditLog.getService(),
                auditLog.getResourceType(),
                auditLog.getResourceId(),
                auditLog.getDetails(),
                auditLog.getIpAddress(),
                auditLog.getCreatedAt()
        );
    }
}