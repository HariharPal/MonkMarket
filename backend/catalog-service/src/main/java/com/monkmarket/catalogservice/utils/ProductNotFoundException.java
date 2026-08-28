package com.monkmarket.catalogservice.utils;

public class ProductNotFoundException
        extends RuntimeException {

    public ProductNotFoundException(
            String message
    ) {
        super(message);
    }
}