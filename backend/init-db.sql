
CREATE EXTENSION IF NOT EXISTS "pgcrypto";


CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(255) NOT NULL,
    description VARCHAR(2000),
    price_in_paise BIGINT NOT NULL,
    currency VARCHAR(20) NOT NULL,
    category VARCHAR(255) NOT NULL,
    stock_qty INTEGER NOT NULL,
    image_url VARCHAR(1000),
    agent_visible BOOLEAN NOT NULL
);



CREATE TABLE IF NOT EXISTS merchant_policy (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    max_order_amount_in_paise BIGINT NOT NULL,
    upsell_max_items INTEGER NOT NULL,
    human_confirm_above_amount_in_paise BIGINT NOT NULL,
    agent_enabled BOOLEAN NOT NULL
);

CREATE TABLE IF NOT EXISTS allowed_categories (
    policy_id UUID NOT NULL,
    category VARCHAR(255),
    CONSTRAINT fk_allowed_categories_policy
        FOREIGN KEY (policy_id)
        REFERENCES merchant_policy(id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_allowed_categories_policy
    ON allowed_categories(policy_id);



CREATE TABLE IF NOT EXISTS carts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    status VARCHAR(30) NOT NULL,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);


CREATE TABLE IF NOT EXISTS cart_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cart_id UUID NOT NULL,
    product_id UUID NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    price_snapshot_in_paise BIGINT NOT NULL,
    quantity INTEGER NOT NULL,
    image_url VARCHAR(1000),

    CONSTRAINT fk_cart_items_cart
        FOREIGN KEY (cart_id)
        REFERENCES carts(id)
        ON DELETE CASCADE,

    CONSTRAINT uk_cart_product
        UNIQUE (cart_id, product_id)
);

CREATE INDEX IF NOT EXISTS idx_cart_items_cart
    ON cart_items(cart_id);



CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    cart_id UUID NOT NULL,
    total_amount_in_paise BIGINT NOT NULL,
    currency VARCHAR(20) NOT NULL,
    status VARCHAR(40) NOT NULL,
    idempotency_key VARCHAR(255) UNIQUE,
    created_at TIMESTAMP NOT NULL,
    updated_at TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_orders_user_id
    ON orders(user_id);

CREATE INDEX IF NOT EXISTS idx_orders_created_at
    ON orders(created_at);



CREATE TABLE IF NOT EXISTS order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL,
    product_id UUID NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    price_in_paise BIGINT NOT NULL,
    quantity INTEGER NOT NULL,
    total_price_in_paise BIGINT NOT NULL,
    image_url VARCHAR(1000),

    CONSTRAINT fk_order_items_order
        FOREIGN KEY (order_id)
        REFERENCES orders(id)
        ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_order_items_order
    ON order_items(order_id);



CREATE TABLE IF NOT EXISTS payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    order_id UUID NOT NULL UNIQUE,

    user_id UUID NOT NULL,

    amount_in_paise BIGINT NOT NULL,

    currency VARCHAR(20) NOT NULL,

    status VARCHAR(30) NOT NULL,

    razorpay_order_id VARCHAR(255) UNIQUE,

    razorpay_payment_id VARCHAR(255),

    razorpay_signature TEXT,

    created_at TIMESTAMP NOT NULL,

    updated_at TIMESTAMP,

    expires_at TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_payments_user_id
    ON payments(user_id);

CREATE INDEX IF NOT EXISTS idx_payments_status
    ON payments(status);



CREATE TABLE IF NOT EXISTS processed_webhook_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    event_id VARCHAR(255) NOT NULL UNIQUE,

    event_type VARCHAR(255) NOT NULL,

    processed_at TIMESTAMP NOT NULL
);



CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID,

    action VARCHAR(50) NOT NULL,

    service VARCHAR(255) NOT NULL,

    resource_type VARCHAR(255),

    resource_id UUID,

    details VARCHAR(5000),

    ip_address VARCHAR(255),

    created_at TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id
    ON audit_logs(user_id);

