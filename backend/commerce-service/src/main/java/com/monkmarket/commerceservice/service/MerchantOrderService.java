package com.monkmarket.commerceservice.service;

import com.monkmarket.commerceservice.dto.MerchantOrderResponse;
import com.monkmarket.commerceservice.dto.OrderItemResponse;
import com.monkmarket.commerceservice.model.Order;
import com.monkmarket.commerceservice.model.Payment;
import com.monkmarket.commerceservice.repository.OrderRepository;
import com.monkmarket.commerceservice.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class MerchantOrderService {

    private final OrderRepository orderRepository;
    private final PaymentRepository paymentRepository;

    public List<MerchantOrderResponse> getOrders() {

        return orderRepository
                .findAllByOrderByCreatedAtDesc()
                .stream()
                .map(this::toResponse)
                .toList();
    }

    public MerchantOrderResponse getOrder(
            UUID orderId
    ) {

        Order order =
                orderRepository
                        .findById(orderId)
                        .orElseThrow(
                                () -> new IllegalArgumentException(
                                        "Order not found"
                                )
                        );

        return toResponse(order);
    }

    private MerchantOrderResponse toResponse(
            Order order
    ) {

        Payment payment =
                paymentRepository
                        .findByOrderId(order.getId())
                        .orElse(null);

        return new MerchantOrderResponse(
                order.getId(),
                order.getUserId(),
                order.getCartId(),
                order.getTotalAmountInPaise(),
                order.getCurrency(),
                order.getStatus() == null
                        ? null
                        : order.getStatus().name(),
                payment == null
                        ? null
                        : payment.getStatus(),
                payment == null
                        ? null
                        : payment.getId(),
                payment == null
                        ? null
                        : payment.getRazorpayOrderId(),
                payment == null
                        ? null
                        : payment.getRazorpayPaymentId(),
                order.getItems()
                        .stream()
                        .map(OrderItemResponse::from)
                        .toList(),
                order.getCreatedAt(),
                order.getUpdatedAt()
        );
    }
}