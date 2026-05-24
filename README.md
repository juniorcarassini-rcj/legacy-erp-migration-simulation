# Legacy ERP Migration Simulation 🏛️ -> 🚀

A simulated enterprise-grade T-SQL implementation demonstrating data migration strategies from legacy relational structures (ERP architectures) to modern analytical data environments. This repository showcases optimized batch processing, data integrity constraints, and transaction control techniques required for critical business systems.

---

## 🚀 Purpose & Context
Legacy software engineering and relational databases often require massive schema re-architecting without disrupting 24/7 production environments. This project illustrates:
- **Performance Tuning**: Using segmented batch processing (`WHILE` loops with variable size parameters) to prevent transaction log saturation and table locks.
- **Data Architecture**: Cleansing and transforming legacy column naming conventions and structural dependencies into structured analytical target schemas.
- **System Reliability**: Implementing transaction safety rules (`XACT_ABORT`, structural checkpoints, and database monitoring indicators).

---

## 🛠️ Tech Stack & Concepts
- **Database Engine**: Microsoft SQL Server / T-SQL
- **Methodology**: Safe ETL (Extract, Transform, Load) staging strategy
- **Concepts Applied**: High-Performance Indexing Strategy, Batch Commit Isolation, Target Idempotency, and Enterprise System Reliability.

---

## 📊 Logic Pipeline
The core routine contained in `migration_procedure.sql` operates through three main phases:

1. **Pre-Migration Integrity Validation**: Sweeps the legacy staging environment (`LegacySalesRaw`) to flags anomalies or missing structural keys prior to moving operational data.
2. **Dynamic Data Transformation**: Normalizes unstructured legacy fields (e.g., calculating net values on-the-fly while mapping old short-string item formats to standard target keys).
3. **Throttled Persistence (Load)**: Saves data dynamically using small, non-blocking time delays (`WAITFOR DELAY`) to minimize performance degradation on hardware infrastructures running production routines.

---

## 📈 How to Deploy & Inspect
1. Open the SQL Script inside an ecosystem connected to an SQL Server instance (e.g., Azure Data Studio or SSMS).
2. Execute the DDL script to compile the routine:
```sql
   -- Compiles the procedure into the target schema
   EXEC usp_MigrateLegacySalesToAnalytics @BatchSize = 1000, @DebugMode = 1;
