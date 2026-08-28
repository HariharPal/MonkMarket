// service/AuditService.java

package com.monkmarket.auditservice.service;

import com.monkmarket.auditservice.dto.AuditLogResponse;
import com.monkmarket.auditservice.dto.CreateAuditLogRequest;
import com.monkmarket.auditservice.utils.AuditLogNotFoundException;
import com.monkmarket.auditservice.model.AuditAction;
import com.monkmarket.auditservice.model.AuditLog;
import com.monkmarket.auditservice.repository.AuditLogRepository;
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

    private final AuditLogRepository auditLogRepository;

    public AuditLogResponse createLog(
            CreateAuditLogRequest request
    ) {

        AuditLog auditLog =
                AuditLog.builder()
                        .userId(request.userId())
                        .action(request.action())
                        .service(request.service())
                        .resourceType(request.resourceType())
                        .resourceId(request.resourceId())
                        .details(request.details())
                        .ipAddress(request.ipAddress())
                        .createdAt(LocalDateTime.now())
                        .build();

        AuditLog savedLog =
                auditLogRepository.save(auditLog);

        return AuditLogResponse.from(savedLog);
    }

    @Transactional(readOnly = true)
    public AuditLogResponse getLog(UUID id) {

        AuditLog auditLog =
                auditLogRepository.findById(id)
                        .orElseThrow(
                                () -> new AuditLogNotFoundException(
                                        "Audit log not found"
                                )
                        );

        return AuditLogResponse.from(auditLog);
    }

    @Transactional(readOnly = true)
    public List<AuditLogResponse> getUserLogs(
            UUID userId
    ) {

        return auditLogRepository
                .findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(AuditLogResponse::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<AuditLogResponse> getLogsByAction(
            AuditAction action
    ) {

        return auditLogRepository
                .findByActionOrderByCreatedAtDesc(action)
                .stream()
                .map(AuditLogResponse::from)
                .toList();
    }

    @Transactional(readOnly = true)
    public List<AuditLogResponse> getResourceLogs(
            UUID resourceId
    ) {

        return auditLogRepository
                .findByResourceIdOrderByCreatedAtDesc(resourceId)
                .stream()
                .map(AuditLogResponse::from)
                .toList();
    }
}