package com.monkmarket.orderservice.guardrail;

import java.util.List;

public record GuardrailResult(
        GuardrailDecision decision,
        String reason,
        List<String> checks
) {
}