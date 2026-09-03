package com.monkmarket.commerceservice.service;

import com.monkmarket.commerceservice.model.CommerceAuditEvent;
import com.monkmarket.commerceservice.repository.CommerceAuditEventRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CommerceAuditService {

    private final CommerceAuditEventRepository repository;

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void record(
            UUID userId,
            UUID orderId,
            UUID paymentId,
            String operation,
            String oldState,
            String newState,
            Long amountInPaise,
            String currency,
            String razorpayOrderId,
            String razorpayPaymentId,
            boolean success,
            String message,
            Exception exception,
            long latencyMs
    ) {

        repository.save(
                CommerceAuditEvent.builder()
                        .userId(userId)
                        .orderId(orderId)
                        .paymentId(paymentId)
                        .operation(operation)
                        .oldState(oldState)
                        .newState(newState)
                        .amountInPaise(amountInPaise)
                        .currency(currency)
                        .razorpayOrderId(razorpayOrderId)
                        .razorpayPaymentId(razorpayPaymentId)
                        .success(success)
                        .message(message)
                        .errorType(
                                exception == null
                                        ? null
                                        : exception.getClass().getName()
                        )
                        .errorMessage(
                                exception == null
                                        ? null
                                        : exception.getMessage()
                        )
                        .latencyMs(latencyMs)
                        .createdAt(LocalDateTime.now())
                        .build()
        );
    }

    public void success(
            UUID userId,
            UUID orderId,
            UUID paymentId,
            String operation,
            String oldState,
            String newState,
            Long amountInPaise,
            String currency,
            String razorpayOrderId,
            String razorpayPaymentId,
            String message,
            long latencyMs
    ) {
        record(
                userId,
                orderId,
                paymentId,
                operation,
                oldState,
                newState,
                amountInPaise,
                currency,
                razorpayOrderId,
                razorpayPaymentId,
                true,
                message,
                null,
                latencyMs
        );
    }

    public void failure(
            UUID userId,
            UUID orderId,
            UUID paymentId,
            String operation,
            Exception exception,
            long latencyMs
    ) {
        record(
                userId,
                orderId,
                paymentId,
                operation,
                null,
                null,
                null,
                null,
                null,
                null,
                false,
                null,
                exception,
                latencyMs
        );
    }
}