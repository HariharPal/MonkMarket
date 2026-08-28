package com.monkmarket.agentservice.guardrail;

import java.util.List;

public record GuardrailResult(
        GuardrailDecision decision,
        String reason,
        List<String> checks
) {
}