package com.monkmarket.authservice.dto;
import com.monkmarket.authservice.model.Role;

import java.util.UUID;

public record UserInfo(

        UUID id,

        String name,

        String email,

        Role role

) {}