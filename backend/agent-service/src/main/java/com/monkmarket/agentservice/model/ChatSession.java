package com.monkmarket.agentservice.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "chat_sessions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatSession {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private UUID userId;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Builder.Default
    @Enumerated(EnumType.STRING)
    private CheckoutState checkoutState = CheckoutState.NONE;

    @Column
    private UUID checkoutOrderId;

    @Column
    private UUID checkoutPaymentId;

    @Column
    private String checkoutRazorpayOrderId;

    @Column
    private Long checkoutAmountInPaise;

    @Column
    private String checkoutCurrency;

    @Column
    private String checkoutPaymentStatus;


    @Column
    private UUID pendingCheckoutCartId;

    @Column
    private String pendingCheckoutIdempotencyKey;

    @Column(nullable = false)
    private LocalDateTime updatedAt;
}