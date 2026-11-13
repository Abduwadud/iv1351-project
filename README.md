# IV1351 Project – Course Layout and Teaching Load Allocation

Database for planning course layouts and allocating teaching load at a university (IV1351 Data Storage Paradigms, KTH, HT26).

## Files
- `create.sql` – creates all tables
- `insert.sql` – inserts test data

## Run (PostgreSQL)
```
createdb iv1351
psql iv1351 -f create.sql
psql iv1351 -f insert.sql
```
