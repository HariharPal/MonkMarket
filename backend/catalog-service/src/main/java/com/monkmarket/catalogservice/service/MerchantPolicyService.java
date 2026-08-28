package com.monkmarket.catalogservice.service;

import com.monkmarket.catalogservice.dto.MerchantPolicyResponse;
import com.monkmarket.catalogservice.model.MerchantPolicy;
import com.monkmarket.catalogservice.repository.MerchantPolicyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MerchantPolicyService {

    private final MerchantPolicyRepository policyRepository;

    public MerchantPolicyResponse getPolicy() {

        MerchantPolicy policy =
                policyRepository.findAll()
                        .stream()
                        .findFirst()
                        .orElseGet(this::createDefaultPolicy);

        return new MerchantPolicyResponse(
                policy.getId(),
                policy.getMaxOrderAmountInPaise(),
                policy.getAllowedCategories(),
                policy.getUpsellMaxItems(),
                policy.getHumanConfirmAboveAmountInPaise(),
                policy.isAgentEnabled()
        );
    }

    private MerchantPolicy createDefaultPolicy() {

        MerchantPolicy policy =
                new MerchantPolicy();

        policy.setMaxOrderAmountInPaise(
                500000L
        );

        policy.setAllowedCategories(
                List.of(
                        "SHOES",
                        "ACCESSORIES",
                        "ELECTRONICS",
                        "CLOTHING"
                )
        );

        policy.setUpsellMaxItems(1);

        policy.setHumanConfirmAboveAmountInPaise(
                200000L
        );

        policy.setAgentEnabled(true);

        return policyRepository.save(policy);
    }
}