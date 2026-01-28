# System zarządzania bazą danych banku

## Opis projektu
Jest to projekt funkcjonalnej bazy danych dla instytucji finansowej, stworzony w PostgreSQL. Baza obsługuje klientów, konta, karty, pożyczki, lokaty i przelewy oraz generuje raporty i KPI biznesowe, takie jak liczba aktywnych klientów, średnia liczba produktów na klienta czy miesięczny wolumen przelewów. Dane testowe są generowane automatycznie za pomocą skryptu Bash, umożliwiając pełną symulację operacji bankowych.

**Kluczowe funkcjonalności:**
- Cztery schematy: `customer_data`, `bank_products`, `operations`, `reporting`
- Tabele i widoki z kontrolą integralności danych
- Indeksy zoptymalizowane pod aktywne produkty
- Role i uprawnienia (`admin`, `employee`, `reporting`)
- Widoki raportowe i KPI biznesowe
- Automatyczne generowanie danych testowych (120 klientów, 300 przelewów)

## Struktura bazy danych

### Schematy i tabele
- **customer_data** – klienci (`customers`)  
- **bank_products** – konta (`accounts`), posiadacze kont (`account_holders`), pożyczki (`loans`), karty (`cards`), lokaty (`deposits`)  
- **operations** – przelewy (`transfers`)  
- **reporting** – widoki raportowe i KPI (`v_customer_product_facts`, `kpi_active_customers`, itp.)

### Role i uprawnienia
- **role_admin** – pełne prawa do tworzenia i modyfikacji schematów oraz tabel  
- **role_employee** – CRUD na danych operacyjnych  
- **role_reporting** – dostęp tylko do odczytu danych i raportów  

### Przykładowe KPI i metryki
- Liczba aktywnych klientów  
- Średnia liczba produktów na klienta  
- Miesięczny wolumen przelewów  
- Trend aktywacji produktów według typu  

## Uruchamianie projektu

### Wymagania
- PostgreSQL 18
- pgAdmin4 (opcjonalnie do zarządzania bazą)
- Visual Studio Code lub inny edytor
- Bash (np. Git Bash na Windows)

### Tworzenie bazy danych
Skopiuj skrypt SQL z repozytorium i uruchom go w PostgreSQL
