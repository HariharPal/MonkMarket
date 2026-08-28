
package com.monkmarket.orderservice.utils;

public class EmptyCartException
        extends RuntimeException {

    public EmptyCartException(
            String message
    ) {
        super(message);
    }
}