package com.monkmarket.commerceservice.service;

import com.monkmarket.commerceservice.dto.MerchantPolicyRequest;
import com.monkmarket.commerceservice.dto.MerchantPolicyResponse;
import com.monkmarket.commerceservice.model.MerchantPolicy;
import com.monkmarket.commerceservice.repository.MerchantPolicyRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class MerchantPolicyService {

    private final MerchantPolicyRepository repository;

    public MerchantPolicyResponse getPolicy() {
        MerchantPolicy policy = repository.findAll()
                .stream()
                .findFirst()
                .orElseGet(this::createDefaultPolicy);

        return toResponse(policy);
    }

    public MerchantPolicyResponse updatePolicy(MerchantPolicyRequest request) {
        MerchantPolicy policy = repository.findAll()
                .stream()
                .findFirst()
                .orElseGet(this::createDefaultPolicy);

        policy.setMaxOrderAmountInPaise(request.maxOrderAmountInPaise());
        policy.setAllowedCategories(request.allowedCategories());
        policy.setUpsellMaxItems(request.upsellMaxItems());
        policy.setHumanConfirmAboveAmountInPaise(request.humanConfirmAboveAmountInPaise());
        policy.setAgentEnabled(request.agentEnabled());

        return toResponse(repository.save(policy));
    }

    public MerchantPolicy entity() {
        return repository.findAll()
                .stream()
                .findFirst()
                .orElseGet(this::createDefaultPolicy);
    }

    private MerchantPolicy createDefaultPolicy() {
        MerchantPolicy policy = MerchantPolicy.builder()
                .maxOrderAmountInPaise(500000L)
                .allowedCategories(List.of(
                        "SHOES",
                        "ACCESSORIES",
                        "ELECTRONICS",
                        "CLOTHING",
                        "FITNESS",
                        "GROCERY",
                        "NUTRITION",
                        "BAGS",
                        "COMPUTER_ACCESSORIES",
                        "HOME_OFFICE"
                ))
                .upsellMaxItems(1)
                .humanConfirmAboveAmountInPaise(200000L)
                .agentEnabled(true)
                .build();

        return repository.save(policy);
    }

    private MerchantPolicyResponse toResponse(MerchantPolicy policy) {
        return new MerchantPolicyResponse(
                policy.getId(),
                policy.getMaxOrderAmountInPaise(),
                policy.getAllowedCategories(),
                policy.getUpsellMaxItems(),
                policy.getHumanConfirmAboveAmountInPaise(),
                policy.isAgentEnabled()
        );
    }
}
