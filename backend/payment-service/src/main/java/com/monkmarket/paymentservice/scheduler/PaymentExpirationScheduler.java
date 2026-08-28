package com.monkmarket.paymentservice.scheduler;

import com.monkmarket.paymentservice.client.OrderClient;
import com.monkmarket.paymentservice.dto.PaymentStatus;
import com.monkmarket.paymentservice.model.Payment;
import com.monkmarket.paymentservice.repository.PaymentRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.List;

@Component
@RequiredArgsConstructor
@Slf4j
public class PaymentExpirationScheduler {

    private final PaymentRepository paymentRepository;
    private final OrderClient orderClient;

    @Scheduled(fixedRate = 60000)
    @Transactional
    public void expirePayments() {

        List<Payment> payments =
                paymentRepository
                        .findByStatusAndExpiresAtBefore(
                                PaymentStatus.CREATED,
                                LocalDateTime.now()
                        );

        for (Payment payment : payments) {

            try {

                orderClient.expireOrder(
                        payment.getOrderId()
                );

                payment.setStatus(
                        PaymentStatus.EXPIRED
                );

                payment.setUpdatedAt(
                        LocalDateTime.now()
                );

                paymentRepository.save(payment);

                log.info(
                        "Expired payment {}",
                        payment.getId()
                );

            } catch (Exception e) {

                log.error(
                        "Could not expire payment {}",
                        payment.getId(),
                        e
                );
            }
        }
    }
}