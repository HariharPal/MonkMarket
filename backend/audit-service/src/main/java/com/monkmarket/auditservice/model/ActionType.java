package com.monkmarket.auditservice.model;

public enum ActionType {

    SEARCH,

    ADD_TO_CART,

    REMOVE_FROM_CART,

    CHECKOUT_PROPOSED,

    CHECKOUT_BLOCKED,

    PAYMENT_CREATED,

    PAYMENT_FAILED,

    PAYMENT_SUCCESS,

    UPSELL_OFFERED,

    ORDER_CREATED
}