
package com.monkmarket.auditservice.controller;

import com.monkmarket.auditservice.dto.AuditLogResponse;
import com.monkmarket.auditservice.dto.CreateAuditLogRequest;
import com.monkmarket.auditservice.model.AuditAction;
import com.monkmarket.auditservice.service.AuditService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/audit")
@RequiredArgsConstructor
public class AuditController {

    private final AuditService auditService;

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public AuditLogResponse createLog(
            @Valid
            @RequestBody
            CreateAuditLogRequest request
    ) {

        return auditService.createLog(request);
    }

    @GetMapping("/{id}")
    public AuditLogResponse getLog(
            @PathVariable UUID id
    ) {

        return auditService.getLog(id);
    }

    @GetMapping("/user/{userId}")
    public List<AuditLogResponse> getUserLogs(
            @PathVariable UUID userId
    ) {

        return auditService.getUserLogs(userId);
    }

    @GetMapping("/action/{action}")
    public List<AuditLogResponse> getLogsByAction(
            @PathVariable AuditAction action
    ) {

        return auditService.getLogsByAction(action);
    }

    @GetMapping("/resource/{resourceId}")
    public List<AuditLogResponse> getResourceLogs(
            @PathVariable UUID resourceId
    ) {

        return auditService.getResourceLogs(resourceId);
    }
}