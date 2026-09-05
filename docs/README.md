# 🛍️ MonkMarket

### Sahayak · AI-Powered Agentic Commerce

<p align="center">
  <strong>Tell it what you want. Let it handle the rest.</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter"/>
  <img src="https://img.shields.io/badge/Spring%20Boot-6DB33F?style=for-the-badge&logo=springboot&logoColor=white" alt="Spring Boot"/>
  <img src="https://img.shields.io/badge/Google%20Gemini-8E75B2?style=for-the-badge&logo=google&logoColor=white" alt="Gemini"/>
  <img src="https://img.shields.io/badge/PostgreSQL-4169E1?style=for-the-badge&logo=postgresql&logoColor=white" alt="PostgreSQL"/>
  <img src="https://img.shields.io/badge/Razorpay-3395FF?style=for-the-badge&logo=razorpay&logoColor=white" alt="Razorpay"/>
</p>

<p align="center">
  <em>An AI-native commerce platform where natural language becomes a controlled commerce action.</em>
</p>

## 💡 The Idea

Traditional e-commerce still asks users to translate their intent into clicks:

```text
Search → Product Page → Compare → Cart → Checkout → Payment
```

MonkMarket changes the interaction model:

```text
User Intent
     ↓
Sahayak
     ↓
Understand + Search + Recommend
     ↓
Cart
     ↓
Guardrails
     ↓
Checkout
     ↓
Razorpay
```

Instead of asking:

> "What should I click next?"

MonkMarket asks:

> **"What are you trying to accomplish?"**

---

# 🤖 Meet Sahayak

**Sahayak** is the AI shopping assistant at the center of MonkMarket.

Users can interact using normal language:

```text
"I need something I can wear on my wrist."

"Why do you recommend this one?"

"Add one of those to my cart."

"Actually, make that three."

"Proceed to checkout."
```

Sahayak can:

| Capability                | What it does                               |
| ------------------------- | ------------------------------------------ |
| 🔎 Product Search         | Finds products from the live catalog       |
| 📦 Product Information    | Retrieves real product details             |
| 🎯 Recommendations        | Suggests relevant products                 |
| 🧩 Complementary Products | Suggests useful additions                  |
| 🛒 Cart Operations        | Add, update, remove and inspect cart items |
| 💳 Checkout               | Initiates a controlled checkout flow       |
| 🧠 Context                | Understands conversational references      |

---

# 🏗️ Architecture

![System Architecture](docs/architecture/system-architecture.png)

### Backend Services

```text
                       ┌───────────────────┐
                       │   Flutter Apps    │
                       │ Shopper + Merchant│
                       └─────────┬─────────┘
                                 │
                                 ▼
                       ┌───────────────────┐
                       │  Gateway Service  │
                       │      :8080        │
                       └─────────┬─────────┘
                                 │
              ┌──────────────────┼──────────────────┐
              │                  │                  │
              ▼                  ▼                  ▼
      ┌──────────────┐   ┌──────────────┐   ┌──────────────┐
      │   Identity   │   │   Commerce   │   │    Agent     │
      │    :8081     │   │    :8082     │   │    :8083     │
      └──────────────┘   └──────┬───────┘   └──────┬───────┘
                                 │                  │
                    ┌────────────┼─────────┐        ▼
                    │            │         │     Gemini
                    ▼            ▼         ▼
                 Catalog       Cart      Order
                                             │
                                             ▼
                                          Payment
                                             │
                                             ▼
                                          Razorpay

                         PostgreSQL
```

### Services

- **Service Registry** · Eureka-based service discovery
- **Gateway Service** · Central API entry point and routing
- **Identity Service** · Authentication, users and JWT
- **Commerce Service** · Catalog, cart, orders, payments, merchant features, guardrails and audit
- **Agent Service** · Sahayak, Gemini, tool calling and conversation context

---

# 🧠 How Sahayak Works

![AI Workflow](docs/workflows/ai-agent-workflow.png)

```text
User Message
     ↓
Flutter
     ↓
Gateway
     ↓
Agent Service
     ↓
Spring AI + Gemini
     ↓
Intent / Tool Selection
     ↓
Controlled Tool
     ↓
Commerce Service
     ↓
Real Backend Data
     ↓
Tool Result
     ↓
Gemini
     ↓
Natural Language Response
     ↓
User
```

