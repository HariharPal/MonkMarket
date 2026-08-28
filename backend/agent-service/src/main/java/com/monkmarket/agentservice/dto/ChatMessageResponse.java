
package com.monkmarket.agentservice.dto;

import com.monkmarket.agentservice.model.ChatMessage;
import com.monkmarket.agentservice.model.MessageRole;

import java.time.LocalDateTime;
import java.util.UUID;

public record ChatMessageResponse(

        UUID id,

        MessageRole role,

        String content,

        LocalDateTime createdAt

) {

    public static ChatMessageResponse from(
            ChatMessage message
    ) {

        return new ChatMessageResponse(
                message.getId(),
                message.getRole(),
                message.getContent(),
                message.getCreatedAt()
        );
    }
}