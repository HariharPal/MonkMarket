
package com.monkmarket.agentservice.dto;

import java.util.List;
import java.util.UUID;

public record CartDto(

        UUID cartId,

        List<CartItemDto> items,

        Long totalInPaise,

        String currency

) {
}