package com.monkmarket.commerceservice.service;

import com.monkmarket.commerceservice.dto.AuditLogResponse;
import com.monkmarket.commerceservice.dto.CreateAuditLogRequest;
import com.monkmarket.commerceservice.model.AuditAction;
import com.monkmarket.commerceservice.model.AuditLog;
import com.monkmarket.commerceservice.repository.AuditLogRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class AuditService {

    private final AuditLogRepository repository;

    @Transactional(readOnly = true)
    public List<AuditLogResponse> getAllLogs() {
        return repository.findAllByOrderByCreatedAtDesc()
                .stream()
                .map(AuditLogResponse::from)
                .toList();
    }

    public AuditLogResponse create(CreateAuditLogRequest request) {
        AuditLog log = AuditLog.builder()
                .userId(request.userId())
                .action(request.action())
                .service(request.service())
                .resourceType(request.resourceType())
                .resourceId(request.resourceId())
                .details(request.details())
                .ipAddress(request.ipAddress())
                .createdAt(LocalDateTime.now())
                .build();

        return AuditLogResponse.from(repository.save(log));
    }

    @Transactional(readOnly = true)
    public AuditLogResponse get(UUID id) {
        return repository.findById(id)
                .map(AuditLogResponse::from)
                .orElseThrow(() -> new IllegalArgumentException("Audit log not found"));
    }

    @Transactional(readOnly = true)
    public List<AuditLogResponse> getUserLogs(UUID userId) {
        return repository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(AuditLogResponse::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<AuditLogResponse> getLogsByAction(AuditAction action) {
        return repository.findByActionOrderByCreatedAtDesc(action)
                .stream()
                .map(AuditLogResponse::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<AuditLogResponse> getResourceLogs(UUID resourceId) {
        return repository.findByResourceIdOrderByCreatedAtDesc(resourceId)
                .stream()
                .map(AuditLogResponse::from)
                .toList();
    }
}
