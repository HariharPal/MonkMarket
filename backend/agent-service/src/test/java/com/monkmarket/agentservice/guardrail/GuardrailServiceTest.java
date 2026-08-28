package com.monkmarket.agentservice.guardrail;

import com.monkmarket.agentservice.dto.CheckoutItem;
import com.monkmarket.agentservice.dto.CheckoutProposal;
import com.monkmarket.agentservice.dto.MerchantPolicyResponse;
import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.*;

class GuardrailServiceTest {

    private final GuardrailService guardrailService =
            new GuardrailService();

    private MerchantPolicyResponse policy() {
        return new MerchantPolicyResponse(
                UUID.randomUUID(),
                500000L, // ₹5000 max
                List.of("SHOES", "ACCESSORIES", "ELECTRONICS", "STATIONERY"),
                1,
                200000L, // ₹2000 confirmation threshold
                true
        );
    }

    private CheckoutProposal checkout(long totalInPaise) {

        CheckoutItem item = new CheckoutItem(
                UUID.randomUUID(),
                "Test Product",
                1,
                totalInPaise,
                totalInPaise
        );

        return new CheckoutProposal(
                UUID.randomUUID(),
                totalInPaise,
                List.of(item)
        );
    }

    @Test
    void shouldAllowOrderBelowConfirmationThreshold() {

        GuardrailResult result =
                guardrailService.evaluate(
                        checkout(150000L), // ₹1500
                        policy()
                );

        assertEquals(
                GuardrailDecision.ALLOWED,
                result.decision()
        );
    }

    @Test
    void shouldRequireConfirmationAboveThreshold() {

        GuardrailResult result =
                guardrailService.evaluate(
                        checkout(300000L), // ₹3000
                        policy()
                );

        assertEquals(
                GuardrailDecision.NEEDS_CONFIRMATION,
                result.decision()
        );
    }

    @Test
    void shouldBlockOrderAboveMaximum() {

        GuardrailResult result =
                guardrailService.evaluate(
                        checkout(600000L), // ₹6000
                        policy()
                );

        assertEquals(
                GuardrailDecision.BLOCKED,
                result.decision()
        );
    }

    @Test
    void shouldBlockWhenAgentDisabled() {

        MerchantPolicyResponse disabledPolicy =
                new MerchantPolicyResponse(
                        UUID.randomUUID(),
                        500000L,
                        List.of("SHOES", "ACCESSORIES"),
                        1,
                        200000L,
                        false
                );

        GuardrailResult result =
                guardrailService.evaluate(
                        checkout(100000L),
                        disabledPolicy
                );

        assertEquals(
                GuardrailDecision.BLOCKED,
                result.decision()
        );
    }
}