package com.monkmarket.agentservice.tool;

import com.monkmarket.agentservice.client.OrderClient;
import lombok.RequiredArgsConstructor;
import org.springframework.ai.chat.model.ToolContext;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.ai.tool.annotation.ToolParam;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
@RequiredArgsConstructor
public class OrderTools {

    private final OrderClient orderClient;

    @Tool(
            name = "getMyOrders",
            description = """
                    Get the authenticated shopper's previous orders.

                    Use this when the shopper asks:
                    - what are my orders
                    - show my orders
                    - previous orders
                    - order history
                    """
    )
    public String getMyOrders(
            ToolContext toolContext
    ) {

        UUID userId = getUserId(toolContext);

        return orderClient.getMyOrders(userId);
    }

    @Tool(
            name = "getOrder",
            description = """
                    Get details of a specific order.

                    Use this when the shopper asks about a particular order.
                    The orderId must come from a previous order lookup.
                    Never invent an order ID.
                    """
    )
    public String getOrder(
            @ToolParam(
                    description = "UUID of the order"
            )
            UUID orderId,

            ToolContext toolContext
    ) {

        UUID userId = getUserId(toolContext);

        return orderClient.getOrder(
                userId,
                orderId
        );
    }

    private UUID getUserId(
            ToolContext toolContext
    ) {

        Object value = toolContext
                .getContext()
                .get("userId");

        if (value == null) {
            throw new IllegalStateException(
                    "User ID missing from tool context"
            );
        }

        return UUID.fromString(
                value.toString()
        );
    }
}