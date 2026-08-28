package com.monkmarket.cartservice.service;

import com.monkmarket.cartservice.client.CatalogClient;
import com.monkmarket.cartservice.dto.*;
import com.monkmarket.cartservice.utils.CartItemNotFoundException;
import com.monkmarket.cartservice.model.Cart;
import com.monkmarket.cartservice.model.CartItem;
import com.monkmarket.cartservice.model.CartStatus;
import com.monkmarket.cartservice.repository.CartItemRepository;
import com.monkmarket.cartservice.repository.CartRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class CartService {

    private final CartRepository cartRepository;
    private final CartItemRepository cartItemRepository;
    private final CatalogClient catalogClient;


    public CartResponse getCart(UUID userId) {

        Cart cart = getOrCreateActiveCart(userId);

        return CartResponse.from(cart);
    }


    public CartResponse addItem(
            UUID userId,
            AddCartItemRequest request
    ) {

        Cart cart = getOrCreateActiveCart(userId);

        ProductInfo product =
                catalogClient.getProduct(request.productId());

        if (product.stockQty() <= 0) {
            throw new RuntimeException("Product is out of stock");
        }

        CartItem cartItem =
                cartItemRepository
                        .findByCartIdAndProductId(
                                cart.getId(),
                                request.productId()
                        )
                        .orElse(null);

        if (cartItem != null) {

            int newQuantity =
                    cartItem.getQuantity()
                            + request.quantity();

            if (newQuantity > product.stockQty()) {
                throw new RuntimeException(
                        "Requested quantity exceeds available stock"
                );
            }

            cartItem.setQuantity(newQuantity);

        } else {

            cartItem = CartItem.builder()
                    .cart(cart)
                    .productId(product.id())
                    .productName(product.title())
                    .priceSnapshotInPaise(
                            product.priceInPaise()
                    )
                    .quantity(request.quantity())
                    .imageUrl(product.imageUrl())
                    .build();

            cart.getItems().add(cartItem);
        }

        cart.setUpdatedAt(LocalDateTime.now());

        cartRepository.save(cart);

        return CartResponse.from(cart);
    }


    public CartResponse updateItemQuantity(
            UUID userId,
            UUID cartItemId,
            UpdateCartItemRequest request
    ) {

        Cart cart = getOrCreateActiveCart(userId);

        CartItem cartItem =
                cart.getItems()
                        .stream()
                        .filter(
                                item ->
                                        item.getId()
                                                .equals(cartItemId)
                        )
                        .findFirst()
                        .orElseThrow(
                                () ->
                                        new CartItemNotFoundException(
                                                "Cart item not found"
                                        )
                        );

        ProductInfo product =
                catalogClient.getProduct(
                        cartItem.getProductId()
                );

        if (request.quantity() > product.stockQty()) {
            throw new RuntimeException(
                    "Requested quantity exceeds available stock"
            );
        }

        cartItem.setQuantity(
                request.quantity()
        );

        cart.setUpdatedAt(
                LocalDateTime.now()
        );

        cartRepository.save(cart);

        return CartResponse.from(cart);
    }


    @Transactional
    public CartResponse removeItem(
            UUID userId,
            UUID productId
    ) {

        Cart cart =
                getOrCreateActiveCart(userId);

        CartItem cartItem =
                cartItemRepository
                        .findByCartIdAndProductId(
                                cart.getId(),
                                productId
                        )
                        .orElseThrow(
                                () ->
                                        new CartItemNotFoundException(
                                                "Product is not in cart"
                                        )
                        );

        cartItemRepository.delete(
                cartItem
        );

        cart.getItems().remove(
                cartItem
        );

        cart.setUpdatedAt(
                LocalDateTime.now()
        );

        Cart savedCart =
                cartRepository.save(
                        cart
                );

        return CartResponse.from(
                savedCart
        );
    }

    @Transactional
    public CartResponse clearCart(
            UUID userId
    ) {

        Cart cart =
                getOrCreateActiveCart(userId);

        cartItemRepository.deleteAll(
                cart.getItems()
        );

        cart.getItems().clear();

        cart.setUpdatedAt(
                LocalDateTime.now()
        );

        Cart savedCart =
                cartRepository.save(
                        cart
                );

        return CartResponse.from(
                savedCart
        );
    }


    private Cart getOrCreateActiveCart(
            UUID userId
    ) {

        return cartRepository
                .findByUserIdAndStatus(
                        userId,
                        CartStatus.ACTIVE
                )
                .orElseGet(() -> {

                    LocalDateTime now =
                            LocalDateTime.now();

                    Cart cart =
                            Cart.builder()
                                    .userId(userId)
                                    .status(
                                            CartStatus.ACTIVE
                                    )
                                    .createdAt(now)
                                    .updatedAt(now)
                                    .build();

                    return cartRepository.save(cart);
                });
    }
}