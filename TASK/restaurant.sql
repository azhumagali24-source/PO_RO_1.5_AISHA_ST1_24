-- =========================
-- CREATE SCHEMA
-- =========================
CREATE SCHEMA IF NOT EXISTS restaurant_schema;

SET search_path TO restaurant_schema;

-- =========================
-- CUSTOMER
-- =========================
CREATE TABLE IF NOT EXISTS customer (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(100) UNIQUE,
    created_at DATE NOT NULL DEFAULT CURRENT_DATE
);

-- =========================
-- EMPLOYEE
-- =========================
CREATE TABLE IF NOT EXISTS employee (
    employee_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role VARCHAR(50) NOT NULL,
    hire_date DATE NOT NULL CHECK (hire_date > '2026-01-01'),
    salary NUMERIC(10,2) CHECK (salary > 0),
    is_active BOOLEAN DEFAULT TRUE
);

-- =========================
-- RESTAURANT TABLE
-- =========================
CREATE TABLE IF NOT EXISTS restaurant_table (
    table_id SERIAL PRIMARY KEY,
    table_number INT UNIQUE NOT NULL,
    capacity INT CHECK (capacity > 0),
    location VARCHAR(50)
);

-- =========================
-- RESERVATION
-- =========================
CREATE TABLE IF NOT EXISTS reservation (
    reservation_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    table_id INT NOT NULL,
    reservation_date DATE NOT NULL CHECK (reservation_date > '2026-01-01'),
    guest_count INT CHECK (guest_count > 0),
    status VARCHAR(20) DEFAULT 'Booked',

    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (table_id) REFERENCES restaurant_table(table_id)
);

-- =========================
-- ORDERS
-- =========================
CREATE TABLE IF NOT EXISTS orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL,
    employee_id INT,
    order_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20),
    total_amount NUMERIC(10,2) CHECK (total_amount >= 0),

    FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
);

-- =========================
-- MENU CATEGORY
-- =========================
CREATE TABLE IF NOT EXISTS menu_category (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- =========================
-- MENU ITEM
-- =========================
CREATE TABLE IF NOT EXISTS menu_item (
    menu_item_id SERIAL PRIMARY KEY,
    category_id INT,
    name VARCHAR(100) NOT NULL,
    price NUMERIC(10,2) CHECK (price > 0),
    is_available BOOLEAN DEFAULT TRUE,

    FOREIGN KEY (category_id) REFERENCES menu_category(category_id)
);

-- =========================
-- ORDER ITEM
-- =========================
CREATE TABLE IF NOT EXISTS order_item (
    order_id INT,
    menu_item_id INT,
    quantity INT CHECK (quantity > 0),
    price NUMERIC(10,2) CHECK (price > 0),

    PRIMARY KEY (order_id, menu_item_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (menu_item_id) REFERENCES menu_item(menu_item_id)
);
-- =========================
-- PAYMENT
-- =========================
CREATE TABLE IF NOT EXISTS payment (
    payment_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    payment_date DATE DEFAULT CURRENT_DATE,
    amount NUMERIC(10,2) CHECK (amount > 0),
    method VARCHAR(50),
    status VARCHAR(20) DEFAULT 'Completed',

    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- =========================
-- INGREDIENT
-- =========================
CREATE TABLE IF NOT EXISTS ingredient (
    ingredient_id SERIAL PRIMARY KEY,
    name VARCHAR(100) UNIQUE NOT NULL,
    unit VARCHAR(20),
    current_stock NUMERIC(10,2) CHECK (current_stock >= 0),
    reorder_level NUMERIC(10,2) CHECK (reorder_level >= 0)
);

-- =========================
-- MENU INGREDIENT (many-to-many)
-- =========================
CREATE TABLE IF NOT EXISTS menu_ingredient (
    menu_item_id INT,
    ingredient_id INT,
    quantity_required NUMERIC(10,2) CHECK (quantity_required > 0),

    PRIMARY KEY (menu_item_id, ingredient_id),
    FOREIGN KEY (menu_item_id) REFERENCES menu_item(menu_item_id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredient(ingredient_id)
);

-- =========================
-- INVENTORY TRANSACTION
-- =========================
CREATE TABLE IF NOT EXISTS inventory_transaction (
    transaction_id SERIAL PRIMARY KEY,
    ingredient_id INT NOT NULL,
    transaction_date DATE DEFAULT CURRENT_DATE,
    quantity_change NUMERIC(10,2) NOT NULL,
    transaction_type VARCHAR(50) NOT NULL,
    reference_order_id INT,

    FOREIGN KEY (ingredient_id) REFERENCES ingredient(ingredient_id),
    FOREIGN KEY (reference_order_id) REFERENCES orders(order_id)
);