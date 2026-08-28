

package com.monkmarket.orderservice.controller;

import com.monkmarket.orderservice.dto.CreateOrderRequest;
import com.monkmarket.orderservice.dto.OrderResponse;
import com.monkmarket.orderservice.service.OrderService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/orders")
@RequiredArgsConstructor
public class OrderController {

    private final OrderService orderService;


    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public OrderResponse createOrder(

            @RequestHeader("X-User-Id")
            UUID userId,

            @Valid
            @RequestBody
            CreateOrderRequest request
    ) {

        return orderService.createOrder(
                userId,
                request
        );
    }

    @PatchMapping("/{orderId}/payment-status")
    public void markOrderPaid(
            @RequestHeader("X-User-Id")
            UUID userId,

            @PathVariable
            UUID orderId
    ) {
        orderService.markOrderPaid(
                userId,
                orderId
        );
    }


    @PatchMapping("/{orderId}/expire")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void expireOrder(
            @PathVariable UUID orderId
    ) {

        orderService.expireOrder(
                orderId
        );
    }

    @GetMapping("/{orderId}")
    public OrderResponse getOrder(

            @RequestHeader("X-User-Id")
            UUID userId,

            @PathVariable
            UUID orderId
    ) {

        return orderService.getOrder(
                userId,
                orderId
        );
    }


    @GetMapping("/my")
    public List<OrderResponse> getMyOrders(

            @RequestHeader("X-User-Id")
            UUID userId
    ) {

        return orderService.getMyOrders(
                userId
        );
    }
}