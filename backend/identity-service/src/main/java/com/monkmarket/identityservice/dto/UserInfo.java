package com.monkmarket.identityservice.dto;

import com.monkmarket.identityservice.model.Role;

import java.util.UUID;

public record UserInfo(

        UUID userId,
        String name,
        String email,
        Role role

) {
}