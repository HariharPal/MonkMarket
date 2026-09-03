package com.monkmarket.commerceservice.repository;

import com.monkmarket.commerceservice.model.Cart;
import com.monkmarket.commerceservice.model.CartStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.UUID;

public interface CartRepository extends JpaRepository<Cart, UUID> {

    List<Cart> findByUserIdAndStatusOrderByUpdatedAtDesc(
            UUID userId,
            CartStatus status
    );
}