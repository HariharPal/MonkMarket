
package com.monkmarket.agentservice.dto;

import java.util.List;
import java.util.UUID;

public record AgentChatResponse(

        UUID sessionId,

        ResponseType type,

        String response,

        List<ProductDto> products,

        List<ProductRecommendationDto> recommendations,

        CartDto cart,

        CheckoutDto checkout,

        OrderDto order,

        List<OrderDto> orders,

        List<ActionDto> actions,

        MetaDto meta

) {

    public static AgentChatResponse normal(
            UUID sessionId,
            String response,
            MetaDto meta
    ) {
        return new AgentChatResponse(
                sessionId,
                ResponseType.NORMAL,
                response,
                List.of(),
                List.of(),
                null,
                null,
                null,
                List.of(),
                List.of(),
                meta
        );
    }

    public static AgentChatResponse products(
            UUID sessionId,
            String response,
            List<ProductDto> products,
            List<ActionDto> actions,
            MetaDto meta
    ) {
        return new AgentChatResponse(
                sessionId,
                ResponseType.PRODUCT_RESULTS,
                response,
                products == null ? List.of() : products,
                List.of(),
                null,
                null,
                null,
                List.of(),
                actions == null ? List.of() : actions,
                meta
        );
    }

    public static AgentChatResponse cartUpdated(
            UUID sessionId,
            String response,
            CartDto cart,
            List<ProductRecommendationDto> recommendations,
            List<ActionDto> actions,
            MetaDto meta
    ) {
        return new AgentChatResponse(
                sessionId,
                ResponseType.CART_UPDATED,
                response,
                List.of(),
                recommendations == null ? List.of() : recommendations,
                cart,
                null,
                null,
                List.of(),
                actions == null ? List.of() : actions,
                meta
        );
    }

    public static AgentChatResponse confirmationRequired(
            UUID sessionId,
            String response,
            CartDto cart,
            CheckoutDto checkout,
            List<ActionDto> actions,
            MetaDto meta
    ) {
        return new AgentChatResponse(
                sessionId,
                ResponseType.CHECKOUT_CONFIRMATION_REQUIRED,
                response,
                List.of(),
                List.of(),
                cart,
                checkout,
                null,
                List.of(),
                actions == null ? List.of() : actions,
                meta
        );
    }

    public static AgentChatResponse checkoutBlocked(
            UUID sessionId,
            String response,
            MetaDto meta,
            List<ActionDto> actions
    ) {
        return new AgentChatResponse(
                sessionId,
                ResponseType.CHECKOUT_BLOCKED,
                response,
                List.of(),
                List.of(),
                null,
                null,
                null,
                List.of(),
                actions == null ? List.of() : actions,
                meta
        );
    }

    public static AgentChatResponse paymentRequired(
            UUID sessionId,
            String response,
            CheckoutDto checkout,
            List<ActionDto> actions,
            MetaDto meta
    ) {
        return new AgentChatResponse(
                sessionId,
                ResponseType.PAYMENT_REQUIRED,
                response,
                List.of(),
                List.of(),
                null,
                checkout,
                null,
                List.of(),
                actions == null ? List.of() : actions,
                meta
        );
    }

    public static AgentChatResponse paymentSuccess(
            UUID sessionId,
            String response,
            CheckoutDto checkout,
            OrderDto order,
            List<ActionDto> actions,
            MetaDto meta
    ) {
        return new AgentChatResponse(
                sessionId,
                ResponseType.PAYMENT_SUCCESS,
                response,
                List.of(),
                List.of(),
                null,
                checkout,
                order,
                List.of(),
                actions == null ? List.of() : actions,
                meta
        );
    }

    public static AgentChatResponse paymentFailed(
            UUID sessionId,
            String response,
            CheckoutDto checkout,
            List<ActionDto> actions,
            MetaDto meta
    ) {
        return new AgentChatResponse(
                sessionId,
                ResponseType.PAYMENT_FAILED,
                response,
                List.of(),
                List.of(),
                null,
                checkout,
                null,
                List.of(),
                actions == null ? List.of() : actions,
                meta
        );
    }

    public static AgentChatResponse paymentExpired(
            UUID sessionId,
            String response,
            CheckoutDto checkout,
            List<ActionDto> actions,
            MetaDto meta
    ) {
        return new AgentChatResponse(
                sessionId,
                ResponseType.PAYMENT_EXPIRED,
                response,
                List.of(),
                List.of(),
                null,
                checkout,
                null,
                List.of(),
                actions == null ? List.of() : actions,
                meta
        );
    }

    public static AgentChatResponse orderStatus(
            UUID sessionId,
            String response,
            List<OrderDto> orders,
            List<ActionDto> actions,
            MetaDto meta
    ) {
        return new AgentChatResponse(
                sessionId,
                ResponseType.ORDER_STATUS,
                response,
                List.of(),
                List.of(),
                null,
                null,
                null,
                orders == null ? List.of() : orders,
                actions == null ? List.of() : actions,
                meta
        );
    }
}