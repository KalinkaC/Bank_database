GRANT USAGE ON SCHEMA customer_data TO role_reporting, role_employee, role_admin;
GRANT USAGE ON SCHEMA bank_products TO role_reporting, role_employee, role_admin;
GRANT USAGE ON SCHEMA operations TO role_reporting, role_admin;
GRANT USAGE ON SCHEMA reporting TO role_reporting, role_employee, role_admin;

-- role_reporting
GRANT SELECT(customer_id, created_at)
    ON customer_data.customers TO role_reporting;

GRANT SELECT(account_id, balance, currency, status, type_account, opened_at)
    ON bank_products.accounts TO role_reporting;

GRANT SELECT
    ON bank_products.account_holders TO role_reporting;

GRANT SELECT
    ON bank_products.loans TO role_reporting;

GRANT SELECT
    ON bank_products.deposits TO role_reporting;

GRANT SELECT(card_id, account_id, card_type, status, expiration_date)
    ON bank_products.cards TO role_reporting;

GRANT SELECT ON ALL TABLES IN SCHEMA reporting TO role_reporting;

--role_employee
GRANT SELECT, INSERT, UPDATE, DELETE
    ON customer_data.customers TO role_employee;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON bank_products.accounts TO role_employee;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON bank_products.account_holders TO role_employee;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON bank_products.loans TO role_employee;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON bank_products.deposits TO role_employee;

GRANT SELECT, INSERT, UPDATE, DELETE
    ON bank_products.cards TO role_employee;

GRANT SELECT ON ALL TABLES IN SCHEMA reporting TO role_employee;

--role_admin
GRANT CREATE, ALTER, DROP ON SCHEMA customer_data TO role_admin;
GRANT CREATE, ALTER, DROP ON SCHEMA bank_products TO role_admin;
GRANT CREATE, ALTER, DROP ON SCHEMA operations TO role_admin;
GRANT CREATE, ALTER, DROP ON SCHEMA reporting TO role_admin;

GRANT SELECT ON ALL TABLES IN SCHEMA customer_data TO role_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA bank_products TO role_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA operations TO role_admin;
GRANT SELECT ON ALL TABLES IN SCHEMA reporting TO role_admin;

ALTER DEFAULT PRIVILEGES FOR ROLE role_reporting IN SCHEMA reporting
    GRANT SELECT ON TABLES TO role_reporting;

ALTER DEFAULT PRIVILEGES FOR ROLE role_reporting IN SCHEMA reporting
    GRANT SELECT ON TABLES TO role_employee;

ALTER DEFAULT PRIVILEGES FOR ROLE role_reporting IN SCHEMA reporting
    GRANT SELECT ON TABLES TO role_admin;
