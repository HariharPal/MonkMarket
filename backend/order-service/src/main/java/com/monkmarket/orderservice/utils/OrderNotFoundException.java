package com.monkmarket.orderservice.utils;

public class OrderNotFoundException
        extends RuntimeException {

    public OrderNotFoundException(
            String message
    ) {
        super(message);
    }
}