package com.monkmarket.catalogservice.repository;

import com.monkmarket.catalogservice.model.MerchantPolicy;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface MerchantPolicyRepository
        extends JpaRepository<MerchantPolicy, UUID> {
}