package com.monkmarket.commerceservice.repository;

import com.monkmarket.commerceservice.model.ProcessedWebhookEvent;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.UUID;

public interface ProcessedWebhookEventRepository
        extends JpaRepository<ProcessedWebhookEvent, UUID> {

    boolean existsByEventId(String eventId);
}