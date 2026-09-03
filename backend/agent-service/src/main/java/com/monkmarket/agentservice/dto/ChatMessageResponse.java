package com.monkmarket.agentservice.dto;

import com.monkmarket.agentservice.model.ChatMessage;
import com.monkmarket.agentservice.model.MessageRole;

import java.time.LocalDateTime;
import java.util.UUID;

public record ChatMessageResponse(

        UUID id,

        UUID requestId,

        MessageRole role,

        String content,

        String toolName,

        String toolInput,

        String toolOutput,

        LocalDateTime createdAt

) {

    public static ChatMessageResponse from(
            ChatMessage message
    ) {

        return new ChatMessageResponse(
                message.getId(),
                message.getRequestId(),
                message.getRole(),
                message.getContent(),
                message.getToolName(),
                message.getToolInput(),
                message.getToolOutput(),
                message.getCreatedAt()
        );
    }
}