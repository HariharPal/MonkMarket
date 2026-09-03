package com.monkmarket.commerceservice.service;

import com.monkmarket.commerceservice.dto.*;
import com.monkmarket.commerceservice.model.Cart;
import com.monkmarket.commerceservice.model.CartItem;
import com.monkmarket.commerceservice.model.CartStatus;
import com.monkmarket.commerceservice.model.Product;
import com.monkmarket.commerceservice.repository.CartItemRepository;
import com.monkmarket.commerceservice.repository.CartRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class CartService {

    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final ProductService productService;

    public CartResponse getCart(UUID userId) {
        return CartResponse.from(getOrCreateActiveCart(userId));
    }

    public CartResponse addItem(UUID userId, AddCartItemRequest request) {
        Cart cart = getOrCreateActiveCart(userId);
        Product product = productService.findEntity(request.productId());

        if (product.getStockQty() <= 0) {
            throw new IllegalStateException("Product is out of stock");
        }

        CartItem item = cartItemRepository
                .findByCartIdAndProductId(cart.getId(), request.productId())
                .orElse(null);

        if (item != null) {
            int quantity = item.getQuantity() + request.quantity();

            if (quantity > product.getStockQty()) {
                throw new IllegalStateException("Requested quantity exceeds available stock");
            }

            item.setQuantity(quantity);
        } else {
            if (request.quantity() > product.getStockQty()) {
                throw new IllegalStateException("Requested quantity exceeds available stock");
            }

            item = CartItem.builder()
                    .cart(cart)
                    .productId(product.getId())
                    .productName(product.getTitle())
                    .priceSnapshotInPaise(product.getPriceInPaise())
                    .quantity(request.quantity())
                    .imageUrl(product.getImageUrl())
                    .build();

            cart.getItems().add(item);
        }

        cart.setUpdatedAt(LocalDateTime.now());
        Cart saved = cartRepository.save(cart);
        return CartResponse.from(saved);
    }

    public Cart getById(UUID cartId) {
        return cartRepository.findById(cartId)
                .orElseThrow(() ->
                        new IllegalArgumentException("Cart not found")
                );
    }

    public CartResponse updateItemQuantity(
            UUID userId,
            UUID cartItemId,
            UpdateCartItemRequest request
    ) {
        Cart cart = getOrCreateActiveCart(userId);

        CartItem item = cart.getItems()
                .stream()
                .filter(i -> i.getId().equals(cartItemId))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Cart item not found"));

        Product product = productService.findEntity(item.getProductId());

        if (request.quantity() > product.getStockQty()) {
            throw new IllegalStateException("Requested quantity exceeds available stock");
        }

        item.setQuantity(request.quantity());
        cart.setUpdatedAt(LocalDateTime.now());

        return CartResponse.from(cartRepository.save(cart));
    }

    public CartResponse removeItem(UUID userId, UUID productId) {
        Cart cart = getOrCreateActiveCart(userId);

        CartItem item = cartItemRepository
                .findByCartIdAndProductId(cart.getId(), productId)
                .orElseThrow(() -> new IllegalArgumentException("Product is not in cart"));

        cart.getItems().remove(item);
        cartItemRepository.delete(item);
        cart.setUpdatedAt(LocalDateTime.now());

        return CartResponse.from(cartRepository.save(cart));
    }

    public CartResponse clearCart(UUID userId) {
        Cart cart = getOrCreateActiveCart(userId);
        cart.getItems().clear();
        cart.setUpdatedAt(LocalDateTime.now());
        return CartResponse.from(cartRepository.save(cart));
    }

    public Cart getOrCreateActiveCart(UUID userId) {

        List<Cart> activeCarts =
                cartRepository.findByUserIdAndStatusOrderByUpdatedAtDesc(
                        userId,
                        CartStatus.ACTIVE
                );

        if (!activeCarts.isEmpty()) {
            return activeCarts.get(0);
        }

        LocalDateTime now = LocalDateTime.now();

        Cart cart = Cart.builder()
                .userId(userId)
                .status(CartStatus.ACTIVE)
                .createdAt(now)
                .updatedAt(now)
                .build();

        return cartRepository.save(cart);
    }

    public void markCheckedOut(UUID cartId) {
        cartRepository.findById(cartId).ifPresent(cart -> {
            cart.setStatus(CartStatus.CHECKED_OUT);
            cart.setUpdatedAt(LocalDateTime.now());
            cartRepository.save(cart);
        });
    }
}
