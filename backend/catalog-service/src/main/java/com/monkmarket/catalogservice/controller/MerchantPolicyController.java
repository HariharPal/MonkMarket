package com.monkmarket.catalogservice.controller;

import com.monkmarket.catalogservice.dto.MerchantPolicyResponse;
import com.monkmarket.catalogservice.service.MerchantPolicyService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/catalog")
@RequiredArgsConstructor
public class MerchantPolicyController {

    private final MerchantPolicyService merchantPolicyService;

    @GetMapping("/policy")
    public MerchantPolicyResponse getPolicy() {
        return merchantPolicyService.getPolicy();
    }
}