package com.monkmarket.agentservice.dto;

import java.util.List;

public record CatalogSearchIntent(

        String searchQuery,

        List<String> categories,

        boolean categoryOnly

) {
}