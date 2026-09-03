package com.monkmarket.agentservice.model;

public enum CheckoutState {
    NONE,
    CONFIRMATION_REQUIRED,
    PAYMENT_REQUIRED,
    PAYMENT_COMPLETED,
    BLOCKED
}