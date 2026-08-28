package com.monkmarket.agentservice.dto;

import java.util.List;
import java.util.UUID;

public record CheckoutProposal(
        UUID cartId,
        Long totalAmountInPaise,
        List<CheckoutItem> items
) {
}