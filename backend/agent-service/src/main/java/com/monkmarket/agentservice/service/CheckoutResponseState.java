package com.monkmarket.agentservice.service;

import java.util.UUID;

public record CheckoutResponseState(

        boolean confirmationRequired,

        UUID cartId,

        long amountInPaise,

        String message

) {
}