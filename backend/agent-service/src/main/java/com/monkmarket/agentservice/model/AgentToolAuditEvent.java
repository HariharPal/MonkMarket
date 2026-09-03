package com.monkmarket.agentservice.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(
        name = "agent_tool_audit_events",
        indexes = {
                @Index(
                        name = "idx_agent_tool_audit_request",
                        columnList = "requestId"
                ),
                @Index(
                        name = "idx_agent_tool_audit_session",
                        columnList = "sessionId"
                ),
                @Index(
                        name = "idx_agent_tool_audit_user",
                        columnList = "userId"
                ),
                @Index(
                        name = "idx_agent_tool_audit_created",
                        columnList = "createdAt"
                )
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AgentToolAuditEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private UUID requestId;

    @Column(nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private UUID sessionId;

    @Column(nullable = false, length = 50)
    private String eventType;

    @Column(nullable = false, length = 150)
    private String operation;

    @Column(length = 50)
    private String targetType;

    @Column(length = 100)
    private String targetName;

    @Column(length = 20)
    private String httpMethod;

    @Column(length = 500)
    private String apiPath;

    @Column(columnDefinition = "TEXT")
    private String inputJson;

    @Column(columnDefinition = "TEXT")
    private String outputJson;

    @Column(nullable = false)
    private Boolean success;

    @Column(length = 255)
    private String errorType;

    @Column(columnDefinition = "TEXT")
    private String errorMessage;

    @Column(nullable = false)
    private Long latencyMs;

    @Column(nullable = false)
    private LocalDateTime createdAt;
}