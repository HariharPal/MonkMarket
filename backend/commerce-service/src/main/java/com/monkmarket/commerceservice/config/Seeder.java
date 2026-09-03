package com.monkmarket.commerceservice.config;

import com.monkmarket.commerceservice.model.Product;
import com.monkmarket.commerceservice.repository.ProductRepository;
import com.monkmarket.commerceservice.service.MerchantPolicyService;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.util.List;

// It's just for demo and starting purposes it will be removed in future
@Component
@RequiredArgsConstructor
public class Seeder implements CommandLineRunner {

    private final ProductRepository productRepository;
    private final MerchantPolicyService merchantPolicyService;

    @Override
    public void run(String... args) {
        merchantPolicyService.getPolicy();

        if (productRepository.count() > 0) {
            return;
        }

        productRepository.saveAll(List.of(
                product("SprintX Running Shoes", "Lightweight running shoes designed for daily jogging and road running.", 299900L, "SHOES", 18),
                product("AeroRun Pro Sneakers", "Cushioned athletic sneakers for running, walking, and workouts.", 249900L, "SHOES", 14),
                product("RoadRunner Lite Shoes", "Lightweight road-running shoes for beginners and daily jogging.", 189900L, "SHOES", 22),
                product("Classic Cotton T-Shirt", "Soft regular-fit cotton t-shirt for everyday wear.", 69900L, "CLOTHING", 40),
                product("Urban Denim Jacket", "Classic denim jacket for casual outfits and streetwear.", 199900L, "CLOTHING", 12),
                product("Performance Running Shorts", "Quick-dry running shorts designed for training and workouts.", 89900L, "CLOTHING", 27),
                product("HydroMax Steel Bottle", "Insulated stainless steel bottle for cold and hot drinks.", 89900L, "ACCESSORIES", 31),
                product("Classic Leather Wallet", "Slim leather wallet with multiple card slots.", 119900L, "ACCESSORIES", 18),
                product("Travel Backpack 25L", "Water-resistant backpack with laptop storage and multiple compartments.", 189900L, "BAGS", 15),
                product("FitTrack Smart Watch", "Fitness smartwatch with step tracking and heart-rate monitoring.", 349900L, "ELECTRONICS", 9),
                product("Wireless Bluetooth Headphones", "Over-ear wireless headphones with long battery life.", 279900L, "ELECTRONICS", 11),
                product("Compact Wireless Mouse", "Ergonomic wireless mouse for work and travel.", 79900L, "COMPUTER_ACCESSORIES", 25),
                product("Mechanical Gaming Keyboard", "Compact mechanical keyboard for gaming and productivity.", 229900L, "COMPUTER_ACCESSORIES", 8),
                product("USB-C Fast Charger", "Compact fast charger for USB-C phones and tablets.", 129900L, "ELECTRONICS", 24),
                product("Organic Green Tea", "Refreshing green tea for everyday consumption.", 49900L, "GROCERY", 42),
                product("Premium Coffee Beans", "Freshly roasted medium-dark coffee beans.", 69900L, "GROCERY", 28),
                product("Protein Energy Bar Pack", "High-protein snack bars for workouts and travel.", 79900L, "NUTRITION", 36),
                product("Instant Oats 1kg", "Whole-grain oats for breakfast and healthy meals.", 24900L, "GROCERY", 55),
                product("Portable USB Desk Lamp", "Adjustable LED desk lamp with multiple brightness levels.", 99900L, "HOME_OFFICE", 17),
                product("Ergonomic Laptop Stand", "Adjustable aluminum laptop stand for desk setups.", 149900L, "HOME_OFFICE", 13),
                product("Yoga Mat Pro", "Non-slip exercise mat for yoga and home workouts.", 109900L, "FITNESS", 20),
                product("Resistance Band Set", "Five resistance bands with different strengths.", 59900L, "FITNESS", 30)
        ));
    }

    private Product product(
            String title,
            String description,
            Long price,
            String category,
            Integer stock
    ) {
        return Product.builder()
                .title(title)
                .description(description)
                .priceInPaise(price)
                .currency("INR")
                .category(category)
                .stockQty(stock)
                .agentVisible(true)
                .build();
    }
}
