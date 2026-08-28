package com.monkmarket.orderservice.model;

public enum OrderStatus {

    CREATED,
    PAYMENT_PENDING,
    PAID,
    CONFIRMED,
    PAYMENT_EXPIRED,
    CANCELLED
}