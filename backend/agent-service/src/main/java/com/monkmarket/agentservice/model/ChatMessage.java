package com.monkmarket.agentservice.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(
        name = "chat_messages",
        indexes = {
                @Index(
                        name = "idx_chat_message_session",
                        columnList = "sessionId"
                ),
                @Index(
                        name = "idx_chat_message_request",
                        columnList = "requestId"
                ),
                @Index(
                        name = "idx_chat_message_created",
                        columnList = "createdAt"
                )
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatMessage {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private UUID sessionId;

    @Column
    private UUID requestId;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private MessageRole role;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(length = 100)
    private String toolName;

    @Column(columnDefinition = "TEXT")
    private String toolInput;

    @Column(columnDefinition = "TEXT")
    private String toolOutput;

    @Column(nullable = false)
    private LocalDateTime createdAt;
}