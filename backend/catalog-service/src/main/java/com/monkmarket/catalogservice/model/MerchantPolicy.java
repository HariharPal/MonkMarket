package com.monkmarket.catalogservice.model;

import jakarta.persistence.*;
import lombok.*;

import java.util.List;
import java.util.UUID;

@Entity
@Table(name = "merchant_policy")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MerchantPolicy {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private Long maxOrderAmountInPaise;

    @ElementCollection
    @CollectionTable(
            name = "allowed_categories",
            joinColumns = @JoinColumn(name = "policy_id")
    )
    @Column(name = "category")
    private List<String> allowedCategories;

    @Column(nullable = false)
    private Integer upsellMaxItems;

    @Column(nullable = false)
    private Long humanConfirmAboveAmountInPaise;

    @Column(nullable = false)
    private boolean agentEnabled;
}