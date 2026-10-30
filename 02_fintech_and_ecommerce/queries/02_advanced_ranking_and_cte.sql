-- ============================================================================
-- Модуль 2: Fintech & E-commerce Data Platform
-- Скрипт 2: 02_advanced_ranking_and_cte.sql
-- Тема: Сложные аналитические витрины, Ранжирование и Оконные агрегации (CTE)
-- СУБД: PostgreSQL 15+
-- ============================================================================

/*
Задание 1
Отделу закупок и логистики необходимо выявить товары-бестселлеры в каждой товарной категории для оптимизации неснижаемых остатков. 
На основе таблиц товаров (products), позиций заказа (order_items) и заказов (orders) 
найдите в рамках каждой категории ровно один товар с наибольшим суммарным количеством проданных единиц. 
Выведите название категории (category), наименование товара (product_name), общее число проданных штук (total_units_sold), 
а также суммарную выручку по этому товару (category_revenue). 
Учитывайте только завершенные заказы со статусом 'completed'. 
Запрос обязательно должен быть реализован через конструкцию WITH (CTE) и оконную функцию ROW_NUMBER().
*/
WITH category_sales_ranked AS (
    SELECT 
        p.category, 
        p.product_id,
        p.product_name, 
        SUM(oi.quantity) AS total_units_sold,
        SUM(oi.quantity * oi.price) AS category_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY p.category 
            ORDER BY SUM(oi.quantity) DESC
        ) AS sales_rank 
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status = 'completed'
    GROUP BY p.category, p.product_id, p.product_name
)
SELECT 
    category, 
    product_name, 
    total_units_sold,
    category_revenue
FROM category_sales_ranked
WHERE sales_rank = 1
ORDER BY total_units_sold DESC;


/*
Задание 2
Аналитической службе банка требуется определить крупнейшие финансовые операции в региональном разрезе. 
На основе таблиц клиентов (clients), счетов (accounts) и транзакций (transactions) определите для каждого города 
клиента, совершившего транзакцию с максимальной суммой. 
Выведите город (city), имя клиента (client_name), сумму рекордной операции (max_transaction_amount) и дату ее совершения (tx_date). 
В выборке должно остаться строго по одной операции для каждого города. 
Для реализации используйте обобщенное табличное выражение WITH и функцию ROW_NUMBER().
*/
WITH ranked_city_transactions AS (
    SELECT 
        c.city, 
        c.client_name, 
        t.amount,
        t.tx_date,
        ROW_NUMBER() OVER (
            PARTITION BY c.city 
            ORDER BY t.amount DESC
        ) AS rank_in_city
    FROM clients c
    JOIN accounts a ON a.client_id = c.client_id
    JOIN transactions t ON t.account_id = a.account_id
)
SELECT 
    city, 
    client_name, 
    amount AS max_transaction_amount,
    tx_date
FROM ranked_city_transactions
WHERE rank_in_city = 1
ORDER BY max_transaction_amount DESC;


/*
Задание 3
Финансово-экономический отдел изучает подневную динамику поступления выручки по ключевому хабу доставки в г. Казань. 
На основе таблиц заказов (orders) и клиентов (customers) рассчитайте суммарную ежедневную выручку (daily_revenue) 
по успешно оформленным заказам ('completed'). 
С помощью функции LAG() извлеките сумму выручки за предыдущий календарный день (prev_day_revenue), 
а также найдите абсолютный суточный прирост (revenue_growth_amount) и относительный темп прироста в процентах (revenue_growth_pct), 
округленный до двух знаков после запятой. При расчете процента предусмотрите защиту от деления на ноль с помощью функции NULLIF(). 
Результат выведите в хронологическом порядке.
*/
WITH daily_city_revenue AS (
    SELECT 
        o.order_date, 
        SUM(o.total_amount) AS daily_revenue 
    FROM orders o
    JOIN customers c ON c.customer_id = o.customer_id
    WHERE c.city = 'Казань' 
      AND o.status = 'completed'
    GROUP BY o.order_date
)
SELECT 
    order_date, 
    daily_revenue, 
    LAG(daily_revenue) OVER (ORDER BY order_date ASC) AS prev_day_revenue, 
    daily_revenue - LAG(daily_revenue) OVER (ORDER BY order_date ASC) AS revenue_growth_amount,
    ROUND(
        (daily_revenue - LAG(daily_revenue) OVER (ORDER BY order_date ASC)) 
        * 100.0 / NULLIF(LAG(daily_revenue) OVER (ORDER BY order_date ASC), 0), 
        2
    ) AS revenue_growth_pct
FROM daily_city_revenue
ORDER BY order_date ASC;


/*
Задание 4
Отделу продуктовой аналитики требуется оценить параметры первой успешной конверсии пользователей (First-Touch Attribution). 
На основе таблиц покупателей (customers) и заказов (orders) выведите идентификатор клиента (customer_id), 
имя (customer_name), номер первого оформленного им заказа (order_id), дату этой первой покупки (first_purchase_date) 
и ее чек (first_purchase_amount). 
Если у клиента имеется несколько заказов, в отчете должен остаться строго самый ранний заказ по дате. 
Для решения примените конструкцию WITH и оконную нумерацию строк.
*/
WITH first_orders AS (
    SELECT 
        c.customer_id,
        c.name AS customer_name,
        o.order_id,
        o.order_date,
        o.total_amount,
        ROW_NUMBER() OVER (
            PARTITION BY c.customer_id 
            ORDER BY o.order_date ASC
        ) AS order_sequence_num
    FROM customers c
    JOIN orders o ON o.customer_id = c.customer_id
    WHERE o.status = 'completed'
)
SELECT 
    customer_id,
    customer_name,
    order_id,
    order_date AS first_purchase_date,
    total_amount AS first_purchase_amount
FROM first_orders
WHERE order_sequence_num = 1
ORDER BY first_purchase_date ASC;
