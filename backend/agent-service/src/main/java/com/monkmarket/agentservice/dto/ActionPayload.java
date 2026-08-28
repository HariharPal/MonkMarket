
package com.monkmarket.agentservice.dto;

import java.util.UUID;

public record ActionPayload(

        UUID productId,

        UUID orderId

) {
}