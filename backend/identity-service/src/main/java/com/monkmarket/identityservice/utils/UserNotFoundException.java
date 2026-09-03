package com.monkmarket.identityservice.utils;

public class UserNotFoundException
        extends RuntimeException {

    public UserNotFoundException(
            String message
    ) {

        super(message);
    }
}