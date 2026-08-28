
package com.monkmarket.agentservice.service;

import com.monkmarket.agentservice.dto.AgentChatResponse;
import com.monkmarket.agentservice.dto.MetaDto;

import java.time.LocalDateTime;

public final class AgentResponseFactory {

    private AgentResponseFactory() {
    }

    public static MetaDto meta() {

        return new MetaDto(
                LocalDateTime.now(),
                false,
                null,
                null
        );
    }

    public static MetaDto confirmationMeta() {

        return new MetaDto(
                LocalDateTime.now(),
                true,
                null,
                null
        );
    }
}