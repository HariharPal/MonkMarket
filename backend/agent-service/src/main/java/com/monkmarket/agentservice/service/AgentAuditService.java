package com.monkmarket.agentservice.service;

import com.monkmarket.agentservice.dto.AgentChatResponse;
import com.monkmarket.agentservice.model.AgentAuditEvent;
import com.monkmarket.agentservice.repository.AgentAuditEventRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.beans.factory.annotation.Value;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AgentAuditService {

    private final AgentAuditEventRepository repository;
    @Value("${spring.ai.google.genai.chat.model:unknown}")
    private String modelName;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void recordSuccess(
            UUID requestId,
            UUID userId,
            UUID sessionId,
            String requestMessage,
            AgentChatResponse response,
            long latencyMs
    ) {

        repository.save(
                AgentAuditEvent.builder()
                        .requestId(requestId)
                        .userId(userId)
                        .sessionId(sessionId)
                        .eventType("AGENT_RESPONSE")
                        .requestMessage(requestMessage)
                        .responseType(
                                response == null || response.type() == null
                                        ? null
                                        : response.type().name()
                        ).modelName(modelName)
                        .responseMessage(
                                response == null
                                        ? null
                                        : response.response()
                        )
                        .productCount(
                                response == null
                                        || response.products() == null
                                        ? 0
                                        : response.products().size()
                        )
                        .recommendationCount(
                                response == null
                                        || response.recommendations() == null
                                        ? 0
                                        : response.recommendations().size()
                        )
                        .cartPresent(
                                response != null
                                        && response.cart() != null
                        )
                        .checkoutPresent(
                                response != null
                                        && response.checkout() != null
                        )
                        .actionCount(
                                response == null
                                        || response.actions() == null
                                        ? 0
                                        : response.actions().size()
                        )
                        .success(true)
                        .latencyMs(latencyMs)
                        .createdAt(LocalDateTime.now())
                        .build()
        );
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void recordFailure(
            UUID requestId,
            UUID userId,
            UUID sessionId,
            String requestMessage,
            Exception exception,
            long latencyMs
    ) {

        repository.save(
                AgentAuditEvent.builder()
                        .requestId(requestId)
                        .userId(userId)
                        .sessionId(sessionId)
                        .eventType("AGENT_ERROR")
                        .requestMessage(requestMessage)
                        .responseType(null)
                        .responseMessage(null)
                        .productCount(0)
                        .recommendationCount(0)
                        .cartPresent(false)
                        .checkoutPresent(false)
                        .actionCount(0)
                        .success(false)
                        .errorType(
                                exception.getClass().getName()
                        )
                        .errorMessage(
                                exception.getMessage()
                        )
                        .latencyMs(latencyMs)
                        .createdAt(LocalDateTime.now())
                        .build()
        );
    }
}