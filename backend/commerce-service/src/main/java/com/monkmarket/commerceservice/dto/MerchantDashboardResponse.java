package com.monkmarket.commerceservice.dto;

public record MerchantDashboardResponse(
        long totalRevenueInPaise,
        long totalOrders,
        long paidOrders,
        long pendingPayments,
        long failedPayments,
        long aiAssistedOrders,
        long guardrailBlocks,
        String agentStatus,
        String storeName
) {
}