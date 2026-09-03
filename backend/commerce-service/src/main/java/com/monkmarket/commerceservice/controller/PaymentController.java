package com.monkmarket.commerceservice.controller;
import com.monkmarket.commerceservice.dto.PaymentVerificationResponse;
import com.monkmarket.commerceservice.dto.CreatePaymentRequest;
import com.monkmarket.commerceservice.dto.PaymentOrderResponse;
import com.monkmarket.commerceservice.dto.PaymentVerificationRequest;
import com.monkmarket.commerceservice.service.PaymentService;
import com.monkmarket.commerceservice.service.PaymentWebhookService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;
    private final PaymentWebhookService paymentWebhookService;

    @PostMapping("/orders")
    public PaymentOrderResponse createPaymentOrder(
            @RequestHeader("X-User-Id") UUID userId,
            @Valid @RequestBody CreatePaymentRequest request
    ) throws Exception {
        return paymentService.createPaymentOrder(userId, request.orderId());
    }

    @PostMapping("/verify")
    public PaymentVerificationResponse  verifyPayment(
            @RequestHeader("X-User-Id") UUID userId,
            @Valid @RequestBody PaymentVerificationRequest request
    ) {
        return paymentService.verifyPayment(userId, request);
    }

    @PostMapping("/webhook")
    public ResponseEntity<Void> webhook(
            @RequestHeader("X-Razorpay-Signature") String signature,
            @RequestHeader("x-razorpay-event-id") String eventId,
            @RequestBody String rawBody
    ) {
        paymentWebhookService.process(
                rawBody,
                signature,
                eventId
        );

        return ResponseEntity.ok().build();
    }
}
