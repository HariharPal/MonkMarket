package com.monkmarket.commerceservice.service;

import com.monkmarket.commerceservice.model.Payment;
import com.monkmarket.commerceservice.model.PaymentStatus;
import com.monkmarket.commerceservice.repository.PaymentRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Component
@RequiredArgsConstructor
public class PaymentExpirationScheduler {

    private final PaymentRepository paymentRepository;
    private final OrderService orderService;

    @Scheduled(fixedRate = 60000)
    @Transactional
    public void expirePayments() {
        List<Payment> payments = paymentRepository
                .findByStatusAndExpiresAtBefore(
                        PaymentStatus.CREATED,
                        LocalDateTime.now()
                );

        for (Payment payment : payments) {
            orderService.expireOrder(payment.getOrderId());
            payment.setStatus(PaymentStatus.EXPIRED);
            payment.setUpdatedAt(LocalDateTime.now());
            paymentRepository.save(payment);
        }
    }
}
