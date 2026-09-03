package com.monkmarket.commerceservice.dto;

import com.monkmarket.commerceservice.model.Order;
import com.monkmarket.commerceservice.model.PaymentStatus;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public record MerchantOrderResponse(

        UUID id,

        UUID userId,

        UUID cartId,

        Long totalAmountInPaise,

        String currency,

        String status,

        PaymentStatus paymentStatus,

        UUID paymentId,

        String razorpayOrderId,

        String razorpayPaymentId,

        List<OrderItemResponse> items,

        LocalDateTime createdAt,

        LocalDateTime updatedAt

) {
}