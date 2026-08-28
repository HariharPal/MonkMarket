
package com.monkmarket.agentservice.dto;

public record ActionDto(

        ActionType type,

        String label,

        ActionPayload payload

) {
}