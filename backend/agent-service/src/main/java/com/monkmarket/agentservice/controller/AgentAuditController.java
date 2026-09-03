package com.monkmarket.agentservice.controller;

import com.monkmarket.agentservice.dto.ChatMessageResponse;
import com.monkmarket.agentservice.dto.MerchantAuditSessionDetailResponse;
import com.monkmarket.agentservice.dto.MerchantAuditSessionResponse;
import com.monkmarket.agentservice.dto.MerchantAuditUserResponse;
import com.monkmarket.agentservice.model.AgentAuditEvent;
import com.monkmarket.agentservice.model.AgentToolAuditEvent;
import com.monkmarket.agentservice.model.ChatMessage;
import com.monkmarket.agentservice.model.ChatSession;
import com.monkmarket.agentservice.repository.AgentAuditEventRepository;
import com.monkmarket.agentservice.repository.AgentToolAuditEventRepository;
import com.monkmarket.agentservice.repository.ChatMessageRepository;
import com.monkmarket.agentservice.repository.ChatSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/v1/agent/audit")
@RequiredArgsConstructor
public class AgentAuditController {

    private final AgentToolAuditEventRepository toolAuditRepository;
    private final AgentAuditEventRepository auditRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final ChatSessionRepository chatSessionRepository;

    @GetMapping("/session/{sessionId}")
    public List<AgentAuditEvent> getSessionAudit(
            @RequestHeader("X-User-Id") UUID userId,
            @PathVariable UUID sessionId
    ) {

        return auditRepository
                .findTop100BySessionIdOrderByCreatedAtDesc(
                        sessionId
                )
                .stream()
                .filter(event ->
                        userId.equals(event.getUserId())
                )
                .toList();
    }

    @GetMapping("/session/{sessionId}/tools")
    public List<AgentToolAuditEvent> getSessionToolAudit(
            @RequestHeader("X-User-Id") UUID userId,
            @PathVariable UUID sessionId
    ) {

        return toolAuditRepository
                .findTop500BySessionIdOrderByCreatedAtDesc(
                        sessionId
                )
                .stream()
                .filter(event ->
                        userId.equals(event.getUserId())
                )
                .toList();
    }

    @GetMapping("/merchant/users")
    public List<MerchantAuditUserResponse> getMerchantUsers() {

        List<ChatSession> sessions =
                chatSessionRepository.findAll();

        Map<UUID, List<ChatSession>> grouped =
                sessions.stream()
                        .collect(
                                Collectors.groupingBy(
                                        ChatSession::getUserId
                                )
                        );

        return grouped.entrySet()
                .stream()
                .map(entry -> {

                    UUID userId =
                            entry.getKey();

                    List<ChatSession> userSessions =
                            entry.getValue();

                    long messageCount =
                            userSessions.stream()
                                    .mapToLong(
                                            session ->
                                                    chatMessageRepository
                                                            .countBySessionId(
                                                                    session.getId()
                                                            )
                                    )
                                    .sum();

                    return new MerchantAuditUserResponse(
                            userId,
                            userSessions.size(),
                            messageCount
                    );
                })
                .toList();
    }

    @GetMapping("/merchant/users/{userId}/sessions")
    public List<MerchantAuditSessionResponse> getUserSessions(
            @PathVariable UUID userId
    ) {

        return chatSessionRepository
                .findByUserIdOrderByUpdatedAtDesc(
                        userId
                )
                .stream()
                .map(session ->
                        new MerchantAuditSessionResponse(
                                session.getId(),
                                session.getUserId(),
                                session.getCreatedAt(),
                                session.getUpdatedAt(),
                                session.getCheckoutState() == null
                                        ? null
                                        : session.getCheckoutState().name(),
                                session.getCheckoutOrderId(),
                                session.getCheckoutPaymentId(),
                                session.getCheckoutRazorpayOrderId()
                        )
                )
                .toList();
    }

    @GetMapping("/merchant/sessions/{sessionId}")
    public MerchantAuditSessionDetailResponse getSessionDetail(
            @PathVariable UUID sessionId
    ) {

        ChatSession session =
                chatSessionRepository
                        .findById(sessionId)
                        .orElseThrow(
                                () -> new IllegalArgumentException(
                                        "Chat session not found"
                                )
                        );

        List<ChatMessageResponse> messages =
                chatMessageRepository
                        .findBySessionIdOrderByCreatedAtAsc(
                                sessionId
                        )
                        .stream()
                        .map(ChatMessageResponse::from)
                        .toList();

        List<AgentAuditEvent> agentEvents =
                auditRepository
                        .findTop100BySessionIdOrderByCreatedAtDesc(
                                sessionId
                        );

        List<AgentToolAuditEvent> toolEvents =
                toolAuditRepository
                        .findTop500BySessionIdOrderByCreatedAtDesc(
                                sessionId
                        );

        return new MerchantAuditSessionDetailResponse(
                session.getId(),
                session.getUserId(),
                messages,
                agentEvents,
                toolEvents
        );
    }
}