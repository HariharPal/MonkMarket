package com.monkmarket.paymentservice.repository;

import com.monkmarket.paymentservice.dto.PaymentStatus;
import com.monkmarket.paymentservice.model.Payment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PaymentRepository
        extends JpaRepository<Payment, UUID> {

    Optional<Payment> findByOrderId(UUID orderId);

    Optional<Payment> findByRazorpayOrderId(
            String razorpayOrderId
    );

    List<Payment> findByStatusAndExpiresAtBefore(
            PaymentStatus status,
            LocalDateTime time
    );
}