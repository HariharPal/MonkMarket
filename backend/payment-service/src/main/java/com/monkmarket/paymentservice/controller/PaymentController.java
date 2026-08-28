package com.monkmarket.paymentservice.controller;

import com.monkmarket.paymentservice.dto.CreatePaymentRequest;
import com.monkmarket.paymentservice.dto.PaymentOrderResponse;
import com.monkmarket.paymentservice.dto.PaymentVerificationRequest;
import com.monkmarket.paymentservice.service.PaymentService;
import com.monkmarket.paymentservice.service.PaymentWebhookService;
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

    @PostMapping("/webhook")
    public ResponseEntity<Void> webhook(
            @RequestHeader("X-Razorpay-Signature")
            String signature,

            @RequestBody
            String rawBody
    ) {

        paymentWebhookService.process(
                rawBody,
                signature
        );

        return ResponseEntity.ok().build();
    }

    @PostMapping("/orders")
    public PaymentOrderResponse createPaymentOrder(

            @RequestHeader("X-User-Id")
            UUID userId,

            @Valid
            @RequestBody
            CreatePaymentRequest request

    ) throws Exception {

        return paymentService.createPaymentOrder(
                userId,
                request.orderId()
        );
    }

    @PostMapping("/verify")
    public String verifyPayment(
            @RequestHeader("X-User-Id")
            UUID userId,

            @RequestBody
            PaymentVerificationRequest request
    ) {

        return paymentService.verifyPayment(
                userId,
                request
        );
    }
}