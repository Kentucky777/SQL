# 💳 Fintech & E-commerce Data Analytics Platform

Модуль реляционного моделирования и сквозной бизнес-аналитики для финансовых и ретейл-платформ в среде **PostgreSQL**.

---

## 📌 Описание бизнес-домена и архитектуры
Модуль содержит две взаимосвязанные модели предметных областей:
1. **Fintech Core (Банковский процессинг):** сущности клиентов, расчетных/депозитных счетов и транзакций с поддержкой целостности финансовых проводок.
2. **E-commerce Core (Электронная коммерция):** цепочка оформления заказов, детализация чеков по товарным позициям и управление каталогом.

Архитектура базы данных спроектирована в строгом соответствии с **3-й Нормальной Формой (3НФ)**, исключая транзитивные функциональные зависимости и избыточность хранения.

---

## 🛠 Реализованные технические компетенции
* **Реляционная целостность (Data Integrity):** реализация первичных (`PRIMARY KEY`) и внешних (`FOREIGN KEY`) ключей, строгих ограничений диапазонов (`CHECK (amount > 0)`).
* **Аналитические оконные функции (Window Functions):**
  * `ROW_NUMBER()` и `DENSE_RANK()` с секционированием (`PARTITION BY`) для нахождения лидеров в группах (Top-1 / Best-sellers).
  * `LAG()` / `LEAD()` для анализа временных рядов (Day-over-Day прирост выручки и аудит скачков расходов).
  * Накопительная кумулятивная агрегация (`SUM() OVER (ORDER BY ...)`).
* **Продвинутый синтаксис SQL:**
  * Обобщенные табличные выражения (`WITH` / CTE) для построения легко читаемых аналитических пайплайнов.
  * Anti-Join паттерны (`LEFT JOIN ... WHERE right.id IS NULL`) для выявления оттока.
  * Безопасные математические расчеты с защитой от деления на ноль (`NULLIF`).

---

## 📂 Структура файлов модуля
| Файл | Содержание и назначение |
| :--- | :--- |
| **`ddl_and_data_integrity.sql`** | DDL-скрипт развертывания таблиц, ограничений, индексов и тестового датасета. |
| **`01_customer_and_risk_analytics.sql`** | Запросы для поиска спящих клиентов, фрод-мониторинга расходов (DoD) и накопительных балансов. |
| **`02_advanced_ranking_and_cte.sql`** | Комплексные CTE-пайплайны: определение бестселлеров в категориях, динамика выручки и атрибуция первых заказов. |

---

## 📊 Ключевые аналитические кейсы

### 1. Выявление бестселлеров в категориях (CTE + ROW_NUMBER)
Двухшаговый конвейер: предварительная условная агрегация проданных штук по каждому товару с последующим ранжированием внутри категории:
```sql
WITH category_sales_ranked AS (
    SELECT 
        p.category, 
        p.product_name, 
        SUM(oi.quantity) AS total_units_sold,
        ROW_NUMBER() OVER (
            PARTITION BY p.category 
            ORDER BY SUM(oi.quantity) DESC
        ) AS sales_rank 
    FROM products p
    JOIN order_items oi ON oi.product_id = p.product_id
    JOIN orders o ON o.order_id = oi.order_id
    WHERE o.status = 'completed'
    GROUP BY p.category, p.product_name
)
SELECT category, product_name, total_units_sold
FROM category_sales_ranked
WHERE sales_rank = 1;
```

### 2. Мониторинг аномальных скачков списаний (LAG)
Изоляция временных рядов по банковским счетам для вычисления финансовой дельты между смежными расходными операциями:
```sql
SELECT 
    account_id, 
    tx_date, 
    amount AS current_withdrawal, 
    amount - LAG(amount) OVER (
        PARTITION BY account_id 
        ORDER BY tx_date ASC
    ) AS withdrawal_diff
FROM transactions
WHERE tx_type = 'withdrawal';
```
