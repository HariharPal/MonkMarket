package com.monkmarket.identityservice.service;

import com.monkmarket.identityservice.dao.UserDao;
import com.monkmarket.identityservice.dto.AuthResponse;
import com.monkmarket.identityservice.dto.CreateUserRequest;
import com.monkmarket.identityservice.dto.LoginRequest;
import com.monkmarket.identityservice.dto.UpdateUserRequest;
import com.monkmarket.identityservice.dto.UserInfo;
import com.monkmarket.identityservice.dto.UserResponse;
import com.monkmarket.identityservice.model.Role;
import com.monkmarket.identityservice.model.User;
import com.monkmarket.identityservice.utils.UserNotFoundException;

import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import org.springframework.security.core.Authentication;

import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final JwtService jwtService;

    private final PasswordEncoder passwordEncoder;

    private final UserDao userDao;

    public ResponseEntity<String> createUser(
            CreateUserRequest request
    ) {

        if (userDao.existsByEmail(
                request.email()
        )) {

            return ResponseEntity
                    .badRequest()
                    .body("Email already exists");
        }

        User user = User.builder()

                .name(request.name())

                .email(
                        request.email()
                                .trim()
                                .toLowerCase()
                )

                .password(
                        passwordEncoder.encode(
                                request.password()
                        )
                )

                .role(Role.USER)

                .enabled(true)

                .createdAt(
                        LocalDateTime.now()
                )

                .build();

        userDao.save(user);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body("User created successfully");
    }


    public ResponseEntity<AuthResponse> loginUser(
            LoginRequest request
    ) {

        User user =
                userDao.findByEmail(
                                request.email()
                                        .trim()
                                        .toLowerCase()
                        )
                        .orElse(null);

        if (user == null ||
                !passwordEncoder.matches(
                        request.password(),
                        user.getPassword()
                )) {

            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .build();
        }

        if (!user.isEnabled()) {

            return ResponseEntity
                    .status(HttpStatus.FORBIDDEN)
                    .build();
        }

        String token =
                jwtService.generateToken(user);

        AuthResponse response =
                new AuthResponse(
                        token,
                        user.getId(),
                        user.getName(),
                        user.getEmail(),
                        user.getRole()
                );

        return ResponseEntity.ok(response);
    }


    public ResponseEntity<UserInfo> checkUser(
            Authentication authentication
    ) {

        if (authentication == null ||
                !authentication.isAuthenticated()) {

            return ResponseEntity
                    .status(HttpStatus.UNAUTHORIZED)
                    .build();
        }

        User user =
                (User) authentication.getPrincipal();

        UserInfo userInfo =
                new UserInfo(
                        user.getId(),
                        user.getName(),
                        user.getEmail(),
                        user.getRole()
                );

        return ResponseEntity.ok(userInfo);
    }


    public ResponseEntity<UserResponse> fetchUser(
            UUID id
    ) throws UserNotFoundException {

        User user =
                userDao.findById(id)
                        .orElseThrow(
                                () -> new UserNotFoundException(
                                        "User not found"
                                )
                        );

        return ResponseEntity.ok(
                UserResponse.from(user)
        );
    }


    public ResponseEntity<String> updateUser(
            UUID id,
            UpdateUserRequest request
    ) throws UserNotFoundException {

        User user =
                userDao.findById(id)
                        .orElseThrow(
                                () -> new UserNotFoundException(
                                        "User not found"
                                )
                        );

        String newEmail =
                request.email()
                        .trim()
                        .toLowerCase();

        boolean emailChanged =
                !user.getEmail()
                        .equalsIgnoreCase(newEmail);

        if (emailChanged &&
                userDao.existsByEmail(newEmail)) {

            return ResponseEntity
                    .badRequest()
                    .body("Email already exists");
        }

        user.setName(
                request.name().trim()
        );

        user.setEmail(newEmail);

        userDao.save(user);

        return ResponseEntity.ok(
                "User updated successfully"
        );
    }
}