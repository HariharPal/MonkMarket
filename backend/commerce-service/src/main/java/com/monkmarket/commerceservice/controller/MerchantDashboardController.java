package com.monkmarket.commerceservice.controller;

import com.monkmarket.commerceservice.dto.MerchantDashboardResponse;
import com.monkmarket.commerceservice.dto.RevenueDataPointResponse;
import com.monkmarket.commerceservice.model.OrderStatus;
import com.monkmarket.commerceservice.model.PaymentStatus;
import com.monkmarket.commerceservice.model.Order;
import com.monkmarket.commerceservice.model.Payment;
import com.monkmarket.commerceservice.repository.OrderRepository;
import com.monkmarket.commerceservice.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import com.monkmarket.commerceservice.dto.AuditLogResponse;
import com.monkmarket.commerceservice.service.AuditService;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/merchant")
@RequiredArgsConstructor
public class MerchantDashboardController {

    private final OrderRepository orderRepository;
    private final PaymentRepository paymentRepository;

    private final AuditService auditService;

    @GetMapping("/audit")
    public List<AuditLogResponse> audit() {
        return auditService.getAllLogs();
    }

    @GetMapping("/dashboard")
    public MerchantDashboardResponse dashboard(
            @RequestHeader(value = "X-User-Id", required = false)
            UUID merchantId
    ) {

        List<Order> orders =
                orderRepository.findAll();

        List<Payment> payments =
                paymentRepository.findAll();

        long totalOrders =
                orders.size();

        long paidOrders =
                orders.stream()
                        .filter(order ->
                                order.getStatus()
                                        == OrderStatus.PAID
                                        || order.getStatus()
                                        == OrderStatus.CONFIRMED
                        )
                        .count();

        long totalRevenueInPaise =
                payments.stream()
                        .filter(payment ->
                                payment.getStatus()
                                        == PaymentStatus.PAID
                        )
                        .mapToLong(
                                Payment::getAmountInPaise
                        )
                        .sum();

        long pendingPayments =
                payments.stream()
                        .filter(payment ->
                                payment.getStatus()
                                        == PaymentStatus.CREATED
                        )
                        .count();

        long failedPayments =
                payments.stream()
                        .filter(payment ->
                                payment.getStatus()
                                        == PaymentStatus.FAILED
                        )
                        .count();

        return new MerchantDashboardResponse(
                totalRevenueInPaise,
                totalOrders,
                paidOrders,
                pendingPayments,
                failedPayments,
                0,
                0,
                "ACTIVE",
                "MonkMarket"
        );
    }

    @GetMapping("/analytics/revenue")
    public List<RevenueDataPointResponse> revenue(
            @RequestHeader(value = "X-User-Id", required = false)
            UUID merchantId
    ) {
        return orderRepository.findAll()
                .stream()
                .filter(order ->
                        order.getStatus() == OrderStatus.PAID
                                || order.getStatus() == OrderStatus.CONFIRMED
                )
                .collect(
                        java.util.stream.Collectors.groupingBy(
                                order ->
                                        order.getCreatedAt()
                                                .toLocalDate(),
                                java.util.TreeMap::new,
                                java.util.stream.Collectors.summingLong(
                                        Order::getTotalAmountInPaise
                                )
                        )
                )
                .entrySet()
                .stream()
                .map(entry ->
                        new RevenueDataPointResponse(
                                entry.getKey(),
                                entry.getValue()
                        )
                )
                .toList();
    }
}