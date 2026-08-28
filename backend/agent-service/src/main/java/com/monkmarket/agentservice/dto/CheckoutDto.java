

package com.monkmarket.agentservice.dto;

import java.time.LocalDateTime;
import java.util.UUID;

public record CheckoutDto(

        UUID orderId,

        UUID paymentId,

        String razorpayOrderId,

        Long amountInPaise,

        String currency,

        String paymentStatus,

        LocalDateTime expiresAt

) {
}