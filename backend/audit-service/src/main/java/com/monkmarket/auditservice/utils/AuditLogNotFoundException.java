
package com.monkmarket.auditservice.utils;

public class AuditLogNotFoundException
        extends RuntimeException {

    public AuditLogNotFoundException(String message) {
        super(message);
    }
}