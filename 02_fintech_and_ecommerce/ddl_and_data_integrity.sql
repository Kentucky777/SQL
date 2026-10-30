-- ============================================================================
-- Модуль 2: Fintech & E-commerce Data Platform
-- Скрипт 1: DDL, Ограничения целостности и Проектирование схемы (3НФ)
-- СУБД: PostgreSQL 14+
-- ============================================================================

-- 1. Схема банковского учета (Fintech Core)
-- Архитектура соответствует требованиям 3-й Нормальной Формы (3НФ):
-- каждое неключевое поле строго зависит только от первичного ключа.

DROP TABLE IF EXISTS transactions CASCADE;
DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS clients CASCADE;

-- Сущность "Клиенты банка"
CREATE TABLE clients (
    client_id         SERIAL PRIMARY KEY,
    client_name       VARCHAR(100) NOT NULL,
    city              VARCHAR(50) NOT NULL,
    email             VARCHAR(100) UNIQUE,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at        TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Сущность "Банковские счета"
CREATE TABLE accounts (
    account_id   SERIAL PRIMARY KEY,
    client_id    INTEGER NOT NULL,
    account_type VARCHAR(20) NOT NULL,
    currency     VARCHAR(3) NOT NULL DEFAULT 'RUB',
    is_active    BOOLEAN NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- Ссылочная целостность:
    CONSTRAINT fk_accounts_clients FOREIGN KEY (client_id) 
        REFERENCES clients(client_id) ON DELETE RESTRICT,
        
    -- Бизнес-валидация типов счетов:
    CONSTRAINT chk_account_type CHECK (account_type IN ('debit', 'credit', 'savings'))
);

-- Сущность "Банковские транзакции"
CREATE TABLE transactions (
    tx_id        BIGSERIAL PRIMARY KEY,
    account_id   INTEGER NOT NULL,
    tx_date      DATE NOT NULL,
    amount       NUMERIC(14, 2) NOT NULL,
    tx_type      VARCHAR(20) NOT NULL,
    description  TEXT,
    created_at   TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    -- Ограничение ссылочной целостности:
    CONSTRAINT fk_transactions_accounts FOREIGN KEY (account_id) 
        REFERENCES accounts(account_id) ON DELETE RESTRICT,
        
    -- Сумма транзакции строго положительна:
    CONSTRAINT chk_positive_amount CHECK (amount > 0),
    
    -- Валидация направления операции:
    CONSTRAINT chk_tx_type CHECK (tx_type IN ('deposit', 'withdrawal'))
);

-- Индексы для оптимизации поиска и аналитических оконных функций
CREATE INDEX idx_transactions_account_date ON transactions(account_id, tx_date);
CREATE INDEX idx_accounts_client ON accounts(client_id);
CREATE INDEX idx_clients_city ON clients(city);


-- 2. Схема электронного ретейла (E-commerce Core)
DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS customers CASCADE;

CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    city        VARCHAR(50) NOT NULL,
    phone       VARCHAR(20) UNIQUE
);

CREATE TABLE products (
    product_id   SERIAL PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category     VARCHAR(50) NOT NULL,
    price        NUMERIC(10, 2) NOT NULL,
    
    CONSTRAINT chk_product_price CHECK (price >= 0)
);

CREATE TABLE orders (
    order_id     SERIAL PRIMARY KEY,
    customer_id  INTEGER NOT NULL,
    order_date   DATE NOT NULL,
    total_amount NUMERIC(12, 2) NOT NULL DEFAULT 0.00,
    status       VARCHAR(30) NOT NULL,
    
    CONSTRAINT fk_orders_customers FOREIGN KEY (customer_id) 
        REFERENCES customers(customer_id) ON DELETE RESTRICT,
    CONSTRAINT chk_order_status CHECK (status IN ('processing', 'completed', 'completed'))
);

CREATE TABLE order_items (
    item_id    SERIAL PRIMARY KEY,
    order_id   INTEGER NOT NULL,
    product_id INTEGER NOT NULL,
    quantity   INTEGER NOT NULL,
    price      NUMERIC(10, 2) NOT NULL,
    
    CONSTRAINT fk_items_orders FOREIGN KEY (order_id) 
        REFERENCES orders(order_id) ON DELETE CASCADE,
    CONSTRAINT fk_items_products FOREIGN KEY (product_id) 
        REFERENCES products(product_id) ON DELETE RESTRICT,
    CONSTRAINT chk_item_quantity CHECK (quantity > 0),
    CONSTRAINT chk_item_price CHECK (price >= 0)
);

