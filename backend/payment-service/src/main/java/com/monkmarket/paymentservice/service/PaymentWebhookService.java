package com.monkmarket.paymentservice.service;

import com.monkmarket.paymentservice.client.OrderClient;
import com.monkmarket.paymentservice.dto.PaymentStatus;
import com.monkmarket.paymentservice.model.Payment;
import com.monkmarket.paymentservice.repository.PaymentRepository;
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
    private final OrderClient orderClient;

    @Value("${razorpay.webhook-secret}")
    private String webhookSecret;

    @Transactional
    public void process(
            String rawBody,
            String signature
    ) {

        try {

            Utils.verifyWebhookSignature(
                    rawBody,
                    signature,
                    webhookSecret
            );

        } catch (Exception e) {

            throw new IllegalArgumentException(
                    "Invalid Razorpay webhook signature",
                    e
            );
        }

        JSONObject event =
                new JSONObject(rawBody);

        String eventName =
                event.optString("event");

        switch (eventName) {

            case "payment.captured" ->
                    handlePaymentCaptured(event);

            case "payment.failed" ->
                    handlePaymentFailed(event);

            case "order.paid" ->
                    handleOrderPaid(event);

            default ->
                    System.out.println(
                            "Ignoring Razorpay event: "
                                    + eventName
                    );
        }
    }

    private void handlePaymentCaptured(
            JSONObject event
    ) {

        JSONObject paymentEntity =
                event
                        .getJSONObject("payload")
                        .getJSONObject("payment")
                        .getJSONObject("entity");

        String razorpayOrderId =
                paymentEntity.getString("order_id");

        String razorpayPaymentId =
                paymentEntity.getString("id");

        Payment payment =
                paymentRepository
                        .findByRazorpayOrderId(
                                razorpayOrderId
                        )
                        .orElse(null);

        if (payment == null) {

            System.out.println(
                    "Payment not found for Razorpay order: "
                            + razorpayOrderId
            );

            return;
        }

        if (PaymentStatus.PAID.equals(
                payment.getStatus()
        )) {
            return;
        }

        if (PaymentStatus.EXPIRED.equals(
                payment.getStatus()
        )) {
            return;
        }

        payment.setRazorpayPaymentId(
                razorpayPaymentId
        );

        payment.setStatus(
                PaymentStatus.PAID
        );

        payment.setUpdatedAt(
                LocalDateTime.now()
        );

        paymentRepository.save(payment);

        orderClient.markOrderPaid(
                payment.getUserId(),
                payment.getOrderId()
        );
    }

    private void handlePaymentFailed(
            JSONObject event
    ) {

        JSONObject paymentEntity =
                event
                        .getJSONObject("payload")
                        .getJSONObject("payment")
                        .getJSONObject("entity");

        String razorpayOrderId =
                paymentEntity.getString("order_id");

        String razorpayPaymentId =
                paymentEntity.getString("id");

        Payment payment =
                paymentRepository
                        .findByRazorpayOrderId(
                                razorpayOrderId
                        )
                        .orElse(null);

        if (payment == null) {
            return;
        }

        if (PaymentStatus.PAID.equals(
                payment.getStatus()
        )) {
            return;
        }

        payment.setRazorpayPaymentId(
                razorpayPaymentId
        );

        payment.setStatus(
                PaymentStatus.FAILED
        );

        payment.setUpdatedAt(
                LocalDateTime.now()
        );

        paymentRepository.save(payment);
    }

    private void handleOrderPaid(
            JSONObject event
    ) {

        JSONObject orderEntity =
                event
                        .getJSONObject("payload")
                        .getJSONObject("order")
                        .getJSONObject("entity");

        String razorpayOrderId =
                orderEntity.getString("id");

        Payment payment =
                paymentRepository
                        .findByRazorpayOrderId(
                                razorpayOrderId
                        )
                        .orElse(null);

        if (payment == null) {
            return;
        }

        if (PaymentStatus.PAID.equals(
                payment.getStatus()
        )) {
            return;
        }

        if (PaymentStatus.EXPIRED.equals(
                payment.getStatus()
        )) {
            return;
        }

        payment.setStatus(
                PaymentStatus.PAID
        );

        payment.setUpdatedAt(
                LocalDateTime.now()
        );

        paymentRepository.save(payment);

        orderClient.markOrderPaid(
                payment.getUserId(),
                payment.getOrderId()
        );
    }
}