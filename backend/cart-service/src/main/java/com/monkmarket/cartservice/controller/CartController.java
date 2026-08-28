package com.monkmarket.cartservice.controller;

import com.monkmarket.cartservice.dto.AddCartItemRequest;
import com.monkmarket.cartservice.dto.CartResponse;
import com.monkmarket.cartservice.dto.UpdateCartItemRequest;
import com.monkmarket.cartservice.service.CartService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/cart")
@RequiredArgsConstructor
public class CartController {

    private final CartService cartService;


    @GetMapping
    public CartResponse getCart(

            @RequestHeader("X-User-Id")
            UUID userId
    ) {

        return cartService.getCart(userId);
    }


    @PostMapping("/items")
    @ResponseStatus(HttpStatus.CREATED)
    public CartResponse addItem(

            @RequestHeader("X-User-Id")
            UUID userId,

            @Valid
            @RequestBody
            AddCartItemRequest request
    ) {

        return cartService.addItem(
                userId,
                request
        );
    }


    @PatchMapping("/items/{cartItemId}")
    public CartResponse updateItem(

            @RequestHeader("X-User-Id")
            UUID userId,

            @PathVariable
            UUID cartItemId,

            @Valid
            @RequestBody
            UpdateCartItemRequest request
    ) {

        return cartService.updateItemQuantity(
                userId,
                cartItemId,
                request
        );
    }




    @DeleteMapping("/items/{productId}")
    public CartResponse removeItem(
            @RequestHeader("X-User-Id")
            UUID userId,

            @PathVariable
            UUID productId
    ) {

        return cartService.removeItem(
                userId,
                productId
        );
    }

    @DeleteMapping
    public CartResponse clearCart(
            @RequestHeader("X-User-Id")
            UUID userId
    ) {

        return cartService.clearCart(
                userId
        );
    }
}