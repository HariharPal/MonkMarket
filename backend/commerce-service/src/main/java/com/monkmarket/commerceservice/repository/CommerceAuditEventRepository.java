package com.monkmarket.commerceservice.repository;

import com.monkmarket.commerceservice.model.CommerceAuditEvent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface CommerceAuditEventRepository
        extends JpaRepository<CommerceAuditEvent, UUID> {

    List<CommerceAuditEvent>
    findTop100ByOrderIdOrderByCreatedAtDesc(UUID orderId);

    List<CommerceAuditEvent>
    findTop100ByPaymentIdOrderByCreatedAtDesc(UUID paymentId);

    List<CommerceAuditEvent>
    findTop100ByUserIdOrderByCreatedAtDesc(UUID userId);
}