### Core principle

> **Gemini reasons and proposes actions. The backend validates and executes them.**

The AI does not receive unrestricted access to the application's data.

---

# 🔧 AI Tools

Sahayak interacts with the commerce backend through predefined tools.

```text
searchProducts()
getProductDetails()
addToCart()
updateCart()
getCart()
checkout()
getOrderStatus()
```

This creates a controlled boundary between:

```text
AI Reasoning
     │
     ▼
Tool Call
     │
     ▼
Backend Validation
     │
     ▼
Business Operation
```

---

# 🧠 Conversation Context

Shopping conversations are not isolated requests.

A user may say:

> "Show me a smartwatch."

Then:

> "Add one of those."

Then:

> "Make that three."

Sahayak maintains contextual information such as:

```text
Conversation
├── Recent Messages
├── Referenced Products
├── Current Cart
├── Current Intent
└── Conversation Summary
```

The backend remains the source of truth for:

```text
Products
Cart
Orders
Payments
Merchant Policies
```

The model is used for understanding and orchestration, not as the authoritative database.

---

# 🔐 Security & Guardrails

Giving an AI the ability to perform commerce actions requires strict boundaries.

MonkMarket uses merchant-defined guardrails such as:

- Maximum checkout amount
- Allowed product categories
- Human confirmation requirements
- AI-assisted checkout limits
- Upsell limits

![Guardrail Workflow](docs/workflows/guardrail-workflow.png)

```text
AI Action
    ↓
Guardrail Validation
    ├── ✅ PASS → Execute
    ├── ❌ BLOCK → Explain Reason
    └── ⚠️ CONFIRM → Ask User
```

### Defense in depth

Even when the AI requests an action, the backend validates the operation before execution.

> **The AI cannot override merchant-defined rules.**

---

# 💳 Payment

![Payment Workflow](docs/workflows/payment-workflow.png)

Sahayak **does not directly process the customer's payment credentials**.

The flow is:

```text
Checkout Request
       ↓
Guardrail Validation
       ↓
Commerce Service
       ↓
Razorpay
       ↓
Flutter Payment UI
       ↓
Customer Authorizes Payment
       ↓
Razorpay Webhook
       ↓
Backend Verification
       ↓
Order Status
```

The AI does not handle:

```text
❌ Card Number
❌ CVV
❌ UPI PIN
❌ OTP
```

Razorpay handles the payment experience and the customer authorizes the transaction.

---

# 📋 Audit Trail

![Audit Workflow](docs/workflows/audit-workflow.png)

Important AI and commerce actions are recorded for traceability.

An audit event can contain:

```text
Actor
Action
Timestamp
Input Summary
AI Rationale
Guardrail Checks
Outcome
```

Example:

```text
Actor:       AI
Action:      CHECKOUT
Amount:      ₹10,497

Guardrail:
MAX_ORDER_AMOUNT

Result:
BLOCKED

Reason:
Exceeded merchant limit of ₹5,000
```

This makes the system explainable:

> **What happened? Why did it happen? Was it allowed? What was the result?**

---

# 🛒 Commerce Flow

![Traditional vs MonkMarket](docs/workflows/traditional-vs-monkmarket.png)

### Traditional

```text
Search
  ↓
Select
  ↓
Cart
  ↓
Checkout
  ↓
Payment
```

### MonkMarket

```text
Natural Language
      ↓
Sahayak
      ↓
Product Discovery
      ↓
Recommendation
      ↓
Cart
      ↓
Guardrails
      ↓
Checkout
      ↓
Razorpay
```

---

# 🤝 Agentic Commerce

MonkMarket is not limited to a human-facing chatbot.

Commerce capabilities can also be exposed through structured APIs for an external AI buyer.

```text
External AI Buyer
       ↓
Catalog API
       ↓
Product Selection
       ↓
Cart API
       ↓
Guardrails
       ↓
Checkout API
       ↓
Order
```

This allows an external agent to interact with the merchant's commerce system without navigating the Flutter interface.

---

# 🏪 Merchant Experience

The merchant application provides visibility and control over the commerce system.

```text
Merchant
   ↓
Dashboard
   ├── Products
   ├── Orders
   ├── Policies / Guardrails
   └── Audit Logs
```

The merchant remains in control of the rules that constrain AI-assisted commerce.

