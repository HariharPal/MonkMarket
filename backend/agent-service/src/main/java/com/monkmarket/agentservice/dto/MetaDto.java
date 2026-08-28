
package com.monkmarket.agentservice.dto;

import java.time.LocalDateTime;

public record MetaDto(

        LocalDateTime timestamp,

        boolean requiresConfirmation,

        GuardrailMeta guardrail,

        String errorCode

) {
}