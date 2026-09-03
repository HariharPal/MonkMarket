package com.monkmarket.agentservice.service.audit;

import java.lang.annotation.*;

@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface AuditedCommerceOperation {

    String method();

    String path();
}