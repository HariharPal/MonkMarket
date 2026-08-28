package com.monkmarket.agentservice.repository;

import com.monkmarket.agentservice.model.ChatSession;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ChatSessionRepository
        extends JpaRepository<ChatSession, UUID> {

    List<ChatSession> findByUserIdOrderByUpdatedAtDesc(UUID userId);

    Optional<ChatSession> findByIdAndUserId(
            UUID sessionId,
            UUID userId
    );
}