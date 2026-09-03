package com.monkmarket.agentservice.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record MerchantAuditSessionResponse(
        UUID sessionId,
        UUID userId,
        LocalDateTime createdAt,
        LocalDateTime updatedAt,
        String checkoutState,
        UUID checkoutOrderId,
        UUID checkoutPaymentId,
        String checkoutRazorpayOrderId
) {
}