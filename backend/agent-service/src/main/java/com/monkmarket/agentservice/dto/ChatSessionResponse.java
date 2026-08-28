package com.monkmarket.agentservice.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record ChatSessionResponse(

        UUID id,

        UUID userId,

        LocalDateTime createdAt
) {
}