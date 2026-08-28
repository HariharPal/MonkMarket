package com.monkmarket.authservice.service;
import com.monkmarket.authservice.dto.*;
import com.monkmarket.authservice.dao.UserDao;
import com.monkmarket.authservice.model.Role;
import com.monkmarket.authservice.model.User;
import com.monkmarket.authservice.utils.UserNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
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

        if (userDao.existsByEmail(request.email())) {

            return ResponseEntity
                    .badRequest()
                    .body("Email already exists");
        }

        User user = new User();

        user.setName(request.name());

        user.setEmail(request.email());

        user.setPassword(
                passwordEncoder.encode(
                        request.password()
                )
        );

        user.setEnabled(true);

        user.setRole(Role.USER);

        user.setCreatedAt(
                LocalDateTime.now()
        );

        userDao.save(user);

        return ResponseEntity
                .status(HttpStatus.CREATED)
                .body("User created successfully");
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

        boolean emailExists =
                userDao.existsByEmail(
                        request.email()
                );

        boolean emailChanged =
                !user.getEmail()
                        .equals(request.email());

        if (emailExists && emailChanged) {

            return ResponseEntity
                    .badRequest()
                    .body("Email already exists");
        }

        user.setName(
                request.name()
        );

        user.setEmail(
                request.email()
        );

        userDao.save(user);

        return ResponseEntity.ok("User updated successfully");
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


    public ResponseEntity<AuthResponse> loginUser(
            LoginRequest request
    ) {

        User user =
                userDao.findByEmail(request.email())
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

        String token =
                jwtService.generateToken(user);

        return ResponseEntity.ok(

                new AuthResponse(
                        token,
                        user.getId(),
                        user.getName(),
                        user.getEmail(),
                        user.getRole()
                )
        );
    }


    public ResponseEntity<UserInfo> checkUser(
            Authentication authentication
    ) {

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
}