CREATE TABLE operations.transfers (
    transfer_id SERIAL PRIMARY KEY,
    from_account INT REFERENCES bank_products.accounts(account_id) NOT NULL,
    to_account CHAR(26) NOT NULL,              -- numer konta odbiorcy
    amount NUMERIC(15,2) NOT NULL CHECK (amount > 0),
    transfer_timestamp TIMESTAMPTZ DEFAULT now()
);
