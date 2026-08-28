package com.monkmarket.authservice.controller;

import com.monkmarket.authservice.dto.*;
import com.monkmarket.authservice.service.AuthService;
import com.monkmarket.authservice.utils.UserNotFoundException;
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
        System.out.println(request);
        return authService.loginUser(request);
    }


    @GetMapping("/me")
    public ResponseEntity<UserInfo> getCurrentUser(

            Authentication authentication
    ) {

        return authService.checkUser(authentication);
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