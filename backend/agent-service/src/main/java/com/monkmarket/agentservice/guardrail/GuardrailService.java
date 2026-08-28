package com.monkmarket.agentservice.guardrail;

import com.monkmarket.agentservice.dto.CheckoutProposal;
import com.monkmarket.agentservice.dto.MerchantPolicyResponse;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class GuardrailService {

    public GuardrailResult evaluate(
            CheckoutProposal checkout,
            MerchantPolicyResponse policy
    ) {

        List<String> checks = new ArrayList<>();

        // 1. Agent enabled
        if (!policy.agentEnabled()) {

            checks.add("agentEnabled=FAIL");

            return new GuardrailResult(
                    GuardrailDecision.BLOCKED,
                    "Agent checkout is disabled by the merchant.",
                    checks
            );
        }

        checks.add("agentEnabled=PASS");

        // 2. Maximum order amount
        long total = checkout.totalAmountInPaise();

        if (total > policy.maxOrderAmountInPaise()) {

            checks.add("maxOrderAmount=FAIL");

            return new GuardrailResult(
                    GuardrailDecision.BLOCKED,
                    "Order amount exceeds the merchant's maximum allowed amount.",
                    checks
            );
        }

        checks.add("maxOrderAmount=PASS");

        // 3. Human confirmation threshold
        if (total > policy.humanConfirmAboveAmountInPaise()) {

            checks.add("humanConfirmation=REQUIRED");

            return new GuardrailResult(
                    GuardrailDecision.NEEDS_CONFIRMATION,
                    "Human confirmation is required before checkout.",
                    checks
            );
        }

        checks.add("humanConfirmation=NOT_REQUIRED");

        // 4. Passed current checks
        return new GuardrailResult(
                GuardrailDecision.ALLOWED,
                "Checkout passed the current guardrail checks.",
                checks
        );
    }
}