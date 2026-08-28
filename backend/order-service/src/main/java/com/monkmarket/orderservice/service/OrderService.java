
package com.monkmarket.orderservice.service;

import com.monkmarket.orderservice.client.CartClient;
import com.monkmarket.orderservice.client.CatalogClient;
import com.monkmarket.orderservice.client.PolicyClient;
import com.monkmarket.orderservice.dto.*;
import com.monkmarket.orderservice.guardrail.GuardrailDecision;
import com.monkmarket.orderservice.guardrail.GuardrailResult;
import com.monkmarket.orderservice.guardrail.OrderGuardrailService;
import com.monkmarket.orderservice.utils.EmptyCartException;
import com.monkmarket.orderservice.utils.OrderNotFoundException;
import com.monkmarket.orderservice.model.Order;
import com.monkmarket.orderservice.model.OrderItem;
import com.monkmarket.orderservice.model.OrderStatus;
import com.monkmarket.orderservice.repository.OrderRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Transactional
public class OrderService {
    private final PolicyClient policyClient;
    private final OrderRepository orderRepository;
    private final OrderGuardrailService orderGuardrailService;
    private final CartClient cartClient;

    private final CatalogClient catalogClient;


    public OrderResponse createOrder(
            UUID userId,
            CreateOrderRequest request
    ) {

        Order existingOrder =
                orderRepository
                        .findByIdempotencyKey(
                                request.idempotencyKey()
                        )
                        .orElse(null);

        if (existingOrder != null) {

            return OrderResponse.from(
                    existingOrder
            );
        }

        CartInfo cart =
                cartClient.getCart(userId, request.cartId());

        if (!cart.id().equals(request.cartId())) {
            throw new RuntimeException(
                    "Cart does not belong to user"
            );
        }

        if (cart.items() == null
                || cart.items().isEmpty()) {

            throw new EmptyCartException(
                    "Cannot create order from empty cart"
            );
        }



        LocalDateTime now =
                LocalDateTime.now();

        Order order =
                Order.builder()
                        .userId(userId)
                        .cartId(cart.id())
                        .status(
                                OrderStatus.CREATED
                        )
                        .currency("INR")
                        .idempotencyKey(
                                request.idempotencyKey()
                        )
                        .createdAt(now)
                        .updatedAt(now)
                        .build();

        List<OrderItem> orderItems =
                new ArrayList<>();

        long totalAmount = 0;

        for (CartItemInfo cartItem
                : cart.items()) {

            ProductInfo product =
                    catalogClient.getProduct(
                            cartItem.productId()
                    );
            MerchantPolicyResponse policy =
                    policyClient.getPolicy();

            if (policy.allowedCategories() != null
                    && !policy.allowedCategories().isEmpty()) {

                boolean allowed =
                        policy.allowedCategories()
                                .stream()
                                .anyMatch(
                                        category ->
                                                category.equalsIgnoreCase(
                                                        product.category()
                                                )
                                );

                if (!allowed) {

                    throw new IllegalStateException(
                            "Product category '"
                                    + product.category()
                                    + "' is not allowed"
                    );
                }
            }

            if (product.stockQty() < cartItem.quantity()) {

                throw new RuntimeException(
                        product.title()
                                + " does not have enough stock"
                );
            }

            long itemTotal =
                    product.priceInPaise()
                            * cartItem.quantity();

            OrderItem orderItem =
                    OrderItem.builder()
                            .order(order)
                            .productId(
                                    product.id()
                            )
                            .productName(
                                    product.title()
                            )
                            .priceInPaise(
                                    product.priceInPaise()
                            )
                            .quantity(
                                    cartItem.quantity()
                            )
                            .totalPriceInPaise(
                                    itemTotal
                            )
                            .imageUrl(
                                    product.imageUrl()
                            )
                            .build();

            orderItems.add(orderItem);

            totalAmount += itemTotal;
        }



        order.setItems(orderItems);

        order.setTotalAmountInPaise(
                totalAmount
        );

        MerchantPolicyResponse policy =
                policyClient.getPolicy();

        GuardrailResult guardrail =
                orderGuardrailService.evaluate(
                        totalAmount,
                        policy,
                        request.humanConfirmed()
                );

        if (guardrail.decision()
                != GuardrailDecision.ALLOWED) {

            throw new RuntimeException(
                    guardrail.reason()
            );
        }



        Order savedOrder =
                orderRepository.save(order);

        return OrderResponse.from(
                savedOrder
        );
    }

    @Transactional
    public void markOrderPaid(
            UUID userId,
            UUID orderId
    ) {

        Order order = orderRepository
                .findById(orderId)
                .orElseThrow(
                        () -> new OrderNotFoundException(
                                "Order not found"
                        )
                );

        if (!order.getUserId().equals(userId)) {
            throw new OrderNotFoundException(
                    "Order not found"
            );
        }

        if (order.getStatus() == OrderStatus.PAID) {
            return;
        }

        if (order.getStatus() == OrderStatus.PAYMENT_EXPIRED) {
            throw new IllegalStateException(
                    "Order payment has expired"
            );
        }

        order.setStatus(
                OrderStatus.PAID
        );

        order.setUpdatedAt(
                LocalDateTime.now()
        );

        orderRepository.save(order);
    }


    public OrderResponse getOrder(
            UUID userId,
            UUID orderId
    ) {

        Order order =
                orderRepository
                        .findById(orderId)
                        .orElseThrow(
                                () ->
                                        new OrderNotFoundException(
                                                "Order not found"
                                        )
                        );

        if (!order.getUserId().equals(userId)) {

            throw new OrderNotFoundException(
                    "Order not found"
            );
        }

        return OrderResponse.from(
                order
        );
    }


    public List<OrderResponse> getMyOrders(
            UUID userId
    ) {

        return orderRepository
                .findByUserIdOrderByCreatedAtDesc(
                        userId
                )
                .stream()
                .map(OrderResponse::from)
                .toList();
    }

    @Transactional
    public void expireOrder(
            UUID orderId
    ) {

        Order order = orderRepository
                .findById(orderId)
                .orElseThrow(
                        () -> new OrderNotFoundException(
                                "Order not found"
                        )
                );

        if (order.getStatus() == OrderStatus.PAID
                || order.getStatus() == OrderStatus.CONFIRMED) {

            return;
        }

        order.setStatus(
                OrderStatus.PAYMENT_EXPIRED
        );

        order.setUpdatedAt(
                LocalDateTime.now()
        );

        orderRepository.save(order);
    }


}