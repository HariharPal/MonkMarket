package com.monkmarket.commerceservice.repository;

import com.monkmarket.commerceservice.model.Payment;
import com.monkmarket.commerceservice.model.PaymentStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface PaymentRepository extends JpaRepository<Payment, UUID> {

    Optional<Payment> findByOrderId(UUID orderId);

    Optional<Payment> findByRazorpayOrderId(String razorpayOrderId);

    List<Payment> findByStatusAndExpiresAtBefore(
            PaymentStatus status,
            LocalDateTime time
    );
}
