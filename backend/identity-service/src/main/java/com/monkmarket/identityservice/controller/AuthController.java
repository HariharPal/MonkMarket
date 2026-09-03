package com.monkmarket.identityservice.controller;

import com.monkmarket.identityservice.dto.AuthResponse;
import com.monkmarket.identityservice.dto.CreateUserRequest;
import com.monkmarket.identityservice.dto.LoginRequest;
import com.monkmarket.identityservice.dto.UpdateUserRequest;
import com.monkmarket.identityservice.dto.UserInfo;
import com.monkmarket.identityservice.dto.UserResponse;
import com.monkmarket.identityservice.service.AuthService;
import com.monkmarket.identityservice.utils.UserNotFoundException;

import jakarta.validation.Valid;

import lombok.RequiredArgsConstructor;

import org.springframework.http.ResponseEntity;

import org.springframework.security.core.Authentication;

import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;


    @PostMapping("/register")
    public ResponseEntity<String> register(

            @Valid
            @RequestBody
            CreateUserRequest request

    ) {

        return authService.createUser(request);
    }


    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(

            @Valid
            @RequestBody
            LoginRequest request

    ) {

        return authService.loginUser(request);
    }


    @GetMapping("/me")
    public ResponseEntity<UserInfo> getCurrentUser(

            Authentication authentication

    ) {

        return authService.checkUser(
                authentication
        );
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> getUser(

            @PathVariable
            UUID id

    ) throws UserNotFoundException {

        return authService.fetchUser(id);
    }

    @PutMapping("/{id}")
    public ResponseEntity<String> updateUser(

            @PathVariable
            UUID id,

            @Valid
            @RequestBody
            UpdateUserRequest request

    ) throws UserNotFoundException {

        return authService.updateUser(
                id,
                request
        );
    }
}