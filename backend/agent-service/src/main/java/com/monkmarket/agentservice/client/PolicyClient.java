package com.monkmarket.agentservice.client;

import com.monkmarket.agentservice.dto.MerchantPolicyResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

@Component
@RequiredArgsConstructor
public class PolicyClient {

    private final RestClient restClient;

    public MerchantPolicyResponse getPolicy() {

        return restClient
                .get()
                .uri("http://localhost:8082/api/v1/catalog/policy")
                .retrieve()
                .body(MerchantPolicyResponse.class);
    }
}