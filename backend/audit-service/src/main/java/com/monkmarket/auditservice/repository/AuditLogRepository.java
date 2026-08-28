
package com.monkmarket.auditservice.repository;

import com.monkmarket.auditservice.model.AuditAction;
import com.monkmarket.auditservice.model.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface AuditLogRepository
        extends JpaRepository<AuditLog, UUID> {

    List<AuditLog> findByUserIdOrderByCreatedAtDesc(
            UUID userId
    );

    List<AuditLog> findByActionOrderByCreatedAtDesc(
            AuditAction action
    );

    List<AuditLog> findByResourceIdOrderByCreatedAtDesc(
            UUID resourceId
    );
}