CREATE INDEX IF NOT EXISTS idx_audit_logs_resource_id
    ON audit_logs(resource_id);

CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at
    ON audit_logs(created_at);



CREATE TABLE IF NOT EXISTS commerce_audit_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,

    order_id UUID,

    payment_id UUID,

    operation VARCHAR(60) NOT NULL,

    old_state VARCHAR(40),

    new_state VARCHAR(40),

    amount_in_paise BIGINT,

    currency VARCHAR(20),

    razorpay_order_id VARCHAR(255),

    razorpay_payment_id VARCHAR(255),

    success BOOLEAN NOT NULL,

    message TEXT,

    error_type VARCHAR(120),

    error_message TEXT,

    latency_ms BIGINT NOT NULL,

    created_at TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_commerce_audit_user
    ON commerce_audit_events(user_id);

CREATE INDEX IF NOT EXISTS idx_commerce_audit_order
    ON commerce_audit_events(order_id);

CREATE INDEX IF NOT EXISTS idx_commerce_audit_payment
    ON commerce_audit_events(payment_id);

CREATE INDEX IF NOT EXISTS idx_commerce_audit_created
    ON commerce_audit_events(created_at);



CREATE TABLE IF NOT EXISTS chat_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    user_id UUID NOT NULL,

    created_at TIMESTAMP NOT NULL,

    checkout_state VARCHAR(40) NOT NULL DEFAULT 'NONE',

    checkout_order_id UUID,

    checkout_payment_id UUID,

    checkout_razorpay_order_id VARCHAR(255),

    checkout_amount_in_paise BIGINT,

    checkout_currency VARCHAR(20),

    checkout_payment_status VARCHAR(30),

    pending_checkout_cart_id UUID,

    pending_checkout_idempotency_key VARCHAR(255),

    last_search_results_json TEXT,

    last_referenced_product_id UUID,

    updated_at TIMESTAMP NOT NULL,

    CONSTRAINT chat_sessions_checkout_state_check
        CHECK (
            checkout_state IN (
                'NONE',
                'CONFIRMATION_REQUIRED',
                'PAYMENT_REQUIRED',
                'PAYMENT_COMPLETED',
                'BLOCKED'
            )
        )
);

CREATE INDEX IF NOT EXISTS idx_chat_session_user_id
    ON chat_sessions(user_id);

CREATE INDEX IF NOT EXISTS idx_chat_session_updated_at
    ON chat_sessions(updated_at);


CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    session_id UUID NOT NULL,

    role VARCHAR(30) NOT NULL,

    content TEXT NOT NULL,

    tool_name VARCHAR(100),

    tool_input TEXT,

    tool_output TEXT,

    created_at TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_chat_message_session
    ON chat_messages(session_id);

CREATE INDEX IF NOT EXISTS idx_chat_message_created
    ON chat_messages(created_at);

CREATE TABLE IF NOT EXISTS agent_tool_audit_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    request_id UUID NOT NULL,

    user_id UUID NOT NULL,

    session_id UUID NOT NULL,

    event_type VARCHAR(50) NOT NULL,

    operation VARCHAR(150) NOT NULL,

    target_type VARCHAR(50),

    target_name VARCHAR(100),

    http_method VARCHAR(20),

    api_path VARCHAR(500),

    input_json TEXT,

    output_json TEXT,

    success BOOLEAN NOT NULL,

    error_type VARCHAR(255),

    error_message TEXT,

    latency_ms BIGINT NOT NULL,

    created_at TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_agent_tool_audit_request
    ON agent_tool_audit_events(request_id);

CREATE INDEX IF NOT EXISTS idx_agent_tool_audit_session
    ON agent_tool_audit_events(session_id);

CREATE INDEX IF NOT EXISTS idx_agent_tool_audit_user
    ON agent_tool_audit_events(user_id);

