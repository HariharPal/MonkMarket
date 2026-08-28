package com.monkmarket.cartservice.repository;

import com.monkmarket.cartservice.model.CartItem;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.UUID;

public interface CartItemRepository
        extends JpaRepository<CartItem, UUID> {

    Optional<CartItem> findByCartIdAndProductId(
            UUID cartId,
            UUID productId
    );
}