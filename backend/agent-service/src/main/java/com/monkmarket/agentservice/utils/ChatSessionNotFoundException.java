
package com.monkmarket.agentservice.utils;

public class ChatSessionNotFoundException
        extends RuntimeException {

    public ChatSessionNotFoundException(
            String message
    ) {

        super(message);
    }
}