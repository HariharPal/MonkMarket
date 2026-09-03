package com.monkmarket.agentservice.repository;

import com.monkmarket.agentservice.model.ChatMessage;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface ChatMessageRepository
        extends JpaRepository<ChatMessage, UUID> {

    List<ChatMessage> findBySessionIdOrderByCreatedAtAsc(
            UUID sessionId
    );

    List<ChatMessage> findTop20BySessionIdOrderByCreatedAtDesc(
            UUID sessionId
    );


    long countBySessionId(
            UUID sessionId
    );
}