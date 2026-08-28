package com.monkmarket.authservice.dto;

import com.monkmarket.authservice.model.Role;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @Email
        String email,

        @Size(min = 8)
        String password,

        Role role
) {}