CREATE INDEX IF NOT EXISTS idx_agent_tool_audit_created
    ON agent_tool_audit_events(created_at);

CREATE TABLE IF NOT EXISTS agent_audit_events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    request_id UUID NOT NULL,

    user_id UUID NOT NULL,

    session_id UUID NOT NULL,

    event_type VARCHAR(50) NOT NULL,

    request_message TEXT,

    response_type VARCHAR(50),

    response_message TEXT,

    product_count INTEGER NOT NULL,

    recommendation_count INTEGER NOT NULL,

    cart_present BOOLEAN NOT NULL,

    checkout_present BOOLEAN NOT NULL,

    action_count INTEGER NOT NULL,

    success BOOLEAN NOT NULL,

    error_type VARCHAR(255),

    error_message TEXT,

    latency_ms BIGINT NOT NULL,

    created_at TIMESTAMP NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_agent_audit_request_id
    ON agent_audit_events(request_id);

CREATE INDEX IF NOT EXISTS idx_agent_audit_session_id
    ON agent_audit_events(session_id);

CREATE INDEX IF NOT EXISTS idx_agent_audit_user_id
    ON agent_audit_events(user_id);

CREATE INDEX IF NOT EXISTS idx_agent_audit_created_at
    ON agent_audit_events(created_at);


INSERT INTO merchant_policy (
    id,
    max_order_amount_in_paise,
    upsell_max_items,
    human_confirm_above_amount_in_paise,
    agent_enabled
)
SELECT
    gen_random_uuid(),
    500000,
    1,
    200000,
    TRUE
WHERE NOT EXISTS (
    SELECT 1
    FROM merchant_policy
);


INSERT INTO allowed_categories (
    policy_id,
    category
)
SELECT
    mp.id,
    categories.category
FROM (
    VALUES
        ('SHOES'),
        ('ACCESSORIES'),
        ('ELECTRONICS'),
        ('CLOTHING'),
        ('FITNESS'),
        ('GROCERY'),
        ('NUTRITION'),
        ('BAGS'),
        ('COMPUTER_ACCESSORIES'),
        ('HOME_OFFICE')
) AS categories(category)
CROSS JOIN (
    SELECT id
    FROM merchant_policy
    ORDER BY id
    LIMIT 1
) mp
WHERE NOT EXISTS (
    SELECT 1
    FROM allowed_categories ac
    WHERE ac.policy_id = mp.id
      AND ac.category = categories.category
);


