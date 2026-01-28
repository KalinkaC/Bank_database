CREATE TABLE customer_data.customers (
    customer_id SERIAL PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    pesel CHAR(11) UNIQUE,
    email VARCHAR(50) UNIQUE,
    phone_number VARCHAR(15) UNIQUE,
    created_at TIMESTAMPTZ DEFAULT now(),
    CHECK (pesel ~ '^[0-9]{11}$' OR pesel IS NULL),
    CHECK (phone_number ~ '^[0-9]{9,15}$' OR phone_number IS NULL)
);
