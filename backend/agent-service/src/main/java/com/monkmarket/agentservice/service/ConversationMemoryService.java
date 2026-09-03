package com.monkmarket.agentservice.service;

import com.monkmarket.agentservice.model.ChatMessage;
import com.monkmarket.agentservice.model.MessageRole;
import com.monkmarket.agentservice.repository.ChatMessageRepository;
import com.monkmarket.agentservice.repository.ChatSessionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import tools.jackson.databind.ObjectMapper;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class ConversationMemoryService {

    private final ChatMessageRepository chatMessageRepository;
    private final ChatSessionRepository chatSessionRepository;
    private final ObjectMapper objectMapper;

    public List<ChatMessage> getRecentMessages(UUID sessionId, int limit) {

        List<ChatMessage> messages =
                chatMessageRepository
                        .findTop20BySessionIdOrderByCreatedAtDesc(sessionId);

        Collections.reverse(messages);

        return messages;
    }

    public void saveUserMessage(
            UUID sessionId,
            String content
    ) {

        chatMessageRepository.save(
                ChatMessage.builder()
                        .sessionId(sessionId)
                        .role(MessageRole.USER)
                        .content(content)
                        .createdAt(LocalDateTime.now())
                        .build()
        );
    }

    public void saveAssistantMessage(
            UUID sessionId,
            String content
    ) {

        chatMessageRepository.save(
                ChatMessage.builder()
                        .sessionId(sessionId)
                        .role(MessageRole.ASSISTANT)
                        .content(content)
                        .createdAt(LocalDateTime.now())
                        .build()
        );
    }

    public void saveToolMessage(
            UUID sessionId,
            String toolName,
            String input,
            String output
    ) {

        chatMessageRepository.save(
                ChatMessage.builder()
                        .sessionId(sessionId)
                        .role(MessageRole.TOOL)
                        .content(output)
                        .toolName(toolName)
                        .toolInput(input)
                        .toolOutput(output)
                        .createdAt(LocalDateTime.now())
                        .build()
        );
    }
}