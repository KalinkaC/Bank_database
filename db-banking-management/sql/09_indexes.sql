-- Bee-tree indeksy na kluczach obcych
CREATE INDEX idx_account_holders_customer
    ON bank_products.account_holders(customer_id);

CREATE INDEX idx_loans_account
    ON bank_products.loans(account_id);

CREATE INDEX idx_account_holders_account
    ON bank_products.account_holders(account_id);

CREATE INDEX idx_deposits_account
    ON bank_products.deposits(account_id);

CREATE INDEX idx_cards_account
    ON bank_products.cards(account_id);

-- Partial indeksy na status = 'ACTIVE'
CREATE INDEX idx_accounts_active
    ON bank_products.accounts(account_id, opened_at)
    WHERE status = 'ACTIVE';

CREATE INDEX idx_loans_active
    ON bank_products.loans(account_id, start_date)
    WHERE status = 'ACTIVE';

CREATE INDEX idx_account_holders_active
    ON bank_products.account_holders(account_id, customer_id)
    WHERE status_customer = 'ACTIVE';

CREATE INDEX idx_deposits_active
    ON bank_products.deposits(account_id, start_date)
    WHERE status = 'ACTIVE';

CREATE INDEX idx_cards_active
    ON bank_products.cards(account_id)
    WHERE status = 'ACTIVE';




