package com.monkmarket.authservice.dto;

import com.monkmarket.authservice.model.Role;
import com.monkmarket.authservice.model.User;

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