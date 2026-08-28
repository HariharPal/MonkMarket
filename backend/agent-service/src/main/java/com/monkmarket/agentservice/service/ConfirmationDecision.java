package com.monkmarket.agentservice.service;

public record ConfirmationDecision(
        boolean confirmed,
        boolean rejected
) {
}