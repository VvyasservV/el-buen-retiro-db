# El Buen Retiro — Insurance Company Database (SQL Server)

Relational database for a fictional Mexican insurance company, **"El Buen Retiro"**, that sells auto, life and retirement insurance through a network of brokers. Final project for the *Databases* course at the Facultad de Ingeniería, UNAM (Fall 2025), built by a 3-person team.

**Stack:** SQL Server · T-SQL · ER/Studio (relational model) · Dia (conceptual model)

## At a glance

| | |
|---|---|
| Tables | **27**, normalized to 3NF |
| Schemas | **5**: `CATALOGO`, `CLIENTE`, `VENTAS`, `SEGURO`, `TRABAJADOR` |
| Views | 3 |
| Triggers | 5 (business rules enforced in the database) |
| Stored procedures | 5, transactional with `TRY…CATCH` |
| Security | 3 roles with DCL (`GRANT` / `DENY`) |
| Analytics | 17 queries: 10 statistics + 7 business reports |
| Seed data | Full Mexican postal catalog from SEPOMEX: 32 states, 2,478 municipalities, **157,286 neighborhoods** |

## Data model

The model covers clients (individuals or companies), brokers and their supervisors, claims adjusters, three insurance product types (specialization of `SEGURO` into `SEGURO_AUTO`, `SEGURO_VIDA` and `SEGURO_RETIRO`), vehicles, policies, payments, quotes with a status log, life-insurance beneficiaries and claims.

- Conceptual model (ER, Dia): [`docs/diagrams/conceptual-model.dia`](docs/diagrams/conceptual-model.dia)
- Relational model (ER/Studio): [`docs/diagrams/relational-model.DM1`](docs/diagrams/relational-model.DM1)

Constraints used: primary keys, foreign keys, `UNIQUE` (e.g., broker license number, one payment number per policy), `CHECK` (positive premium, end date after start date, CURP/RFC length and "individual has CURP, company has RFC" rule, commission between 0 and 1).

## Business rules enforced with triggers

| Trigger | Rule |
|---|---|
| `VENTAS.tg_asigna_corredor_zona` | If a policy is created without a broker, assign one automatically based on the client's ZIP code. |
| `VENTAS.tg_edad_contratacion` | Reject a life-insurance policy if the client is older than the product's maximum age. |
| `VENTAS.tg_saldo_pendiente` | After every payment, recalculate the policy's outstanding balance; reject overpayments. |
| `VENTAS.tg_bitacora_estado` | Log every quote status change (Pending → Accepted / Rejected) in `BITACORA_COTIZACION`. |
| `VENTAS.tg_beneficiarios` | A life policy can have at most 5 beneficiaries whose shares add up to at most 100 %. |

[`sql/validaTriggers.sql`](sql/validaTriggers.sql) runs a test scenario for each trigger inside a transaction that is rolled back.

## Analytics (`informes.sql`)

**Statistics:** active clients · active policies by insurance type · average insured amount by type · total premium income · claims by cause · clients by state and city · top 5 brokers by premium sold · percentage of late payments · average age of life-insurance clients · policy renewal rate (window function `LEAD`).

**Reports:** active policies by broker · premiums sold by broker · pending quotes by insurance type · clients with both life and retirement insurance · pending payments · average claim payout by insurance type · insured vehicles by make and model.

## Repository layout

```
sql/
  creaBase.sql        DDL: database, schemas, 27 tables and constraints
  cargaInicial.sql    Seed data (SEPOMEX catalog + sample clients, policies, payments, claims)
  dml.sql             Views, triggers and stored procedures
  seguridad.sql       Logins, users, roles and permissions (DCL)
  informes.sql        Statistics and reports
  validaTriggers.sql  Test scenarios for each trigger
docs/diagrams/        Conceptual (Dia) and relational (ER/Studio) models
```

## How to run

Run the scripts in this order in SQL Server Management Studio or Azure Data Studio:

1. `creaBase.sql`
2. `cargaInicial.sql` (large file, it takes a while because of the postal catalog)
3. `dml.sql`
4. `seguridad.sql` (change the example passwords first)
5. `informes.sql`
6. `validaTriggers.sql`

All client, employee and contact data in the seed script is fictional.

## Known limitations

- Several triggers read `INSERTED` into scalar variables, so they assume single-row `INSERT`/`UPDATE` statements. Multi-row statements should be handled with set-based logic.
- The *last month / last quarter* filters from the original spec are not applied in every report, so the sample data keeps producing results.

## Team

- **Yasser Vladimir Cruz Miranda** — [GitHub](https://github.com/VvyasservV) · [LinkedIn](https://www.linkedin.com/in/yasservladimircruzmiranda/)
- Alan Mauricio Morales López
- Luis Adrián González Falcón
