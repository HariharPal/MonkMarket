package com.monkmarket.commerceservice.service;

import com.monkmarket.commerceservice.dto.CreateAuditLogRequest;
import com.monkmarket.commerceservice.dto.CreateOrderRequest;
import com.monkmarket.commerceservice.dto.MerchantPolicyResponse;
import com.monkmarket.commerceservice.dto.OrderResponse;
import com.monkmarket.commerceservice.model.*;
import com.monkmarket.commerceservice.repository.OrderRepository;
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

    private final OrderRepository orderRepository;
    private final CartService cartService;
    private final ProductService productService;
    private final MerchantPolicyService merchantPolicyService;
    private final GuardrailService guardrailService;
    private final AuditService auditService;
    private final CommerceAuditService commerceAuditService;

    public OrderResponse createOrder(
            UUID userId,
            CreateOrderRequest request
    ) {

        long start = System.nanoTime();

        try {

            Order existing =
                    orderRepository
                            .findByIdempotencyKey(
                                    request.idempotencyKey()
                            )
                            .orElse(null);

            if (existing != null) {

                if (!existing.getUserId().equals(userId)) {
                    throw new IllegalStateException(
                            "Idempotency key belongs to another user"
                    );
                }

                commerceAuditService.success(
                        userId,
                        existing.getId(),
                        null,
                        "ORDER_IDEMPOTENCY_REPLAY",
                        existing.getStatus().name(),
                        existing.getStatus().name(),
                        existing.getTotalAmountInPaise(),
                        existing.getCurrency(),
                        null,
                        null,
                        "Existing order returned for idempotency key",
                        elapsedMs(start)
                );

                return OrderResponse.from(existing);
            }

            Cart cart =
                    cartService.getOrCreateActiveCart(userId);

            if (!cart.getId().equals(request.cartId())) {
                throw new IllegalStateException(
                        "Cart does not belong to user"
                );
            }

            if (cart.getItems().isEmpty()) {
                throw new IllegalStateException(
                        "Cannot create order from empty cart"
                );
            }

            MerchantPolicyResponse policy =
                    merchantPolicyService.getPolicy();

            List<String> categories = new ArrayList<>();
            List<OrderItem> orderItems = new ArrayList<>();

            long total = 0;

            for (CartItem cartItem : cart.getItems()) {

                Product product =
                        productService.findEntity(
                                cartItem.getProductId()
                        );

                if (product.getStockQty()
                        < cartItem.getQuantity()) {

                    throw new IllegalStateException(
                            product.getTitle()
                                    + " does not have enough stock"
                    );
                }

                categories.add(
                        product.getCategory()
                );

                long itemTotal =
                        product.getPriceInPaise()
                                * cartItem.getQuantity();

                total += itemTotal;

                OrderItem orderItem =
                        OrderItem.builder()
                                .productName(
                                        product.getTitle()
                                )
                                .productId(
                                        product.getId()
                                )
                                .priceInPaise(
                                        product.getPriceInPaise()
                                )
                                .quantity(
                                        cartItem.getQuantity()
                                )
                                .totalPriceInPaise(
                                        itemTotal
                                )
                                .imageUrl(
                                        product.getImageUrl()
                                )
                                .build();

                orderItems.add(orderItem);
            }

            GuardrailService.GuardrailResult guardrail =
                    guardrailService.evaluate(
                            total,
                            policy,
                            categories,
                            request.humanConfirmed()
                    );

            if (guardrail.decision()
                    != GuardrailService.Decision.ALLOWED) {

                throw new IllegalStateException(
                        guardrail.reason()
                );
            }

            LocalDateTime now =
                    LocalDateTime.now();

            Order order =
                    Order.builder()
                            .userId(userId)
                            .cartId(cart.getId())
                            .totalAmountInPaise(total)
                            .currency("INR")
                            .status(OrderStatus.PAYMENT_PENDING)
                            .idempotencyKey(
                                    request.idempotencyKey()
                            )
                            .createdAt(now)
                            .updatedAt(now)
                            .build();

            for (OrderItem item : orderItems) {
                item.setOrder(order);
            }

            order.setItems(orderItems);

            Order saved =
                    orderRepository.save(order);

            auditService.create(
                    new CreateAuditLogRequest(
                            userId,
                            AuditAction.ORDER_CREATED,
                            "commerce-service",
                            "ORDER",
                            saved.getId(),
                            "Order created amount="
                                    + saved.getTotalAmountInPaise(),
                            null
                    )
            );

            commerceAuditService.success(
                    userId,
                    saved.getId(),
                    null,
                    "ORDER_CREATED",
                    null,
                    saved.getStatus().name(),
                    saved.getTotalAmountInPaise(),
                    saved.getCurrency(),
                    null,
                    null,
                    "Order created successfully",
                    elapsedMs(start)
            );

            return OrderResponse.from(saved);

        } catch (Exception e) {

            commerceAuditService.failure(
                    userId,
                    null,
                    null,
                    "ORDER_CREATE_FAILED",
                    e,
                    elapsedMs(start)
            );

            throw e;
        }
    }
    private long elapsedMs(long start) {
        return (System.nanoTime() - start) / 1_000_000;
    }

    private void finalizePaidOrder(Order order) {

        Cart cart = cartService.getById(order.getCartId());

        if (cart.getStatus() == CartStatus.CHECKED_OUT) {
            return;
        }

        for (CartItem cartItem : cart.getItems()) {

            Product product =
                    productService.findEntity(cartItem.getProductId());

            if (product.getStockQty() < cartItem.getQuantity()) {
                throw new IllegalStateException(
                        product.getTitle() + " no longer has enough stock"
                );
            }

            product.setStockQty(
                    product.getStockQty() - cartItem.getQuantity()
            );
        }

        cartService.markCheckedOut(cart.getId());
    }

    public void markOrderPaid(
            UUID userId,
            UUID orderId
    ) {

        long start = System.nanoTime();

        Order order = getEntity(orderId);

        String oldStatus =
                order.getStatus().name();

        try {

            if (!order.getUserId().equals(userId)) {
                throw new IllegalArgumentException(
                        "Order not found"
                );
            }

            if (order.getStatus() == OrderStatus.PAID
                    || order.getStatus() == OrderStatus.CONFIRMED) {

                commerceAuditService.success(
                        userId,
                        orderId,
                        null,
                        "ORDER_PAYMENT_ALREADY_APPLIED",
                        oldStatus,
                        oldStatus,
                        order.getTotalAmountInPaise(),
                        order.getCurrency(),
                        null,
                        null,
                        "Order was already paid",
                        elapsedMs(start)
                );

                return;
            }

            if (order.getStatus()
                    == OrderStatus.PAYMENT_EXPIRED) {

                throw new IllegalStateException(
                        "Order payment has expired"
                );
            }

            finalizePaidOrder(order);

            order.setStatus(
                    OrderStatus.PAID
            );

            order.setUpdatedAt(
                    LocalDateTime.now()
            );

            orderRepository.save(order);

            commerceAuditService.success(
                    userId,
                    orderId,
                    null,
                    "ORDER_MARKED_PAID",
                    oldStatus,
                    OrderStatus.PAID.name(),
                    order.getTotalAmountInPaise(),
                    order.getCurrency(),
                    null,
                    null,
                    "Order marked paid",
                    elapsedMs(start)
            );

        } catch (Exception e) {

            commerceAuditService.failure(
                    userId,
                    orderId,
                    null,
                    "ORDER_MARK_PAID_FAILED",
                    e,
                    elapsedMs(start)
            );

            throw e;
        }
    }

    public void expireOrder(UUID orderId) {
        Order order = getEntity(orderId);

        if (order.getStatus() == OrderStatus.PAID
                || order.getStatus() == OrderStatus.CONFIRMED) {
            return;
        }

        order.setStatus(OrderStatus.PAYMENT_EXPIRED);
        order.setUpdatedAt(LocalDateTime.now());
        orderRepository.save(order);
    }

    @Transactional(readOnly = true)
    public OrderResponse getOrder(UUID userId, UUID orderId) {
        Order order = getEntity(orderId);

        if (!order.getUserId().equals(userId)) {
            throw new IllegalArgumentException("Order not found");
        }

        return OrderResponse.from(order);
    }

    @Transactional(readOnly = true)
    public List<OrderResponse> getMyOrders(UUID userId) {
        return orderRepository.findByUserIdOrderByCreatedAtDesc(userId)
                .stream()
                .map(OrderResponse::from)
                .toList();
    }

    public Order getEntity(UUID orderId) {
        return orderRepository.findById(orderId)
                .orElseThrow(() -> new IllegalArgumentException("Order not found"));
    }
}
