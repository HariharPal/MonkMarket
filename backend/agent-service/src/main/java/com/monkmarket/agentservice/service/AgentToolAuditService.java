package com.monkmarket.agentservice.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.monkmarket.agentservice.model.AgentToolAuditEvent;
import com.monkmarket.agentservice.repository.AgentToolAuditEventRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AgentToolAuditService {

    private final AgentToolAuditEventRepository repository;
    private final ObjectMapper objectMapper;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void recordSuccess(
            UUID requestId,
            UUID userId,
            UUID sessionId,
            String eventType,
            String operation,
            String targetType,
            String targetName,
            String httpMethod,
            String apiPath,
            Object input,
            Object output,
            long latencyMs
    ) {

        repository.save(
                AgentToolAuditEvent.builder()
                        .requestId(requestId)
                        .userId(userId)
                        .sessionId(sessionId)
                        .eventType(eventType)
                        .operation(operation)
                        .targetType(targetType)
                        .targetName(targetName)
                        .httpMethod(httpMethod)
                        .apiPath(apiPath)
                        .inputJson(toJson(input))
                        .outputJson(toJson(output))
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
            String eventType,
            String operation,
            String targetType,
            String targetName,
            String httpMethod,
            String apiPath,
            Object input,
            Throwable throwable,
            long latencyMs
    ) {

        repository.save(
                AgentToolAuditEvent.builder()
                        .requestId(requestId)
                        .userId(userId)
                        .sessionId(sessionId)
                        .eventType(eventType)
                        .operation(operation)
                        .targetType(targetType)
                        .targetName(targetName)
                        .httpMethod(httpMethod)
                        .apiPath(apiPath)
                        .inputJson(toJson(input))
                        .outputJson(null)
                        .success(false)
                        .errorType(
                                throwable == null
                                        ? null
                                        : throwable.getClass().getName()
                        )
                        .errorMessage(
                                throwable == null
                                        ? null
                                        : throwable.getMessage()
                        )
                        .latencyMs(latencyMs)
                        .createdAt(LocalDateTime.now())
                        .build()
        );
    }

    private String toJson(Object value) {

        if (value == null) {
            return null;
        }

        try {
            return objectMapper.writeValueAsString(value);
        } catch (Exception e) {
            return String.valueOf(value);
        }
    }
}