package com.monkmarket.agentservice.client;

import com.monkmarket.agentservice.dto.AuditEventRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestClient;

@Component
@RequiredArgsConstructor
public class AuditClient {

    private final RestClient restClient;

    public void log(
            AuditEventRequest request
    ) {

        restClient
                .post()
                .uri(
                        "http://localhost:8086/api/v1/audit/events"
                )
                .body(request)
                .retrieve()
                .toBodilessEntity();
    }
}