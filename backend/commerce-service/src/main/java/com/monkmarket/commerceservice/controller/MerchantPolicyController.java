package com.monkmarket.commerceservice.controller;

import com.monkmarket.commerceservice.dto.MerchantPolicyRequest;
import com.monkmarket.commerceservice.dto.MerchantPolicyResponse;
import com.monkmarket.commerceservice.service.MerchantPolicyService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/catalog/policy")
@RequiredArgsConstructor
public class MerchantPolicyController {

    private final MerchantPolicyService service;

    @GetMapping
    public MerchantPolicyResponse getPolicy() {
        return service.getPolicy();
    }

    @PutMapping
    public MerchantPolicyResponse updatePolicy(
            @Valid @RequestBody MerchantPolicyRequest request
    ) {
        return service.updatePolicy(request);
    }
}
