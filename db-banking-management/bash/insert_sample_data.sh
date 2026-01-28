#!/bin/bash

# ŚCIEŻKA DO PSQL - dla PostgreSQL 18
PSQL="/c/Program Files/PostgreSQL/18/bin/psql.exe"

DB_NAME="bank_db"
DB_USER="postgres"
DB_HOST="localhost"
CUSTOMERS=120
TRANSFERS=300

# Sprawdź czy psql istnieje
if [ ! -f "$PSQL" ]; then
    echo "BŁĄD: psql nie jest zainstalowany lub nie znajduje się w PATH"
    echo "Sprawdź ścieżkę: $PSQL"
    exit 1
fi

if [ -z "$PGPASSWORD" ] && [ ! -f ~/.pgpass ]; then
  read -sp "Podaj haslo do PostgreSQL: " PGPASSWORD
  export PGPASSWORD
  echo ""
fi

FIRST_NAMES=("Anna" "Piotr" "Katarzyna" "Marek" "Monika" "Tomasz" "Agnieszka" "Pawel" "Magdalena" "Lukasz")
LAST_NAMES=("Nowak" "Kowalski" "Wisniewski" "Wojcik" "Kaczmarek" "Mazur" "Kubiak" "Zielinski" "Sikora" "Jankowski")

ACCOUNT_SEQ=0

echo "Rozpoczynam wstawianie danych..."

