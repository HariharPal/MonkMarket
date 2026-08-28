package com.monkmarket.cartservice.utils;

public class CartNotFoundException
        extends RuntimeException {

    public CartNotFoundException(
            String message
    ) {
        super(message);
    }
}