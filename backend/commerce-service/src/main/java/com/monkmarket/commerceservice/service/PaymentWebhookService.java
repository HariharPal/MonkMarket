package com.monkmarket.commerceservice.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.monkmarket.commerceservice.dto.CreateAuditLogRequest;
import com.monkmarket.commerceservice.model.AuditAction;
import com.monkmarket.commerceservice.model.Payment;
import com.monkmarket.commerceservice.model.PaymentStatus;
import com.monkmarket.commerceservice.model.ProcessedWebhookEvent;
import com.monkmarket.commerceservice.repository.PaymentRepository;
import com.monkmarket.commerceservice.repository.ProcessedWebhookEventRepository;
import com.razorpay.Utils;
import lombok.RequiredArgsConstructor;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class PaymentWebhookService {

    private final PaymentRepository paymentRepository;
    private final ProcessedWebhookEventRepository processedWebhookEventRepository;
    private final OrderService orderService;
    private final AuditService auditService;
    private final CommerceAuditService commerceAuditService;
    private final ObjectMapper objectMapper;

    @Value("${razorpay.webhook-secret:}")
    private String webhookSecret;

    @Transactional
    public void process(
            String rawBody,
            String signature,
            String eventId
    ) {

        long start = System.nanoTime();

        String eventName = null;

        try {

            try {
                Utils.verifyWebhookSignature(
                        rawBody,
                        signature,
                        webhookSecret
                );
            } catch (Exception e) {

                commerceAuditService.record(
                        null,
                        null,
                        null,
                        "WEBHOOK_SIGNATURE_FAILED",
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        false,
                        "Invalid Razorpay webhook signature",
                        e,
                        elapsedMs(start)
                );

                throw new IllegalArgumentException(
                        "Invalid Razorpay webhook signature"
                );
            }

            JSONObject event = new JSONObject(rawBody);

            eventName = event.optString(
                    "event",
                    null
            );

            if (eventId == null || eventId.isBlank()) {
                throw new IllegalArgumentException(
                        "Razorpay webhook event ID header is missing"
                );
            }

            if (eventName == null || eventName.isBlank()) {
                throw new IllegalArgumentException(
                        "Webhook event type is missing"
                );
            }

            if (processedWebhookEventRepository
                    .existsByEventId(eventId)) {

                commerceAuditService.record(
                        null,
                        null,
                        null,
                        "WEBHOOK_DUPLICATE",
                        null,
                        null,
                        null,
                        null,
                        null,
                        null,
                        true,
                        "Webhook event already processed: " + eventId,
                        null,
                        elapsedMs(start)
                );

                return;
            }

            switch (eventName) {

                case "payment.captured" ->
                        handlePaymentCaptured(event);

                case "payment.failed" ->
                        handlePaymentFailed(event);

                case "order.paid" ->
                        handleOrderPaid(event);

                default -> {
                    commerceAuditService.record(
                            null,
                            null,
                            null,
                            "WEBHOOK_IGNORED",
                            null,
                            null,
                            null,
                            null,
                            null,
                            null,
                            true,
                            "Unsupported webhook event: " + eventName,
                            null,
                            elapsedMs(start)
                    );
                }
            }

            ProcessedWebhookEvent processed =
                    ProcessedWebhookEvent.builder()
                            .eventId(eventId)
                            .eventType(eventName)
                            .processedAt(LocalDateTime.now())
                            .build();

            processedWebhookEventRepository.save(processed);

            commerceAuditService.record(
                    null,
                    null,
                    null,
                    "WEBHOOK_PROCESSED",
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    true,
                    "Webhook processed: " + eventName,
                    null,
                    elapsedMs(start)
            );

        } catch (Exception e) {

            commerceAuditService.record(
                    null,
                    null,
                    null,
                    "WEBHOOK_FAILED",
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    false,
                    eventName == null
                            ? "Webhook processing failed"
                            : "Webhook processing failed: " + eventName,
                    e,
                    elapsedMs(start)
            );

            throw e;
        }
    }

    private void handlePaymentCaptured(
            JSONObject event
    ) {

        JSONObject paymentEntity =
                event.getJSONObject("payload")
                        .getJSONObject("payment")
                        .getJSONObject("entity");

        String razorpayOrderId =
                paymentEntity.getString("order_id");

        String razorpayPaymentId =
                paymentEntity.getString("id");

        Payment payment =
                paymentRepository
                        .findByRazorpayOrderId(razorpayOrderId)
                        .orElse(null);

        if (payment == null) {

            commerceAuditService.record(
                    null,
                    null,
                    null,
                    "PAYMENT_CAPTURED_UNKNOWN_ORDER",
                    null,
                    null,
                    null,
                    null,
                    razorpayOrderId,
                    razorpayPaymentId,
                    true,
                    "No local payment found",
                    null,
                    0
            );

            return;
        }

        if (payment.getStatus() == PaymentStatus.PAID) {

            commerceAuditService.success(
                    payment.getUserId(),
                    payment.getOrderId(),
                    payment.getId(),
                    "WEBHOOK_PAYMENT_ALREADY_PAID",
                    PaymentStatus.PAID.name(),
                    PaymentStatus.PAID.name(),
                    payment.getAmountInPaise(),
                    payment.getCurrency(),
                    payment.getRazorpayOrderId(),
                    payment.getRazorpayPaymentId(),
                    "Payment was already marked PAID",
                    0
            );

            return;
        }

        if (payment.getStatus() == PaymentStatus.EXPIRED) {

            commerceAuditService.success(
                    payment.getUserId(),
                    payment.getOrderId(),
                    payment.getId(),
                    "WEBHOOK_PAYMENT_EXPIRED_IGNORED",
                    PaymentStatus.EXPIRED.name(),
                    PaymentStatus.EXPIRED.name(),
                    payment.getAmountInPaise(),
                    payment.getCurrency(),
                    payment.getRazorpayOrderId(),
                    razorpayPaymentId,
                    "Expired payment ignored",
                    0
            );

            return;
        }

        PaymentStatus oldStatus = payment.getStatus();

        payment.setRazorpayPaymentId(razorpayPaymentId);
        payment.setStatus(PaymentStatus.PAID);
        payment.setUpdatedAt(LocalDateTime.now());

        paymentRepository.save(payment);

        commerceAuditService.success(
                payment.getUserId(),
                payment.getOrderId(),
                payment.getId(),
                "WEBHOOK_PAYMENT_CAPTURED",
                oldStatus.name(),
                PaymentStatus.PAID.name(),
                payment.getAmountInPaise(),
                payment.getCurrency(),
                payment.getRazorpayOrderId(),
                payment.getRazorpayPaymentId(),
                "Razorpay payment captured",
                0
        );

        orderService.markOrderPaid(
                payment.getUserId(),
                payment.getOrderId()
        );

        auditService.create(
                new CreateAuditLogRequest(
                        payment.getUserId(),
                        AuditAction.PAYMENT_COMPLETED,
                        "commerce-service",
                        "PAYMENT",
                        payment.getId(),
                        "Razorpay payment captured",
                        null
                )
        );
    }

    private void handlePaymentFailed(
            JSONObject event
    ) {

        JSONObject paymentEntity =
                event.getJSONObject("payload")
                        .getJSONObject("payment")
                        .getJSONObject("entity");

        String razorpayOrderId =
                paymentEntity.getString("order_id");

        String razorpayPaymentId =
                paymentEntity.getString("id");

        Payment payment =
                paymentRepository
                        .findByRazorpayOrderId(razorpayOrderId)
                        .orElse(null);

        if (payment == null) {
            return;
        }

        if (payment.getStatus() == PaymentStatus.PAID) {

            commerceAuditService.success(
                    payment.getUserId(),
                    payment.getOrderId(),
                    payment.getId(),
                    "WEBHOOK_PAYMENT_FAILED_IGNORED",
                    PaymentStatus.PAID.name(),
                    PaymentStatus.PAID.name(),
                    payment.getAmountInPaise(),
                    payment.getCurrency(),
                    payment.getRazorpayOrderId(),
                    razorpayPaymentId,
                    "Failed webhook ignored because payment is already PAID",
                    0
            );

            return;
        }

        PaymentStatus oldStatus = payment.getStatus();

        payment.setRazorpayPaymentId(razorpayPaymentId);
        payment.setStatus(PaymentStatus.FAILED);
        payment.setUpdatedAt(LocalDateTime.now());

        paymentRepository.save(payment);

        commerceAuditService.success(
                payment.getUserId(),
                payment.getOrderId(),
                payment.getId(),
                "WEBHOOK_PAYMENT_FAILED",
                oldStatus.name(),
                PaymentStatus.FAILED.name(),
                payment.getAmountInPaise(),
                payment.getCurrency(),
                payment.getRazorpayOrderId(),
                payment.getRazorpayPaymentId(),
                "Razorpay payment failed",
                0
        );

        auditService.create(
                new CreateAuditLogRequest(
                        payment.getUserId(),
                        AuditAction.PAYMENT_FAILED,
                        "commerce-service",
                        "PAYMENT",
                        payment.getId(),
                        "Razorpay payment failed",
                        null
                )
        );
    }

    private void handleOrderPaid(
            JSONObject event
    ) {

        JSONObject orderEntity =
                event.getJSONObject("payload")
                        .getJSONObject("order")
                        .getJSONObject("entity");

        String razorpayOrderId =
                orderEntity.getString("id");

        Payment payment =
                paymentRepository
                        .findByRazorpayOrderId(razorpayOrderId)
                        .orElse(null);

        if (payment == null) {
            return;
        }

        if (payment.getStatus() == PaymentStatus.PAID) {

            commerceAuditService.success(
                    payment.getUserId(),
                    payment.getOrderId(),
                    payment.getId(),
                    "WEBHOOK_ORDER_ALREADY_PAID",
                    PaymentStatus.PAID.name(),
                    PaymentStatus.PAID.name(),
                    payment.getAmountInPaise(),
                    payment.getCurrency(),
                    payment.getRazorpayOrderId(),
                    payment.getRazorpayPaymentId(),
                    "Order paid event arrived after payment was already marked PAID",
                    0
            );

            return;
        }

        PaymentStatus oldStatus = payment.getStatus();

        payment.setStatus(PaymentStatus.PAID);
        payment.setUpdatedAt(LocalDateTime.now());

        paymentRepository.save(payment);

        commerceAuditService.success(
                payment.getUserId(),
                payment.getOrderId(),
                payment.getId(),
                "WEBHOOK_ORDER_PAID",
                oldStatus.name(),
                PaymentStatus.PAID.name(),
                payment.getAmountInPaise(),
                payment.getCurrency(),
                payment.getRazorpayOrderId(),
                payment.getRazorpayPaymentId(),
                "Razorpay order marked paid",
                0
        );

        orderService.markOrderPaid(
                payment.getUserId(),
                payment.getOrderId()
        );
    }

    private long elapsedMs(long start) {
        return (
                System.nanoTime() - start
        ) / 1_000_000;
    }
}