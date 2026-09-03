package com.monkmarket.agentservice.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(
        name = "agent_audit_events",
        indexes = {
                @Index(
                        name = "idx_agent_audit_request_id",
                        columnList = "requestId"
                ),
                @Index(
                        name = "idx_agent_audit_session_id",
                        columnList = "sessionId"
                ),
                @Index(
                        name = "idx_agent_audit_user_id",
                        columnList = "userId"
                ),
                @Index(
                        name = "idx_agent_audit_created_at",
                        columnList = "createdAt"
                )
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AgentAuditEvent {

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

    @Column(columnDefinition = "TEXT")
    private String requestMessage;

    @Column(length = 50)
    private String responseType;

    @Column(length = 150)
    private String modelName;

    @Column(columnDefinition = "TEXT")
    private String responseMessage;

    @Column(nullable = false)
    private Integer productCount;

    @Column(nullable = false)
    private Integer recommendationCount;

    @Column(nullable = false)
    private Boolean cartPresent;

    @Column(nullable = false)
    private Boolean checkoutPresent;

    @Column(nullable = false)
    private Integer actionCount;

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