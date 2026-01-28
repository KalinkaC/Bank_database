CREATE TABLE bank_products.accounts (
    account_id SERIAL PRIMARY KEY,
    account_number CHAR(34) UNIQUE NOT NULL,
    balance NUMERIC(15,2) NOT NULL DEFAULT 0,
    currency CHAR(3) NOT NULL DEFAULT 'PLN',
    status VARCHAR(10) NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE','BLOCKED','CLOSED')),
    type_account VARCHAR(20) NOT NULL DEFAULT 'CHECKING'
        CHECK (type_account IN ('CHECKING','SAVINGS','JOINT','BUSINESS')),
    opened_at TIMESTAMPTZ DEFAULT now()
);


CREATE TABLE bank_products.account_holders (
    account_id INT REFERENCES bank_products.accounts(account_id) ON DELETE CASCADE,
    customer_id INT REFERENCES customer_data.customers(customer_id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL DEFAULT 'OWNER'
        CHECK (role IN ('OWNER','CO_OWNER')),
    status_customer VARCHAR(10) NOT NULL DEFAULT 'ACTIVE'
        CHECK (status_customer IN ('ACTIVE','BLOCKED')),
    PRIMARY KEY (account_id, customer_id)
);

CREATE TABLE bank_products.loans (
    loan_id SERIAL PRIMARY KEY,
    account_id INT REFERENCES bank_products.accounts(account_id) ON DELETE CASCADE,
    loan_type VARCHAR(20) NOT NULL DEFAULT 'PERSONAL'
        CHECK (loan_type IN ('PERSONAL','MORTGAGE','CAR','STUDENT','BUSINESS')),
    amount NUMERIC(15,2) NOT NULL CHECK (amount > 0),
    interest_rate NUMERIC(5,2) NOT NULL CHECK (interest_rate >= 0),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE','CLOSED','DEFAULTED'))
);

CREATE TABLE bank_products.cards (
    card_id SERIAL PRIMARY KEY,
    account_id INT REFERENCES bank_products.accounts(account_id) ON DELETE CASCADE,
    card_number CHAR(16) UNIQUE NOT NULL,
    card_type VARCHAR(10) NOT NULL DEFAULT 'DEBIT'
        CHECK (card_type IN ('DEBIT','CREDIT')),
    status VARCHAR(10) NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE','BLOCKED','CLOSED')),
    expiration_date DATE NOT NULL,
    cvv CHAR(3) NOT NULL
);

CREATE TABLE bank_products.deposits (
    deposit_id SERIAL PRIMARY KEY,
    account_id INT REFERENCES bank_products.accounts(account_id) ON DELETE CASCADE,
    deposit_type VARCHAR(20) NOT NULL DEFAULT 'TERM'
        CHECK (deposit_type IN ('TERM','SAVINGS','PROMOTIONAL')),
    amount NUMERIC(15,2) NOT NULL CHECK (amount > 0),
    interest_rate NUMERIC(5,2) NOT NULL CHECK (interest_rate >= 0),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status VARCHAR(10) NOT NULL DEFAULT 'ACTIVE'
        CHECK (status IN ('ACTIVE','CLOSED','MATURED'))
);