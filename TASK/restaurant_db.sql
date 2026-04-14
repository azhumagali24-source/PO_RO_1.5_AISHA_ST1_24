-- ==========================================
-- CLEAN START (rerunnable script)
-- ==========================================
DROP SCHEMA IF EXISTS restaurant_schema CASCADE;
CREATE SCHEMA restaurant_schema;

-- ==========================================
-- BASE TABLES (no dependencies first)
-- ==========================================

-- Roles in system
CREATE TABLE restaurant_schema.role (
    role_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    created_at DATE DEFAULT CURRENT_DATE
);

-- Units for ingredients (kg, liter, etc.)
CREATE TABLE restaurant_schema.unit_of_measure (
    unit_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    unit_name VARCHAR(50) NOT NULL UNIQUE,
    created_at DATE DEFAULT CURRENT_DATE
);

-- Menu categories (Drinks, Food, etc.)
CREATE TABLE restaurant_schema.menu_category (
    category_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description VARCHAR(255)
);

-- Tables inside restaurant
CREATE TABLE restaurant_schema.restaurant_table (
    table_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    table_number INT NOT NULL UNIQUE,
    capacity INT NOT NULL CHECK (capacity > 0),
    location VARCHAR(50)
);

-- ==========================================
-- MAIN ENTITIES
-- ==========================================

-- Customers
CREATE TABLE restaurant_schema.customer (
    customer_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    
    gender VARCHAR(10) NOT NULL CHECK (gender IN ('Male','Female')),
    
    phone VARCHAR(20) UNIQUE,
    email VARCHAR(100) UNIQUE,
    
    created_at DATE DEFAULT CURRENT_DATE
);

-- Employees
CREATE TABLE restaurant_schema.employee (
    employee_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    
    role_id INT NOT NULL,
    
    phone VARCHAR(20) UNIQUE,
    
    hire_date DATE NOT NULL,
    
    salary DECIMAL(10,2) NOT NULL CHECK (salary >= 0),
    
    is_active BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (role_id)
        REFERENCES restaurant_schema.role(role_id)
        ON DELETE RESTRICT
);

-- Ingredients
CREATE TABLE restaurant_schema.ingredient (
    ingredient_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    
    ingredient_name VARCHAR(100) NOT NULL UNIQUE,
    
    unit_id INT NOT NULL,
    
    current_stock DECIMAL(10,2) NOT NULL CHECK (current_stock >= 0),
    reorder_level DECIMAL(10,2) NOT NULL CHECK (reorder_level >= 0),
    
    FOREIGN KEY (unit_id)
        REFERENCES restaurant_schema.unit_of_measure(unit_id)
);

-- ==========================================
-- MENU STRUCTURE
-- ==========================================

-- Menu items
CREATE TABLE restaurant_schema.menu_item (
    menu_item_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    
    category_id INT NOT NULL,
    
    name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    
    is_available BOOLEAN DEFAULT TRUE,
    
    FOREIGN KEY (category_id)
        REFERENCES restaurant_schema.menu_category(category_id)
        ON DELETE CASCADE
);

-- Ingredients used in menu items (M:N)
CREATE TABLE restaurant_schema.menu_item_ingredient (
    menu_item_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    
    quantity_required DECIMAL(10,2) NOT NULL CHECK (quantity_required > 0),
    
    PRIMARY KEY (menu_item_id, ingredient_id),
    
    FOREIGN KEY (menu_item_id)
        REFERENCES restaurant_schema.menu_item(menu_item_id)
        ON DELETE CASCADE,
        
    FOREIGN KEY (ingredient_id)
        REFERENCES restaurant_schema.ingredient(ingredient_id)
        ON DELETE CASCADE
);

-- ==========================================
-- RESERVATIONS
-- ==========================================

CREATE TABLE restaurant_schema.reservation (
    reservation_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    
    customer_id INT NOT NULL,
    table_id INT NOT NULL,
    
    reservation_date DATE NOT NULL CHECK (reservation_date >= CURRENT_DATE),
    
    guest_count INT NOT NULL CHECK (guest_count > 0),
    
    status VARCHAR(20) DEFAULT 'Booked'
        CHECK (status IN ('Booked','Cancelled','Completed')),
    
    FOREIGN KEY (customer_id)
        REFERENCES restaurant_schema.customer(customer_id)
        ON DELETE CASCADE,
        
    FOREIGN KEY (table_id)
        REFERENCES restaurant_schema.restaurant_table(table_id)
        ON DELETE CASCADE
);

-- ==========================================
-- ORDERS
-- ==========================================

CREATE TABLE restaurant_schema.orders (
    order_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    
    customer_id INT NOT NULL,
    employee_id INT NOT NULL,
    table_id INT,
    
    order_date DATE DEFAULT CURRENT_DATE,
    
    status VARCHAR(20) DEFAULT 'New'
        CHECK (status IN ('New','Preparing','Completed','Cancelled')),
    
    total_amount DECIMAL(10,2) DEFAULT 0 CHECK (total_amount >= 0),
    
    FOREIGN KEY (customer_id)
        REFERENCES restaurant_schema.customer(customer_id),
        
    FOREIGN KEY (employee_id)
        REFERENCES restaurant_schema.employee(employee_id),
        
    FOREIGN KEY (table_id)
        REFERENCES restaurant_schema.restaurant_table(table_id)
);

-- Order details
CREATE TABLE restaurant_schema.order_item (
    order_id INT NOT NULL,
    menu_item_id INT NOT NULL,
    
    quantity INT NOT NULL CHECK (quantity > 0),
    
    unit_price DECIMAL(10,2) NOT NULL CHECK (unit_price >= 0),
    
    PRIMARY KEY (order_id, menu_item_id),
    
    FOREIGN KEY (order_id)
        REFERENCES restaurant_schema.orders(order_id)
        ON DELETE CASCADE,
        
    FOREIGN KEY (menu_item_id)
        REFERENCES restaurant_schema.menu_item(menu_item_id)
);

-- ==========================================
-- PAYMENTS
-- ==========================================

CREATE TABLE restaurant_schema.payment (
    payment_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    
    order_id INT NOT NULL,
    
    payment_date DATE DEFAULT CURRENT_DATE,
    
    amount DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    
    payment_method VARCHAR(20),
    
    status VARCHAR(20) DEFAULT 'Completed',
    
    FOREIGN KEY (order_id)
        REFERENCES restaurant_schema.orders(order_id)
        ON DELETE CASCADE
);

-- ==========================================
-- INVENTORY LOG
-- ==========================================

CREATE TABLE restaurant_schema.inventory_transaction (
    transaction_id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    
    ingredient_id INT NOT NULL,
    
    transaction_date DATE DEFAULT CURRENT_DATE,
    
    quantity_change DECIMAL(10,2) NOT NULL,
    
    transaction_type VARCHAR(50),
    
    FOREIGN KEY (ingredient_id)
        REFERENCES restaurant_schema.ingredient(ingredient_id)
);