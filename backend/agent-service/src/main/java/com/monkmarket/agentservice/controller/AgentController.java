package com.monkmarket.agentservice.controller;

import com.monkmarket.agentservice.dto.AgentChatRequest;
import com.monkmarket.agentservice.dto.AgentChatResponse;
import com.monkmarket.agentservice.dto.ChatSessionResponse;
import com.monkmarket.agentservice.service.AgentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/agent")
@RequiredArgsConstructor
public class AgentController {

    private final AgentService agentService;

    @PostMapping("/chat")
    public AgentChatResponse chat(
            @RequestHeader("X-User-Id") UUID userId,
            @Valid @RequestBody AgentChatRequest request
    ) {
        return agentService.chat(
                userId,
                request
        );
    }

    @GetMapping("/sessions")
    public List<ChatSessionResponse> getMySessions(
            @RequestHeader("X-User-Id") UUID userId
    ) {
        return agentService.getMySessions(userId);
    }

    @GetMapping("/sessions/{sessionId}")
    public ChatSessionResponse getSession(
            @RequestHeader("X-User-Id") UUID userId,
            @PathVariable UUID sessionId
    ) {
        return agentService.getSession(
                userId,
                sessionId
        );
    }
}