-- ============================================================================
-- 3. Демонстрационные данные (Seed Data)
-- ============================================================================

INSERT INTO clients (client_id, client_name, city, email, registration_date) VALUES
(1, 'Иванов Алексей Петрович', 'Москва', 'ivanov@mail.ru', '2026-01-10'),
(2, 'Петров Денис Игоревич', 'Москва', 'petrov@yandex.ru', '2026-02-15'),
(3, 'Смирнова Анна Сергеевна', 'Новосибирск', 'smirnova@gmail.com', '2026-03-01'),
(4, 'Кузнецов Максим Олегович', 'Новосибирск', 'kuznetsov@mail.ru', '2026-03-20'),
(5, 'Васильева Елена Павловна', 'Казань', 'vasilieva@bk.ru', '2026-04-05'),
(6, 'Дмитриев Сергей Викторович', 'Казань', 'dmitriev@mail.ru', '2026-04-12');

INSERT INTO accounts (account_id, client_id, account_type) VALUES
(101, 1, 'debit'),
(102, 1, 'savings'),
(103, 2, 'debit'),
(104, 3, 'debit'),
(105, 4, 'debit');
-- Клиенты 5 и 6 намеренно не имеют счетов (для Anti-Join кейсов)

INSERT INTO transactions (account_id, tx_date, amount, tx_type, description) VALUES
(101, '2026-05-01', 50000.00, 'deposit', 'Зарплатное зачисление'),
(101, '2026-05-03', 15000.00, 'withdrawal', 'Оплата услуг'),
(101, '2026-05-10', 32000.00, 'withdrawal', 'Аренда жилья'),
(101, '2026-05-20', 60000.00, 'deposit', 'Премиальная выплата'),
(101, '2026-05-25', 45000.00, 'withdrawal', 'Покупка техники'),
(102, '2026-05-02', 600000.00, 'deposit', 'Внесение вклада'),
(103, '2026-05-05', 120000.00, 'deposit', 'Перевод средств'),
(103, '2026-05-15', 70000.00, 'withdrawal', 'Снятие наличных'),
(104, '2026-05-01', 250000.00, 'deposit', 'Пополнение'),
(104, '2026-05-11', 80000.00, 'withdrawal', 'Расчеты по чеку'),
(105, '2026-05-04', 180000.00, 'deposit', 'Депозит');

INSERT INTO customers (customer_id, name, city) VALUES
(1, 'ООО Смарт-Сервис', 'Москва'),
(2, 'ИП Сидоров', 'Москва'),
(3, 'АО Сибирь-Тех', 'Новосибирск'),
(4, 'ООО Волга-Трейд', 'Казань'),
(5, 'Инновации Плюс', 'Казань');

INSERT INTO products (product_id, product_name, category, price) VALUES
(10, 'Ноутбук ThinkBook 15', 'Электроника', 85000.00),
(11, 'Смартфон Galaxy A54', 'Электроника', 32000.00),
(12, 'Монитор 27 IPS 2K', 'Электроника', 24000.00),
(13, 'Офисное кресло Ergonomic', 'Мебель', 18500.00),
(14, 'Стол с электроподъемом', 'Мебель', 42000.00),
(15, 'Кофемашина Professional', 'Бытовая техника', 65000.00);

INSERT INTO orders (order_id, customer_id, order_date, total_amount, status) VALUES
(1001, 1, '2026-05-01', 170000.00, 'completed'),
(1002, 1, '2026-05-15', 96000.00, 'completed'),
(1003, 2, '2026-05-10', 42000.00, 'completed'),
(1004, 3, '2026-05-02', 320000.00, 'completed'),
(1005, 3, '2026-05-18', 65000.00, 'completed'),
(1006, 4, '2026-05-05', 185000.00, 'completed'),
(1007, 4, '2026-05-06', 120000.00, 'completed'),
(1008, 4, '2026-05-07', 210000.00, 'completed');
-- Клиент 5 не имеет заказов (спящий клиент)

INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1001, 10, 2, 85000.00),
(1002, 11, 3, 32000.00),
(1003, 14, 1, 42000.00),
(1004, 11, 10, 32000.00),
(1005, 15, 1, 65000.00),
(1006, 13, 10, 18500.00),
(1007, 11, 3, 32000.00),
(1008, 10, 2, 85000.00);

