package com.monkmarket.catalogservice.controller;

import com.monkmarket.catalogservice.dto.*;
import com.monkmarket.catalogservice.service.ProductService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/catalog/products")
@RequiredArgsConstructor
public class ProductController {

    private final ProductService productService;


    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    public ProductResponse createProduct(

            @Valid
            @RequestBody
            CreateProductRequest request
    ) {

        return productService.createProduct(request);
    }


    @GetMapping
    public List<ProductResponse> getAllProducts() {

        return productService.getAllProducts();
    }


    @GetMapping("/{id}")
    public ProductResponse getProduct(

            @PathVariable
            UUID id
    ) {

        return productService.getProductById(id);
    }


    @PutMapping("/{id}")
    public ProductResponse updateProduct(

            @PathVariable
            UUID id,

            @Valid
            @RequestBody
            UpdateProductRequest request
    ) {

        return productService.updateProduct(
                id,
                request
        );
    }


    @DeleteMapping("/{id}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void deleteProduct(

            @PathVariable
            UUID id
    ) {

        productService.deleteProduct(id);
    }
}