package com.monkmarket.agentservice.repository;

import com.monkmarket.agentservice.model.AgentToolAuditEvent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface AgentToolAuditEventRepository
        extends JpaRepository<AgentToolAuditEvent, UUID> {

    List<AgentToolAuditEvent>
    findTop200ByRequestIdOrderByCreatedAtAsc(
            UUID requestId
    );

    List<AgentToolAuditEvent>
    findTop500BySessionIdOrderByCreatedAtDesc(
            UUID sessionId
    );

    List<AgentToolAuditEvent>
    findTop500ByUserIdOrderByCreatedAtDesc(
            UUID userId
    );
}