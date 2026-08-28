
package com.monkmarket.auditservice.dto;

import com.monkmarket.auditservice.model.AuditAction;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public record CreateAuditLogRequest(

        UUID userId,

        @NotNull
        AuditAction action,

        @NotBlank
        String service,

        String resourceType,

        UUID resourceId,

        String details,

        String ipAddress

) {
}