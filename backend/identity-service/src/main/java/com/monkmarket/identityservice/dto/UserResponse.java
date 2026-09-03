package com.monkmarket.identityservice.dto;

import com.monkmarket.identityservice.model.Role;
import com.monkmarket.identityservice.model.User;

import java.time.LocalDateTime;
import java.util.UUID;

public record UserResponse(

        UUID id,
        String name,
        String email,
        Role role,
        boolean enabled,
        LocalDateTime createdAt

) {

    public static UserResponse from(User user) {

        return new UserResponse(
                user.getId(),
                user.getName(),
                user.getEmail(),
                user.getRole(),
                user.isEnabled(),
                user.getCreatedAt()
        );
    }
}