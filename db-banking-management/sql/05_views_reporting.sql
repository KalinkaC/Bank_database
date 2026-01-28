
-- Warstwa faktów: wszystkie aktywne produkty klientów (konta, pożyczki, lokaty, karty)
CREATE VIEW reporting.v_customer_product_facts AS
SELECT
    account_holder.customer_id,
    'ACCOUNT' AS product_type,
    account.opened_at AS product_start_date
FROM bank_products.account_holders AS account_holder
JOIN bank_products.accounts AS account
    ON account_holder.account_id = account.account_id
WHERE account.status = 'ACTIVE'
  AND account_holder.status_customer = 'ACTIVE'

UNION ALL

SELECT
    account_holder.customer_id,
    'LOAN' AS product_type,
    loan.start_date::timestamptz AS product_start_date
FROM bank_products.loans AS loan
JOIN bank_products.account_holders AS account_holder
    ON loan.account_id = account_holder.account_id
WHERE loan.status = 'ACTIVE'

UNION ALL

SELECT
    account_holder.customer_id,
    'DEPOSIT' AS product_type,
    deposit.start_date::timestamptz AS product_start_date
FROM bank_products.deposits AS deposit
JOIN bank_products.account_holders AS account_holder
    ON deposit.account_id = account_holder.account_id
WHERE deposit.status = 'ACTIVE'

UNION ALL

SELECT
    account_holder.customer_id,
    'CARD' AS product_type,
    account.opened_at AS product_start_date
FROM bank_products.cards AS card
JOIN bank_products.accounts AS account
    ON card.account_id = account.account_id
JOIN bank_products.account_holders AS account_holder
    ON account.account_id = account_holder.account_id
WHERE card.status = 'ACTIVE';

-- KPI: liczba wszystkich aktywnych klientów banku
CREATE VIEW reporting.kpi_active_customers AS
SELECT
    COUNT(DISTINCT customer_id) AS total_active_customers
FROM reporting.v_customer_product_facts;


-- KPI: średnia liczba produktów przypadających na klienta
CREATE VIEW reporting.kpi_avg_products_per_customer AS
SELECT
    ROUND(AVG(product_count), 2) AS average_products_per_customer
FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT product_type) AS product_count
    FROM reporting.v_customer_product_facts
    GROUP BY customer_id
) AS customer_products;

-- KPI: liczba nowych klientów w podziale na miesiące
CREATE VIEW reporting.kpi_new_customers_monthly AS
SELECT
    DATE_TRUNC('month', created_at) AS month,
    COUNT(*) AS new_customers_count
FROM customer_data.customers
GROUP BY month
ORDER BY month;

-- KPI: miesięczny wolumen przelewów wykonanych przez klientów
CREATE VIEW reporting.kpi_transfer_volume_monthly AS
SELECT
    DATE_TRUNC('month', transfer_timestamp) AS month,
    SUM(amount) AS total_transfer_volume
FROM operations.transfers
GROUP BY month
ORDER BY month;

-- Metryka: liczba klientów wg rodzaju produktu
CREATE VIEW reporting.m_customers_per_product AS
SELECT
    product_type,
    COUNT(DISTINCT customer_id) AS customer_count
FROM reporting.v_customer_product_facts
GROUP BY product_type
ORDER BY product_type;

-- Metryka: miesięczny trend aktywacji produktów według typu
CREATE VIEW reporting.m_product_activation_trend_monthly AS
SELECT
    DATE_TRUNC('month', product_start_date) AS month,
    product_type,
    COUNT(*) AS activated_products_count
FROM reporting.v_customer_product_facts
GROUP BY month, product_type
ORDER BY month, product_type;

-- Metryka: rozkład klientów według liczby posiadanych produktów
CREATE VIEW reporting.m_customer_product_distribution AS
WITH customer_product_counts AS (
    SELECT
        customer_id,
        COUNT(DISTINCT product_type) AS product_count
    FROM reporting.v_customer_product_facts
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN product_count = 1 THEN '1 product'
        WHEN product_count = 2 THEN '2 products'
        ELSE '3+ products'
    END AS product_bucket,
    COUNT(*) AS customer_count
FROM customer_product_counts
GROUP BY product_bucket
ORDER BY product_bucket;

-- Metryka: liczba przelewów klientów w podziale na miesiące
CREATE VIEW reporting.m_monthly_transfer_activity AS
SELECT
    DATE_TRUNC('month', transfer_timestamp) AS month,
    COUNT(*) AS transfer_count
FROM operations.transfers
GROUP BY month
ORDER BY month;

