package com.monkmarket.agentservice.repository;

import com.monkmarket.agentservice.model.AgentAuditEvent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface AgentAuditEventRepository
        extends JpaRepository<AgentAuditEvent, UUID> {

    List<AgentAuditEvent>
    findTop100BySessionIdOrderByCreatedAtDesc(
            UUID sessionId
    );

    List<AgentAuditEvent>
    findTop100ByUserIdOrderByCreatedAtDesc(
            UUID userId
    );
}