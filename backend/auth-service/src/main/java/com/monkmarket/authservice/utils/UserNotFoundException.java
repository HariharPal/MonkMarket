package com.monkmarket.authservice.utils;

public class UserNotFoundException extends Exception {
    public UserNotFoundException(String message){
        super(message);
    }


}