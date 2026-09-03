package com.monkmarket.commerceservice.service;

import com.monkmarket.commerceservice.dto.*;
import com.monkmarket.commerceservice.model.AuditAction;
import com.monkmarket.commerceservice.model.OrderStatus;
import com.monkmarket.commerceservice.model.Payment;
import com.monkmarket.commerceservice.model.PaymentStatus;
import com.monkmarket.commerceservice.repository.PaymentRepository;
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

    private final CommerceAuditService commerceAuditService;

    private final PaymentRepository paymentRepository;
    private final OrderService orderService;
    private final AuditService auditService;

    @Value("${razorpay.key-secret:}")
    private String razorpayKeySecret;

    private final RazorpayClient razorpayClient;

    public PaymentOrderResponse createPaymentOrder(
            UUID userId,
            UUID orderId
    ) throws Exception {

        com.monkmarket.commerceservice.model.Order order = orderService.getEntity(orderId);

        if (!order.getUserId().equals(userId)) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Order does not belong to this user"
            );
        }


        if (order.getStatus() != OrderStatus.PAYMENT_PENDING) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Order cannot be paid in its current state"
            );
        }

        Payment existing = paymentRepository.findByOrderId(orderId).orElse(null);

        if (existing != null) {
            if (existing.getStatus() == PaymentStatus.PAID) {
                return toResponse(existing);
            }

            if (existing.getStatus() == PaymentStatus.EXPIRED) {
                throw new ResponseStatusException(
                        HttpStatus.GONE,
                        "Payment session has expired"
                );
            }

            if (existing.getExpiresAt() != null
                    && LocalDateTime.now().isAfter(existing.getExpiresAt())) {
                existing.setStatus(PaymentStatus.EXPIRED);
                existing.setUpdatedAt(LocalDateTime.now());
                paymentRepository.save(existing);

                throw new ResponseStatusException(
                        HttpStatus.GONE,
                        "Payment session has expired"
                );
            }

            if (existing.getStatus() == PaymentStatus.CREATED) {
                return toResponse(existing);
            }

            if (existing.getStatus() == PaymentStatus.FAILED) {
                // Allow the user to retry payment for the same order.
                // Create a fresh Razorpay order for the new payment attempt.

                JSONObject retryOptions = new JSONObject();
                retryOptions.put("amount", order.getTotalAmountInPaise());
                retryOptions.put("currency", order.getCurrency());
                retryOptions.put("receipt", "order_" + orderId + "_retry");

                Order razorpayRetryOrder =
                        razorpayClient.orders.create(retryOptions);

                LocalDateTime now = LocalDateTime.now();

                existing.setStatus(PaymentStatus.CREATED);
                existing.setRazorpayOrderId(
                        razorpayRetryOrder.get("id")
                );
                existing.setRazorpayPaymentId(null);
                existing.setRazorpaySignature(null);
                existing.setCreatedAt(now);
                existing.setUpdatedAt(now);
                existing.setExpiresAt(now.plusMinutes(15));

                Payment retriedPayment =
                        paymentRepository.save(existing);

                auditService.create(new CreateAuditLogRequest(
                        userId,
                        com.monkmarket.commerceservice.model.AuditAction.PAYMENT_STARTED,
                        "commerce-service",
                        "PAYMENT",
                        retriedPayment.getId(),
                        "Payment retry started for order=" + orderId,
                        null
                ));

                return toResponse(retriedPayment);
            }
        }

        if (razorpayClient == null) {
            throw new ResponseStatusException(
                    HttpStatus.SERVICE_UNAVAILABLE,
                    "Razorpay is not configured"
            );
        }

        JSONObject options = new JSONObject();
        options.put("amount", order.getTotalAmountInPaise());
        options.put("currency", order.getCurrency());
        options.put("receipt", "order_" + orderId);

        Order razorpayOrder = razorpayClient.orders.create(options);

        LocalDateTime now = LocalDateTime.now();

        Payment payment = Payment.builder()
                .orderId(orderId)
                .userId(userId)
                .amountInPaise(order.getTotalAmountInPaise())
                .currency(order.getCurrency())
                .status(PaymentStatus.CREATED)
                .razorpayOrderId(razorpayOrder.get("id"))
                .createdAt(now)
                .updatedAt(now)
                .expiresAt(now.plusMinutes(15))
                .build();

        Payment saved = paymentRepository.save(payment);

        auditService.create(new CreateAuditLogRequest(
                userId,
                com.monkmarket.commerceservice.model.AuditAction.PAYMENT_STARTED,
                "commerce-service",
                "PAYMENT",
                saved.getId(),
                "Payment started for order=" + orderId,
                null
        ));

        return toResponse(saved);
    }

    public PaymentVerificationResponse  verifyPayment(
            UUID userId,
            PaymentVerificationRequest request
    ) {

        Payment payment = paymentRepository.findByOrderId(request.orderId())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Payment record not found"
                ));

        if (!payment.getUserId().equals(userId)) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "Payment does not belong to this user"
            );
        }



        if (payment.getStatus() == PaymentStatus.PAID) {

            com.monkmarket.commerceservice.model.Order order =
                    orderService.getEntity(payment.getOrderId());

            return new PaymentVerificationResponse(
                    true,
                    "Payment already completed",
                    payment.getOrderId(),
                    payment.getId(),
                    payment.getStatus().name(),
                    order.getStatus().name()
            );
        }

        if (payment.getStatus() == PaymentStatus.EXPIRED) {
            throw new ResponseStatusException(
                    HttpStatus.GONE,
                    "Payment session has expired"
            );
        }

        if (payment.getExpiresAt() != null
                && LocalDateTime.now().isAfter(payment.getExpiresAt())) {
            payment.setStatus(PaymentStatus.EXPIRED);
            payment.setUpdatedAt(LocalDateTime.now());
            paymentRepository.save(payment);

            throw new ResponseStatusException(
                    HttpStatus.GONE,
                    "Payment session has expired"
            );
        }

        JSONObject options = new JSONObject();
        options.put("razorpay_order_id", payment.getRazorpayOrderId());
        options.put("razorpay_payment_id", request.razorpayPaymentId());
        options.put("razorpay_signature", request.razorpaySignature());

        boolean valid;

        try {
            valid = Utils.verifyPaymentSignature(options, razorpayKeySecret);
        } catch (Exception e) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Unable to verify payment signature"
            );
        }

        if (!valid) {
            payment.setStatus(PaymentStatus.FAILED);
            payment.setUpdatedAt(LocalDateTime.now());
            paymentRepository.save(payment);

            auditService.create(new CreateAuditLogRequest(
                    userId,
                    com.monkmarket.commerceservice.model.AuditAction.PAYMENT_FAILED,
                    "commerce-service",
                    "PAYMENT",
                    payment.getId(),
                    "Invalid payment signature",
                    null
            ));

            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Invalid payment signature"
            );
        }

        payment.setRazorpayPaymentId(request.razorpayPaymentId());
        payment.setRazorpaySignature(request.razorpaySignature());
        payment.setStatus(PaymentStatus.PAID);
        payment.setUpdatedAt(LocalDateTime.now());

        paymentRepository.save(payment);

        commerceAuditService.success(
                userId,
                payment.getOrderId(),
                payment.getId(),
                "PAYMENT_SIGNATURE_VERIFIED",
                PaymentStatus.CREATED.name(),
                PaymentStatus.PAID.name(),
                payment.getAmountInPaise(),
                payment.getCurrency(),
                payment.getRazorpayOrderId(),
                payment.getRazorpayPaymentId(),
                "Payment signature verified",
                0
        );

        orderService.markOrderPaid(userId, payment.getOrderId());

        commerceAuditService.success(
                userId,
                payment.getOrderId(),
                payment.getId(),
                "ORDER_PAYMENT_APPLIED",
                null,
                OrderStatus.PAID.name(),
                payment.getAmountInPaise(),
                payment.getCurrency(),
                payment.getRazorpayOrderId(),
                payment.getRazorpayPaymentId(),
                "Payment applied to order",
                0
        );

        auditService.create(new CreateAuditLogRequest(
                userId,
                AuditAction.PAYMENT_COMPLETED,
                "commerce-service",
                "PAYMENT",
                payment.getId(),
                "Payment verified",
                null
        ));

        com.monkmarket.commerceservice.model.Order order =
                orderService.getEntity(payment.getOrderId());

        return new PaymentVerificationResponse(
                true,
                "Payment completed successfully",
                payment.getOrderId(),
                payment.getId(),
                payment.getStatus().name(),
                order.getStatus().name()
        );
    }

    private PaymentOrderResponse toResponse(Payment payment) {
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
