package com.monkmarket.cartservice.repository;

import com.monkmarket.cartservice.model.Cart;
import com.monkmarket.cartservice.model.CartStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface CartRepository
        extends JpaRepository<Cart, UUID> {

    Optional<Cart> findByUserIdAndStatus(
            UUID userId,
            CartStatus status
    );
}