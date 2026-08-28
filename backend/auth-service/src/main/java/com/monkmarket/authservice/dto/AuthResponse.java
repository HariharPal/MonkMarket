package com.monkmarket.authservice.dto;
import com.monkmarket.authservice.model.Role;

import java.util.UUID;

public record AuthResponse(

        String accessToken,

        UUID userId,

        String name,

        String email,

        Role role

) {}