package com.monkmarket.orderservice.repository;

import com.monkmarket.orderservice.model.Order;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface OrderRepository
        extends JpaRepository<Order, UUID> {

    List<Order> findByUserIdOrderByCreatedAtDesc(
            UUID userId
    );

    Optional<Order> findByIdempotencyKey(
            String idempotencyKey
    );
}