package com.monkmarket.authservice.dto;

import com.monkmarket.authservice.model.Role;

import java.util.UUID;

public record LoginResponse(
        String accessToken,
        String tokenType,
        UUID userId,
        String email,
        Role role
) {}