package com.monkmarket.commerceservice.repository;

import com.monkmarket.commerceservice.model.AuditAction;
import com.monkmarket.commerceservice.model.AuditLog;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface AuditLogRepository extends JpaRepository<AuditLog, UUID> {

    List<AuditLog> findAllByOrderByCreatedAtDesc();

    List<AuditLog> findByUserIdOrderByCreatedAtDesc(UUID userId);

    List<AuditLog> findByActionOrderByCreatedAtDesc(AuditAction action);

    List<AuditLog> findByResourceIdOrderByCreatedAtDesc(UUID resourceId);
}
