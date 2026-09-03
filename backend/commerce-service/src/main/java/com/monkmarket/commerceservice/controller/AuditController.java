package com.monkmarket.commerceservice.controller;

import com.monkmarket.commerceservice.dto.AuditLogResponse;
import com.monkmarket.commerceservice.dto.CreateAuditLogRequest;
import com.monkmarket.commerceservice.model.AuditAction;
import com.monkmarket.commerceservice.service.AuditService;
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

    @PostMapping("/events")
    @ResponseStatus(HttpStatus.CREATED)
    public AuditLogResponse create(
            @Valid @RequestBody CreateAuditLogRequest request
    ) {
        return auditService.create(request);
    }

    @GetMapping("/{id}")
    public AuditLogResponse get(@PathVariable UUID id) {
        return auditService.get(id);
    }

    @GetMapping("/user/{userId}")
    public List<AuditLogResponse> getUserLogs(@PathVariable UUID userId) {
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
