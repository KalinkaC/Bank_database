CREATE USER user_admin LOGIN PASSWORD 'admin_password';
GRANT role_admin TO user_admin;

CREATE USER user_employee LOGIN PASSWORD 'employee_password';
GRANT role_employee TO user_employee;

CREATE USER user_reporting LOGIN PASSWORD 'reporting_password';
GRANT role_reporting TO user_reporting;

