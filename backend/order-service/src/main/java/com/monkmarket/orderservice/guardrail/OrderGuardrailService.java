package com.monkmarket.orderservice.guardrail;

import com.monkmarket.orderservice.dto.MerchantPolicyResponse;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class OrderGuardrailService {

    public GuardrailResult evaluate(
            long totalAmount,
            MerchantPolicyResponse policy,
            boolean humanConfirmed
    ) {

        List<String> checks =
                new ArrayList<>();

        if (!policy.agentEnabled()) {

            return new GuardrailResult(
                    GuardrailDecision.BLOCKED,
                    "AI checkout is disabled.",
                    checks
            );
        }

        checks.add(
                "agentEnabled=PASS"
        );

        if (policy.maxOrderAmountInPaise() != null
                && totalAmount
                > policy.maxOrderAmountInPaise()) {

            checks.add(
                    "maxOrderAmount=FAIL"
            );

            return new GuardrailResult(
                    GuardrailDecision.BLOCKED,
                    "Order exceeds the merchant's maximum allowed amount.",
                    checks
            );
        }

        checks.add(
                "maxOrderAmount=PASS"
        );

        if (policy.humanConfirmAboveAmountInPaise() != null
                && totalAmount
                > policy.humanConfirmAboveAmountInPaise()) {

            if (!humanConfirmed) {

                checks.add(
                        "humanConfirmation=REQUIRED"
                );

                return new GuardrailResult(
                        GuardrailDecision.NEEDS_CONFIRMATION,
                        "Human confirmation is required before checkout.",
                        checks
                );
            }

            checks.add(
                    "humanConfirmation=PASS"
            );
        }

        return new GuardrailResult(
                GuardrailDecision.ALLOWED,
                "Checkout allowed.",
                checks
        );
    }
}