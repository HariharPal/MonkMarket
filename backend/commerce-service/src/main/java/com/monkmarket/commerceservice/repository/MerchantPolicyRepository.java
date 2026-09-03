package com.monkmarket.commerceservice.repository;

import com.monkmarket.commerceservice.model.MerchantPolicy;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface MerchantPolicyRepository extends JpaRepository<MerchantPolicy, UUID> {
}
