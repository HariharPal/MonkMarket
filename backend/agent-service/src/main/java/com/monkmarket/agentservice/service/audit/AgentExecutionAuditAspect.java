package com.monkmarket.agentservice.service.audit;

import com.monkmarket.agentservice.service.AgentToolAuditService;
import com.monkmarket.agentservice.service.AgentTurnContext;
import lombok.RequiredArgsConstructor;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.*;
import org.aspectj.lang.reflect.MethodSignature;
import org.springframework.ai.tool.annotation.Tool;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

@Aspect
@Component
@RequiredArgsConstructor
public class AgentExecutionAuditAspect {

    private final AgentToolAuditService auditService;
    private final AgentTurnContext turnContext;

    @Around("@annotation(tool)")
    public Object auditAgentTool(
            ProceedingJoinPoint joinPoint,
            Tool tool
    ) throws Throwable {

        UUID requestId =
                turnContext.getRequestId();

        if (requestId == null) {
            return joinPoint.proceed();
        }

        long start =
                System.nanoTime();

        Object input =
                buildArguments(
                        joinPoint.getArgs()
                );

        try {

            Object output =
                    joinPoint.proceed();

            auditService.recordSuccess(
                    requestId,
                    turnContext.getUserId(),
                    turnContext.getSessionId(),
                    "TOOL_CALL",
                    tool.name(),
                    "AGENT_TOOL",
                    tool.name(),
                    null,
                    null,
                    input,
                    output,
                    elapsedMs(start)
            );

            return output;

        } catch (Throwable throwable) {

            auditService.recordFailure(
                    requestId,
                    turnContext.getUserId(),
                    turnContext.getSessionId(),
                    "TOOL_CALL",
                    tool.name(),
                    "AGENT_TOOL",
                    tool.name(),
                    null,
                    null,
                    input,
                    throwable,
                    elapsedMs(start)
            );

            throw throwable;
        }
    }


    @Around(
            "execution(public * com.monkmarket.agentservice.client.CommerceClient.*(..))"
    )
    public Object auditCommerceClient(
            ProceedingJoinPoint joinPoint
    ) throws Throwable {

        UUID requestId =
                turnContext.getRequestId();

        if (requestId == null) {
            return joinPoint.proceed();
        }

        Method method =
                ((MethodSignature)
                        joinPoint.getSignature())
                        .getMethod();

        AuditedCommerceOperation annotation =
                method.getAnnotation(
                        AuditedCommerceOperation.class
                );

        long start =
                System.nanoTime();

        Object input =
                buildArguments(
                        joinPoint.getArgs()
                );

        String operationName =
                method.getName();

        String httpMethod = null;
        String apiPath = null;

        if (annotation != null) {

            httpMethod =
                    annotation.method();

            apiPath =
                    annotation.path();
        }

        System.out.println(
                "COMMERCE AUDIT START"
                        + " operation="
                        + operationName
                        + " method="
                        + httpMethod
                        + " path="
                        + apiPath
        );

        try {

            Object output =
                    joinPoint.proceed();

            auditService.recordSuccess(
                    requestId,
                    turnContext.getUserId(),
                    turnContext.getSessionId(),
                    "COMMERCE_API_CALL",
                    operationName,
                    "COMMERCE_SERVICE",
                    operationName,
                    httpMethod,
                    apiPath,
                    input,
                    output,
                    elapsedMs(start)
            );

            System.out.println(
                    "COMMERCE AUDIT SUCCESS"
                            + " operation="
                            + operationName
            );

            return output;

        } catch (Throwable throwable) {

            auditService.recordFailure(
                    requestId,
                    turnContext.getUserId(),
                    turnContext.getSessionId(),
                    "COMMERCE_API_CALL",
                    operationName,
                    "COMMERCE_SERVICE",
                    operationName,
                    httpMethod,
                    apiPath,
                    input,
                    throwable,
                    elapsedMs(start)
            );

            System.err.println(
                    "COMMERCE AUDIT FAILURE"
                            + " operation="
                            + operationName
                            + " error="
                            + throwable.getMessage()
            );

            throw throwable;
        }
    }

    private Map<String, Object> buildArguments(
            Object[] args
    ) {

        Map<String, Object> result =
                new LinkedHashMap<>();

        if (args == null) {
            return result;
        }

        for (int i = 0; i < args.length; i++) {

            Object arg =
                    args[i];

            if (arg instanceof
                    org.springframework.ai.chat.model.ToolContext) {

                continue;
            }

            result.put(
                    "arg" + i,
                    arg
            );
        }

        return result;
    }

    private long elapsedMs(
            long start
    ) {

        return (
                System.nanoTime() - start
        ) / 1_000_000;
    }
}