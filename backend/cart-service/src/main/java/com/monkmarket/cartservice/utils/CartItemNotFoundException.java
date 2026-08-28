package com.monkmarket.cartservice.utils;

public class CartItemNotFoundException
        extends RuntimeException {

    public CartItemNotFoundException(
            String message
    ) {
        super(message);
    }
}