for i in $(seq 1 $CUSTOMERS); do
  FIRST=${FIRST_NAMES[$RANDOM % ${#FIRST_NAMES[@]}]}
  LAST=${LAST_NAMES[$RANDOM % ${#LAST_NAMES[@]}]}
  PESEL="9$(printf "%010d" $i)"
  EMAIL="${FIRST,,}.${LAST,,}$i@mail.com"
  PHONE="6$(printf "%08d" $i)"
  
  # Poprawione wykonanie INSERT - bez przekierowań błędów
  CUSTOMER_ID=$("$PSQL" -h $DB_HOST -U $DB_USER -d $DB_NAME -t -A -c \
    "INSERT INTO customer_data.customers
     (first_name, last_name, pesel, email, phone_number, created_at)
     VALUES ('$FIRST', '$LAST', '$PESEL', '$EMAIL', '$PHONE', now() - (random() * interval '12 months'))
     RETURNING customer_id;" 2>&1 | grep -oE '^[0-9]+$' | head -1)
  
  if [ -z "$CUSTOMER_ID" ]; then
    echo "Blad przy tworzeniu klienta $i"
    continue
  fi
  
  if [ $((i % 10)) -eq 0 ]; then
    echo "Przetworzono $i klientow... (ostatni ID: $CUSTOMER_ID)"
  fi
  
  ACC_COUNT=$((RANDOM % 3 + 1))
  
  for a in $(seq 1 $ACC_COUNT); do
    ACCOUNT_SEQ=$((ACCOUNT_SEQ + 1))
    ACCOUNT_NUMBER="PL61$(printf "%024d" $ACCOUNT_SEQ)"
    TYPE_ACCOUNT=("CHECKING" "SAVINGS" "BUSINESS")
    RANDOM_TYPE=${TYPE_ACCOUNT[$RANDOM % 3]}
    
    # Poprawione pobieranie ACCOUNT_ID
    ACCOUNT_ID=$("$PSQL" -h $DB_HOST -U $DB_USER -d $DB_NAME -t -A -c \
      "INSERT INTO bank_products.accounts
       (account_number, balance, status, type_account, opened_at)
       VALUES ('$ACCOUNT_NUMBER', (random()*30000)::numeric(15,2), 'ACTIVE', '$RANDOM_TYPE', now() - (random() * interval '12 months'))
       RETURNING account_id;" 2>&1 | grep -oE '^[0-9]+$' | head -1)
    
    if [ -z "$ACCOUNT_ID" ]; then
      echo "Blad przy tworzeniu konta dla klienta $CUSTOMER_ID"
      continue
    fi
    
    # Wstawienie do account_holders
    "$PSQL" -h $DB_HOST -U $DB_USER -d $DB_NAME -c \
      "INSERT INTO bank_products.account_holders (account_id, customer_id)
       VALUES ($ACCOUNT_ID, $CUSTOMER_ID);" >/dev/null 2>&1
    
    # Dodanie karty (50% szans)
    if [ $((RANDOM % 2)) -eq 0 ]; then
      CARD_NUMBER="4$(printf "%015d" $ACCOUNT_SEQ)"
      CARD_TYPE=("DEBIT" "CREDIT")
      RANDOM_CARD_TYPE=${CARD_TYPE[$RANDOM % 2]}
      CVV=$(printf "%03d" $((RANDOM % 1000)))
      
      "$PSQL" -h $DB_HOST -U $DB_USER -d $DB_NAME -c \
        "INSERT INTO bank_products.cards (account_id, card_number, card_type, expiration_date, cvv)
         VALUES ($ACCOUNT_ID, '$CARD_NUMBER', '$RANDOM_CARD_TYPE', current_date + interval '4 years', '$CVV');" >/dev/null 2>&1
    fi
    
    # Dodanie pożyczki (25% szans)
    if [ $((RANDOM % 4)) -eq 0 ]; then
      LOAN_TYPE=("PERSONAL" "CAR" "STUDENT")
      RANDOM_LOAN=${LOAN_TYPE[$RANDOM % 3]}
      
      "$PSQL" -h $DB_HOST -U $DB_USER -d $DB_NAME -c \
        "INSERT INTO bank_products.loans (account_id, loan_type, amount, interest_rate, start_date, end_date)
         VALUES (
           $ACCOUNT_ID,
           '$RANDOM_LOAN',
           (random()*60000 + 5000)::numeric(15,2),
           (random()*8 + 2)::numeric(5,2),
           current_date - (floor(random()*12)::int) * interval '1 month',
           current_date + (floor(random()*48)::int) * interval '1 month'
         );" >/dev/null 2>&1
    fi
    
    # Dodanie lokaty (25% szans)
    if [ $((RANDOM % 4)) -eq 0 ]; then
      "$PSQL" -h $DB_HOST -U $DB_USER -d $DB_NAME -c \
        "INSERT INTO bank_products.deposits (account_id, amount, interest_rate, start_date, end_date)
         VALUES (
           $ACCOUNT_ID,
           (random()*40000 + 3000)::numeric(15,2),
           (random()*4 + 1)::numeric(5,2),
           current_date - (floor(random()*12)::int) * interval '1 month',
           current_date + (floor(random()*12)::int) * interval '1 month'
         );" >/dev/null 2>&1
    fi
  done
done

echo ""
echo "Generuje przelewy..."

# Poprawione pobieranie listy kont
mapfile -t ACCOUNT_IDS < <("$PSQL" -h $DB_HOST -U $DB_USER -d $DB_NAME -t -A -c \
  "SELECT account_id FROM bank_products.accounts ORDER BY account_id;")

ACCOUNT_COUNT=${#ACCOUNT_IDS[@]}

echo "Znaleziono $ACCOUNT_COUNT kont w bazie"

if [ "$ACCOUNT_COUNT" -lt 2 ]; then
  echo "BLAD: Za malo kont do generowania przelewow (potrzeba minimum 2)"
  exit 1
fi

echo "Pierwsze konto ID: ${ACCOUNT_IDS[0]}"
echo "Ostatnie konto ID: ${ACCOUNT_IDS[$((ACCOUNT_COUNT-1))]}"

SUCCESSFUL_TRANSFERS=0
FAILED_TRANSFERS=0

for i in $(seq 1 $TRANSFERS); do
  FROM_INDEX=$((RANDOM % ACCOUNT_COUNT))
  TO_INDEX=$((RANDOM % ACCOUNT_COUNT))
  
  # Upewnij się, że konta są różne
  ATTEMPTS=0
  while [ "$FROM_INDEX" -eq "$TO_INDEX" ] && [ $ATTEMPTS -lt 10 ]; do
    TO_INDEX=$((RANDOM % ACCOUNT_COUNT))
    ATTEMPTS=$((ATTEMPTS + 1))
  done
  
  if [ "$FROM_INDEX" -eq "$TO_INDEX" ]; then
    FAILED_TRANSFERS=$((FAILED_TRANSFERS + 1))
    continue
  fi
  
  FROM_ACCOUNT=${ACCOUNT_IDS[$FROM_INDEX]}
  TO_ACCOUNT=${ACCOUNT_IDS[$TO_INDEX]}
  
  # Pobierz numer konta docelowego
  TO_ACC_NUMBER=$("$PSQL" -h $DB_HOST -U $DB_USER -d $DB_NAME -t -A -c \
    "SELECT account_number FROM bank_products.accounts WHERE account_id = $TO_ACCOUNT;")
  
  # Generuj losową kwotę
  RANDOM_CENTS=$((RANDOM % 800000 + 100))
  DOLLARS=$((RANDOM_CENTS / 100))
  CENTS=$((RANDOM_CENTS % 100))
  AMOUNT=$(printf "%d.%02d" $DOLLARS $CENTS)
  
  # Wykonaj przelew
  TRANSFER_RESULT=$("$PSQL" -h $DB_HOST -U $DB_USER -d $DB_NAME -c \
    "INSERT INTO operations.transfers (from_account, to_account, amount, transfer_timestamp)
     VALUES (
       $FROM_ACCOUNT,
       '$TO_ACC_NUMBER',
       $AMOUNT,
       now() - (floor(random()*12)::int) * interval '1 month'
     );" 2>&1)
  
  if echo "$TRANSFER_RESULT" | grep -qi "INSERT 0 1"; then
    SUCCESSFUL_TRANSFERS=$((SUCCESSFUL_TRANSFERS + 1))
  elif echo "$TRANSFER_RESULT" | grep -qi "ERROR\|BLAD"; then
    FAILED_TRANSFERS=$((FAILED_TRANSFERS + 1))
    if [ $FAILED_TRANSFERS -le 5 ]; then
      echo "Blad przy przelewie $i: $TRANSFER_RESULT"
    fi
  else
    SUCCESSFUL_TRANSFERS=$((SUCCESSFUL_TRANSFERS + 1))
  fi
  
  if [ $((i % 50)) -eq 0 ]; then
    echo "Przetworzono $i/$TRANSFERS przelewow (udanych: $SUCCESSFUL_TRANSFERS, bledow: $FAILED_TRANSFERS)..."
  fi
done

echo ""
echo "========================================="
echo "PODSUMOWANIE:"
echo "Klienci: $CUSTOMERS"
echo "Konta: $ACCOUNT_COUNT"
echo "Przelewy udane: $SUCCESSFUL_TRANSFERS"
echo "Przelewy nieudane: $FAILED_TRANSFERS"
echo "========================================="