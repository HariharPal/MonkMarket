package com.monkmarket.commerceservice.controller;

import com.monkmarket.commerceservice.model.CommerceAuditEvent;
import com.monkmarket.commerceservice.repository.CommerceAuditEventRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/commerce-audit")
@RequiredArgsConstructor
public class CommerceAuditController {

    private final CommerceAuditEventRepository repository;

    @GetMapping("/order/{orderId}")
    public List<CommerceAuditEvent> getOrderAudit(
            @RequestHeader("X-User-Id") UUID userId,
            @PathVariable UUID orderId
    ) {
        return repository
                .findTop100ByOrderIdOrderByCreatedAtDesc(orderId)
                .stream()
                .filter(event ->
                        userId.equals(event.getUserId())
                )
                .toList();
    }

    @GetMapping("/payment/{paymentId}")
    public List<CommerceAuditEvent> getPaymentAudit(
            @RequestHeader("X-User-Id") UUID userId,
            @PathVariable UUID paymentId
    ) {
        return repository
                .findTop100ByPaymentIdOrderByCreatedAtDesc(paymentId)
                .stream()
                .filter(event ->
                        userId.equals(event.getUserId())
                )
                .toList();
    }
}