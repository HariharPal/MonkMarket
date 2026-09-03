package com.monkmarket.commerceservice.controller;

import com.monkmarket.commerceservice.dto.MerchantOrderResponse;
import com.monkmarket.commerceservice.service.MerchantOrderService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/merchant/orders")
@RequiredArgsConstructor
public class MerchantOrderController {

    private final MerchantOrderService merchantOrderService;

    @GetMapping
    public List<MerchantOrderResponse> getOrders() {
        return merchantOrderService.getOrders();
    }

    @GetMapping("/{orderId}")
    public MerchantOrderResponse getOrder(
            @PathVariable UUID orderId
    ) {
        return merchantOrderService.getOrder(orderId);
    }
}