---

# 📱 Application

### Sahayak Chat

![Sahayak Chat](docs/screenshots/shopper-chat.png)

### Cart

![Cart](docs/screenshots/cart.png)

### Checkout

![Checkout](docs/screenshots/checkout.png)

### Razorpay

![Razorpay Checkout](docs/screenshots/razorpay.png)

### Payment Failure

![Payment Failure](docs/screenshots/payment-failure.png)

### Merchant Dashboard

![Merchant Dashboard](docs/screenshots/merchant-dashboard.png)

### Audit Log

![Audit Log 1](docs/screenshots/audit-log.png)
![Audit Log 2](docs/screenshots/audit-log-2.png)

---

# 🧰 Technology Stack

### Frontend

- Flutter / Dart
- Dio
- GoRouter
- Application state management
- Razorpay Flutter integration

### Backend

- Java
- Spring Boot
- Spring Cloud Gateway
- Netflix Eureka
- Spring Security
- JWT
- Spring AI
- Google Gemini

### Data & Payments

- PostgreSQL
- Razorpay

### Infrastructure

- Docker
- Docker Compose
- Maven
- Git / GitHub

---

# 📁 Project Structure

```text
MonkMarket/
│
├── backend/
│   ├── service-registry/
│   ├── gateway-service/
│   ├── identity-service/
│   ├── commerce-service/
│   └── agent-service/
│
├── shopper-app/
├── merchant-app/
│
├── docs/
│   ├── architecture/
│   ├── workflows/
│   ├── screenshots/
│   └── technical/
│
├── docker-compose.yml
└── README.md
```

---

# 🚀 Running Locally

## Prerequisites

- Java
- Maven
- Flutter SDK
- Docker
- PostgreSQL
- Git

## Start Infrastructure

```bash
docker compose up -d
```

## Start Backend

Start the services:

```text
1. service-registry
2. gateway-service
3. identity-service
4. commerce-service
5. agent-service
```

## Run Flutter

```bash
flutter pub get
flutter run
```

Configure the required environment variables before starting the services.

---

# ⚙️ Environment Variables

Do not commit secrets.

Example:

```env
DB_URL=
DB_USERNAME=
DB_PASSWORD=

JWT_SECRET=

GEMINI_API_KEY=

RAZORPAY_KEY_ID=
RAZORPAY_KEY_SECRET=
RAZORPAY_WEBHOOK_SECRET=
```

Use a local `.env` or environment configuration for real credentials.

---

# 🧪 Failure Handling

MonkMarket also handles unsuccessful operations explicitly.

Example payment flow:

```text
Payment Attempt
      ↓
   Failure
      ↓
Update Order / Payment State
      ↓
Inform User
      ↓
Retry or Continue Shopping
      ↓
Audit Event
```

The system does not treat an AI-generated success message as proof that a payment succeeded.

The final payment state comes from the backend payment flow.

---

# 🧩 Challenges & Learnings

## Learning and Integrating Webhooks

Payment webhooks were a new concept for me when I started implementing the Razorpay payment system.

I had to understand asynchronous payment events, backend verification, and how Razorpay communicates payment status back to the application.

I learned the webhook flow and integrated the payment system with Spring Boot within a day. Razorpay's documentation made the process much easier to understand and implement.

## AI Context & Tool Execution

Another challenge was making the AI reliable during natural-language conversations.

Users may say:

> "Add one of those."

or:

> "Make that three."

without repeating the product name.

I encountered situations where the AI lost context or failed to map natural-language descriptions to the correct product.

I worked on improving tool definitions, conversation context, and structured product/cart information while keeping the actual commerce state in the backend.

---

# 🔮 Future Improvements

- Stronger semantic product search
- Vector-based retrieval for larger catalogs
- More advanced personalization
- Multi-merchant support
- Multi-language support
- Expanded AI-buyer workflows
- Deeper analytics and observability

---

# 🎯 Core Principle

```text
Make commerce conversational
        +
Keep AI actions controlled
        +
Validate before execution
        +
Keep payments customer-authorized
        +
Make important actions auditable
```

> **MonkMarket turns commerce from a sequence of clicks into a controlled conversation.**

<p align="center">
  <strong>MonkMarket · Sahayak</strong><br/>
  <em>Shop smarter. Just ask.</em>
</p>
