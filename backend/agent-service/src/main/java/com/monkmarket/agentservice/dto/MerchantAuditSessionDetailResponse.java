package com.monkmarket.agentservice.dto;

import com.monkmarket.agentservice.model.AgentAuditEvent;
import com.monkmarket.agentservice.model.AgentToolAuditEvent;

import java.util.List;
import java.util.UUID;

public record MerchantAuditSessionDetailResponse(

        UUID sessionId,

        UUID userId,

        List<ChatMessageResponse> messages,

        List<AgentAuditEvent> agentEvents,

        List<AgentToolAuditEvent> toolEvents

) {
}