INSERT INTO products (
    title,
    description,
    price_in_paise,
    currency,
    category,
    stock_qty,
    image_url,
    agent_visible
)
SELECT *
FROM (
    VALUES
    (
        'SprintX Running Shoes',
        'Lightweight running shoes designed for daily jogging and road running.',
        299900,
        'INR',
        'SHOES',
        18,
        'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'AeroRun Pro Sneakers',
        'Cushioned athletic sneakers for running, walking, and workouts.',
        249900,
        'INR',
        'SHOES',
        14,
        'https://images.unsplash.com/photo-1460353581641-37baddab0fa2?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'RoadRunner Lite Shoes',
        'Lightweight road-running shoes for beginners and daily jogging.',
        189900,
        'INR',
        'SHOES',
        22,
        'https://images.unsplash.com/photo-1552674605-db6ffd4facb5?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'Classic Cotton T-Shirt',
        'Soft regular-fit cotton t-shirt for everyday wear.',
        69900,
        'INR',
        'CLOTHING',
        40,
        'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'Urban Denim Jacket',
        'Classic denim jacket for casual outfits and streetwear.',
        199900,
        'INR',
        'CLOTHING',
        12,
        'https://images.unsplash.com/photo-1551028719-00167b16eac5?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'Performance Running Shorts',
        'Quick-dry running shorts designed for training and workouts.',
        89900,
        'INR',
        'CLOTHING',
        27,
        'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'HydroMax Steel Bottle',
        'Insulated stainless steel bottle for cold and hot drinks.',
        89900,
        'INR',
        'ACCESSORIES',
        31,
        'https://images.unsplash.com/photo-1602143407151-7111542de6e8?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'Classic Leather Wallet',
        'Slim leather wallet with multiple card slots.',
        119900,
        'INR',
        'ACCESSORIES',
        18,
        'https://images.unsplash.com/photo-1627123424574-724758594e93?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'Travel Backpack 25L',
        'Water-resistant backpack with laptop storage and multiple compartments.',
        189900,
        'INR',
        'BAGS',
        15,
        'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'FitTrack Smart Watch',
        'Fitness smartwatch with step tracking and heart-rate monitoring.',
        349900,
        'INR',
        'ELECTRONICS',
        9,
        'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'Wireless Bluetooth Headphones',
        'Over-ear wireless headphones with long battery life.',
        279900,
        'INR',
        'ELECTRONICS',
        11,
        'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'Compact Wireless Mouse',
        'Ergonomic wireless mouse for work and travel.',
        79900,
        'INR',
        'COMPUTER_ACCESSORIES',
        25,
        'https://images.unsplash.com/photo-1527814050087-3793815479db?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'Mechanical Gaming Keyboard',
        'Compact mechanical keyboard for gaming and productivity.',
        229900,
        'INR',
        'COMPUTER_ACCESSORIES',
        8,
        'https://images.unsplash.com/photo-1587829741301-dc798b83add3?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'USB-C Fast Charger',
        'Compact fast charger for USB-C phones and tablets.',
        129900,
        'INR',
        'ELECTRONICS',
        24,
        'https://images.unsplash.com/photo-1583863788434-e58a36330cf0?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'Organic Green Tea',
        'Refreshing green tea for everyday consumption.',
        49900,
        'INR',
        'GROCERY',
        42,
        'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'Premium Coffee Beans',
        'Freshly roasted medium-dark coffee beans.',
        69900,
        'INR',
        'GROCERY',
        28,
        'https://images.unsplash.com/photo-1447933601403-0c6688de566e?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'Protein Energy Bar Pack',
        'High-protein snack bars for workouts and travel.',
        79900,
        'INR',
        'NUTRITION',
        36,
        'https://images.unsplash.com/photo-1600185365483-26d7a4cc7519?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'Instant Oats 1kg',
        'Whole-grain oats for breakfast and healthy meals.',
        24900,
        'INR',
        'GROCERY',
        55,
        'https://images.unsplash.com/photo-1517673400267-0251440c45dc?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'Portable USB Desk Lamp',
        'Adjustable LED desk lamp with multiple brightness levels.',
        99900,
        'INR',
        'HOME_OFFICE',
        17,
        'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'Ergonomic Laptop Stand',
        'Adjustable aluminum laptop stand for desk setups.',
        149900,
        'INR',
        'HOME_OFFICE',
        13,
        'https://images.unsplash.com/photo-1527443224154-c4a3942d3acf?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'Yoga Mat Pro',
        'Non-slip exercise mat for yoga and home workouts.',
        109900,
        'INR',
        'FITNESS',
        20,
        'https://images.unsplash.com/photo-1592432678016-e910b452f9a2?auto=format&fit=crop&w=900&q=80',
        TRUE
    ),
    (
        'Resistance Band Set',
        'Five resistance bands with different strengths.',
        59900,
        'INR',
        'FITNESS',
        30,
        'https://images.unsplash.com/photo-1598289431512-b97b0917affc?auto=format&fit=crop&w=900&q=80',
        TRUE
    )
) AS seed(
    title,
    description,
    price_in_paise,
    currency,
    category,
    stock_qty,
    image_url,
    agent_visible
)
WHERE NOT EXISTS (
    SELECT 1
    FROM products p
    WHERE p.title = seed.title
);