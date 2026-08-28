package com.monkmarket.agentservice.service;

import com.monkmarket.agentservice.dto.CartDto;
import com.monkmarket.agentservice.dto.ProductDto;
import com.monkmarket.agentservice.dto.ProductRecommendationDto;
import lombok.Getter;
import lombok.Setter;
import org.springframework.stereotype.Component;
import org.springframework.web.context.annotation.RequestScope;

import java.util.ArrayList;
import java.util.List;

@Component
@RequestScope
@Getter
public class AgentTurnContext {
    @Setter
    private CheckoutResponseState checkout;


    public void clearCheckout() {
        this.checkout = null;
    }

    private final List<ProductDto> products =
            new ArrayList<>();

    private final List<ProductRecommendationDto> recommendations =
            new ArrayList<>();

    private CartDto cart;

    public void setProducts(
            List<ProductDto> products
    ) {

        this.products.clear();

        if (products != null) {
            this.products.addAll(products);
        }
    }

    public void setRecommendations(
            List<ProductRecommendationDto> recommendations
    ) {

        this.recommendations.clear();

        if (recommendations != null) {
            this.recommendations.addAll(recommendations);
        }
    }

    public void setCart(
            CartDto cart
    ) {
        this.cart = cart;
    }

    public void clearProducts() {
        this.products.clear();
    }

    public void clearRecommendations() {
        this.recommendations.clear();
    }

    public void clearCart() {
        this.cart = null;
    }
}