package com.monkmarket.paymentservice.dto;

import java.util.UUID;

public record PaymentOrderResponse(

        UUID paymentId,

        UUID orderId,

        String razorpayOrderId,

        Long amountInPaise,

        String currency,

        PaymentStatus status

) {
}