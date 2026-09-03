package com.monkmarket.commerceservice.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(
        name = "commerce_audit_events",
        indexes = {
                @Index(
                        name = "idx_commerce_audit_user",
                        columnList = "userId"
                ),
                @Index(
                        name = "idx_commerce_audit_order",
                        columnList = "orderId"
                ),
                @Index(
                        name = "idx_commerce_audit_payment",
                        columnList = "paymentId"
                ),
                @Index(
                        name = "idx_commerce_audit_created",
                        columnList = "createdAt"
                )
        }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CommerceAuditEvent {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    private UUID userId;

    private UUID orderId;

    private UUID paymentId;

    @Column(nullable = false, length = 60)
    private String operation;

    @Column(length = 40)
    private String oldState;

    @Column(length = 40)
    private String newState;

    private Long amountInPaise;

    private String currency;

    private String razorpayOrderId;

    private String razorpayPaymentId;

    @Column(nullable = false)
    private Boolean success;

    @Column(columnDefinition = "TEXT")
    private String message;

    @Column(length = 120)
    private String errorType;

    @Column(columnDefinition = "TEXT")
    private String errorMessage;

    @Column(nullable = false)
    private Long latencyMs;

    @Column(nullable = false)
    private LocalDateTime createdAt;
}