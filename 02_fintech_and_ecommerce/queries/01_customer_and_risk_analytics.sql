-- ============================================================================
-- Модуль 2: Fintech & E-commerce Data Platform
-- Скрипт 1: 01_customer_and_risk_analytics.sql
-- Тема: Клиентская аналитика, отток и анализ временных рядов (Anti-Join, Time-Series)
-- СУБД: PostgreSQL 15+
-- ============================================================================

/*
Задание 1
Отделу телемаркетинга необходимо запустить кампанию по реактивации неактивной аудитории. 
На основе таблиц клиентов (clients) и банковских счетов (accounts) выведите идентификатор клиента (client_id), 
полное имя (client_name), город (city) и дату регистрации (registration_date) для тех клиентов, 
которые зарегистрировались в системе, но до сих пор не открыли ни одного банковского счета.
Для реализации проверки обязательно используйте конструкцию LEFT JOIN.
*/
SELECT 
    c.client_id, 
    c.client_name, 
    c.city,
    c.registration_date
FROM clients c 
LEFT JOIN accounts a ON a.client_id = c.client_id
WHERE a.account_id IS NULL;


/*
Задание 2
Службе финансового мониторинга необходимо выявлять резкие единовременные списания денежных средств со счетов. 
На основе таблицы транзакций (transactions) для каждой операции снятия наличных ('withdrawal') 
выведите номер счета (account_id), дату операции (tx_date), текущую сумму списания (amount), 
а также сумму предыдущего списания по этому же счету (prev_withdrawal) и величину изменения расхода (withdrawal_diff). 
Расчет должен производиться строго раздельно для каждого счета в хронологическом порядке. 
Для получения предшествующих значений используйте оконную функцию LAG().
*/
SELECT 
    account_id, 
    tx_date, 
    amount AS current_withdrawal, 
    LAG(amount) OVER (
        PARTITION BY account_id 
        ORDER BY tx_date ASC
    ) AS prev_withdrawal,
    amount - LAG(amount) OVER (
        PARTITION BY account_id 
        ORDER BY tx_date ASC
    ) AS withdrawal_diff
FROM transactions
WHERE tx_type = 'withdrawal'
ORDER BY account_id, tx_date;


/*
Задание 3
Для оценки динамики накопления клиентского капитала сформируйте историю пополнений по каждому счету. 
На основе таблицы транзакций (transactions) выведите номер счета (account_id), дату операции (tx_date), 
сумму текущего пополнения (amount), а также вычисляемое поле cumulative_deposit_total, 
отражающее накопительный итог всех внесенных средств по данному счету от первой зафиксированной операции до текущей. 
В выборку должны попасть только операции пополнения ('deposit').
*/
SELECT 
    account_id, 
    tx_date, 
    amount AS deposit_amount, 
    SUM(amount) OVER (
        PARTITION BY account_id 
        ORDER BY tx_date ASC
    ) AS cumulative_deposit_total
FROM transactions
WHERE tx_type = 'deposit'
ORDER BY account_id, tx_date;


/*
Задание 4
Департаменту по работе с состоятельными клиентами необходимо сформировать пул кандидатов на премиальное обслуживание. 
На основе таблиц клиентов (clients), счетов (accounts) и транзакций (transactions) выведите идентификатор (client_id) 
и имя клиента (client_name), а также общую сумму внесенных им депозитов (total_deposits). 
В итоговый отчет включите только клиентов из города Москва, у которых суммарный объем пополнений 
по всем открытым счетам превысил 500 000 рублей. Результат отсортируйте по убыванию суммы депозитов.
*/
SELECT 
    c.client_id,
    c.client_name, 
    SUM(t.amount) AS total_deposits
FROM clients c 
JOIN accounts a ON a.client_id = c.client_id 
JOIN transactions t ON t.account_id = a.account_id
WHERE c.city = 'Москва' 
  AND t.tx_type = 'deposit'
GROUP BY c.client_id, c.client_name
HAVING SUM(t.amount) >= 500000.00
ORDER BY total_deposits DESC;
