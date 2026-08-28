package com.monkmarket.agentservice.dto;

public final class CartDtoMapper {

    private CartDtoMapper() {
    }

    public static CartDto from(
            CartResponse cart
    ) {

        if (cart == null) {
            return null;
        }

        return new CartDto(
                cart.id(),

                cart.items()
                        .stream()
                        .map(
                                item ->
                                        new CartItemDto(
                                                item.productId(),
                                                item.productName(),
                                                item.priceSnapshotInPaise(),
                                                item.quantity(),
                                                item.imageUrl(),
                                                item.totalPriceInPaise()
                                        )
                        )
                        .toList(),

                cart.totalAmountInPaise(),

                "INR"
        );
    }
}