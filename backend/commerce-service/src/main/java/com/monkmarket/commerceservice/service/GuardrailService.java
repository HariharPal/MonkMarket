package com.monkmarket.commerceservice.service;

import com.monkmarket.commerceservice.dto.MerchantPolicyResponse;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class GuardrailService {

    public GuardrailResult evaluate(
            long totalAmount,
            MerchantPolicyResponse policy,
            List<String> categories,
            boolean humanConfirmed
    ) {
        List<String> checks = new ArrayList<>();

        if (!policy.agentEnabled()) {
            checks.add("agentEnabled=FAIL");
            return new GuardrailResult(
                    Decision.BLOCKED,
                    "AI checkout is disabled.",
                    checks
            );
        }

        checks.add("agentEnabled=PASS");

        if (policy.maxOrderAmountInPaise() != null
                && totalAmount > policy.maxOrderAmountInPaise()) {
            checks.add("maxOrderAmount=FAIL");
            return new GuardrailResult(
                    Decision.BLOCKED,
                    "Order exceeds the merchant's maximum allowed amount.",
                    checks
            );
        }

        checks.add("maxOrderAmount=PASS");

        if (policy.allowedCategories() != null
                && !policy.allowedCategories().isEmpty()) {
            for (String category : categories) {
                boolean allowed = policy.allowedCategories()
                        .stream()
                        .anyMatch(value -> value.equalsIgnoreCase(category));

                if (!allowed) {
                    checks.add("categoryAllowList=FAIL");
                    return new GuardrailResult(
                            Decision.BLOCKED,
                            "Product category '" + category + "' is not allowed.",
                            checks
                    );
                }
            }
        }

        checks.add("categoryAllowList=PASS");

        if (policy.humanConfirmAboveAmountInPaise() != null
                && totalAmount > policy.humanConfirmAboveAmountInPaise()) {

            if (!humanConfirmed) {
                checks.add("humanConfirmation=REQUIRED");
                return new GuardrailResult(
                        Decision.NEEDS_CONFIRMATION,
                        "Human confirmation is required before checkout.",
                        checks
                );
            }

            checks.add("humanConfirmation=PASS");
        }

        return new GuardrailResult(
                Decision.ALLOWED,
                "Checkout allowed.",
                checks
        );
    }

    public enum Decision {
        ALLOWED,
        NEEDS_CONFIRMATION,
        BLOCKED
    }

    public record GuardrailResult(
            Decision decision,
            String reason,
            List<String> checks
    ) {
    }
}
