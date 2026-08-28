package com.monkmarket.paymentservice.service;

import com.monkmarket.paymentservice.client.OrderClient;
import com.monkmarket.paymentservice.dto.OrderInfo;
import com.monkmarket.paymentservice.dto.PaymentOrderResponse;
import com.monkmarket.paymentservice.dto.PaymentStatus;
import com.monkmarket.paymentservice.dto.PaymentVerificationRequest;
import com.monkmarket.paymentservice.model.Payment;
import com.monkmarket.paymentservice.repository.PaymentRepository;
import com.razorpay.Order;
import com.razorpay.RazorpayClient;
import com.razorpay.Utils;
import lombok.RequiredArgsConstructor;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class PaymentService {

    @Value("${razorpay.key-secret}")
    private String razorpayKeySecret;

    private final RazorpayClient razorpayClient;
    private final OrderClient orderClient;
    private final PaymentRepository paymentRepository;

    public PaymentOrderResponse createPaymentOrder(
            UUID userId,
            UUID orderId
    ) throws Exception {

        OrderInfo order = orderClient.getOrder(
                userId,
                orderId
        );

        if (!order.userId().equals(userId)) {

            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Order does not belong to this user"
            );
        }

        Payment existingPayment = paymentRepository
                .findByOrderId(orderId)
                .orElse(null);

        if (existingPayment != null) {

            if (existingPayment.getStatus() == PaymentStatus.VERIFIED
                    || existingPayment.getStatus() == PaymentStatus.PAID) {

                return buildResponse(existingPayment);
            }

            if (existingPayment.getStatus() == PaymentStatus.EXPIRED) {

                throw new ResponseStatusException(
                        HttpStatus.GONE,
                        "Payment session has expired"
                );
            }

            if (existingPayment.getExpiresAt() != null
                    && LocalDateTime.now()
                    .isAfter(existingPayment.getExpiresAt())) {

                existingPayment.setStatus(
                        PaymentStatus.EXPIRED
                );

                existingPayment.setUpdatedAt(
                        LocalDateTime.now()
                );

                paymentRepository.save(existingPayment);

                throw new ResponseStatusException(
                        HttpStatus.GONE,
                        "Payment session has expired"
                );
            }

            if (existingPayment.getStatus() == PaymentStatus.CREATED) {

                return buildResponse(existingPayment);
            }

            if (existingPayment.getStatus() == PaymentStatus.FAILED) {

                throw new ResponseStatusException(
                        HttpStatus.BAD_REQUEST,
                        "Previous payment attempt failed"
                );
            }
        }

        JSONObject options = new JSONObject();

        options.put(
                "amount",
                order.totalAmountInPaise()
        );

        options.put(
                "currency",
                order.currency()
        );

        options.put(
                "receipt",
                "order_" + orderId
        );

        Order razorpayOrder =
                razorpayClient.orders.create(options);

        LocalDateTime now = LocalDateTime.now();

        Payment payment = Payment.builder()
                .orderId(orderId)
                .userId(userId)
                .amountInPaise(
                        order.totalAmountInPaise()
                )
                .currency(
                        order.currency()
                )
                .status(
                        PaymentStatus.CREATED
                )
                .razorpayOrderId(
                        razorpayOrder.get("id")
                )
                .createdAt(now)
                .updatedAt(now)
                .expiresAt(
                        now.plusMinutes(15)
                )
                .build();

        Payment savedPayment =
                paymentRepository.save(payment);

        return buildResponse(savedPayment);
    }

    public String verifyPayment(
            UUID userId,
            PaymentVerificationRequest request
    ) {

        Payment payment = paymentRepository
                .findByOrderId(request.orderId())
                .orElseThrow(() ->
                        new ResponseStatusException(
                                HttpStatus.NOT_FOUND,
                                "Payment record not found"
                        )
                );

        if (!payment.getUserId().equals(userId)) {

            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Payment does not belong to this user"
            );
        }

        if (payment.getStatus() == PaymentStatus.VERIFIED
                || payment.getStatus() == PaymentStatus.PAID) {

            return "Payment already verified";
        }

        if (payment.getStatus() == PaymentStatus.EXPIRED) {

            throw new ResponseStatusException(
                    HttpStatus.GONE,
                    "Payment session has expired"
            );
        }

        if (payment.getExpiresAt() != null
                && LocalDateTime.now()
                .isAfter(payment.getExpiresAt())) {

            payment.setStatus(
                    PaymentStatus.EXPIRED
            );

            payment.setUpdatedAt(
                    LocalDateTime.now()
            );

            paymentRepository.save(payment);

            throw new ResponseStatusException(
                    HttpStatus.GONE,
                    "Payment session has expired"
            );
        }

        String razorpayOrderId =
                payment.getRazorpayOrderId();

        if (razorpayOrderId == null
                || razorpayOrderId.isBlank()) {

            throw new ResponseStatusException(
                    HttpStatus.INTERNAL_SERVER_ERROR,
                    "Razorpay order ID missing"
            );
        }

        JSONObject options = new JSONObject();

        options.put(
                "razorpay_order_id",
                razorpayOrderId
        );

        options.put(
                "razorpay_payment_id",
                request.razorpayPaymentId()
        );

        options.put(
                "razorpay_signature",
                request.razorpaySignature()
        );

        boolean valid;

        try {

            valid = Utils.verifyPaymentSignature(
                    options,
                    razorpayKeySecret
            );

        } catch (Exception e) {

            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Unable to verify payment signature"
            );
        }

        if (!valid) {

            payment.setStatus(
                    PaymentStatus.FAILED
            );

            payment.setUpdatedAt(
                    LocalDateTime.now()
            );

            paymentRepository.save(payment);

            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Invalid payment signature"
            );
        }

        payment.setRazorpayPaymentId(
                request.razorpayPaymentId()
        );

        payment.setRazorpaySignature(
                request.razorpaySignature()
        );

        payment.setStatus(
                PaymentStatus.VERIFIED
        );

        payment.setUpdatedAt(
                LocalDateTime.now()
        );

        paymentRepository.save(payment);

        orderClient.markOrderPaid(
                userId,
                payment.getOrderId()
        );

        return "Payment signature verified successfully";
    }

    private PaymentOrderResponse buildResponse(
            Payment payment
    ) {

        return new PaymentOrderResponse(
                payment.getId(),
                payment.getOrderId(),
                payment.getRazorpayOrderId(),
                payment.getAmountInPaise(),
                payment.getCurrency(),
                payment.getStatus()
        );
    }
}