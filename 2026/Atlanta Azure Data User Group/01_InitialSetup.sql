/*
Optimized Locking Demo (SQL Server 2025)

What you’ll show:
- OPTIMIZED_LOCKING is per-database and OFF by default in SQL Server 2025 (17.x)
- Requires ADR; LAQ requires RCSI for full benefit
Docs: Optimized locking + ALTER DATABASE SET OPTIMIZED_LOCKING :contentReference[oaicite:3]{index=3}
*/

USE master;
GO

IF DB_ID('OptimizedLockingDemo') IS NOT NULL
BEGIN
    ALTER DATABASE OptimizedLockingDemo SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE OptimizedLockingDemo;
END
GO

CREATE DATABASE OptimizedLockingDemo;
GO

-- Need ADR before enabling optimized locking :contentReference[oaicite:4]{index=4}
ALTER DATABASE OptimizedLockingDemo SET ACCELERATED_DATABASE_RECOVERY = ON;
GO

-- LAQ benefits require RCSI :contentReference[oaicite:5]{index=5}
ALTER DATABASE OptimizedLockingDemo SET READ_COMMITTED_SNAPSHOT ON WITH ROLLBACK IMMEDIATE;
GO

-- Start with optimized locking OFF for baseline
ALTER DATABASE OptimizedLockingDemo SET OPTIMIZED_LOCKING = OFF WITH ROLLBACK IMMEDIATE;
GO

/*
--ALTER DATABASE OptimizedLockingDemo SET OPTIMIZED_LOCKING = ON WITH ROLLBACK IMMEDIATE;
*/

USE OptimizedLockingDemo;
GO

DROP TABLE IF EXISTS dbo.Orders;
GO

CREATE TABLE dbo.Orders
(
    OrderId     int IDENTITY(1,1) NOT NULL CONSTRAINT PK_Orders PRIMARY KEY,
    CustomerId  int NOT NULL,
    Status      tinyint NOT NULL,         -- 0 = open, 1 = ready
    Amount      int NOT NULL,
    Pad         char(200) NOT NULL DEFAULT ('x')   -- widen rows to make scans “real”
);
GO

/* Load data: 10 million rows 
   Load Duration: ~1 minute   */
;WITH n AS
(
    SELECT TOP (10000000) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS rn
    FROM sys.all_objects a
    CROSS JOIN sys.all_objects b
)
INSERT dbo.Orders (CustomerId, Status, Amount)
SELECT
    rn % 50000,
    CASE WHEN rn % 10 = 0 THEN 1 ELSE 0 END,  -- ~10% status=1
    rn % 1000
FROM n;
GO

-- Intentionally DO NOT index Status, so predicates on Status force scans (helps show LAQ)
-- Optional: make sure stats exist
UPDATE STATISTICS dbo.Orders WITH FULLSCAN;
GO

-- Sanity check: options on the DB :contentReference[oaicite:6]{index=6}
SELECT
    name,
    is_accelerated_database_recovery_on,
    is_read_committed_snapshot_on,
    is_optimized_locking_on
FROM sys.databases
WHERE name = DB_NAME();
GO
 
CREATE TABLE dbo.sessions (sessionID int, Processed BIT, IsOptimizedLockingEnabled BIT);
GO
CREATE TABLE dbo.locks
     (
       event_time           datetime2,
       spid                 smallint,
       resource_type        nvarchar(60),
       request_mode         nvarchar(60),
       resource_description nvarchar(max)
     );
GO
CREATE PROCEDURE dbo.Watcher
AS 
BEGIN
-- Create some temporary tables for metrics
-- Credit: Aaron Bertrand https://www.red-gate.com/simple-talk/databases/sql-server/database-administration-sql-server/optimized-locking-in-azure-sql-database/

 DECLARE @now datetime2 = sysutcdatetime()
 DECLARE @X INT = 1

 WHILE @x < 50000
 BEGIN
     INSERT dbo.locks
         SELECT @now, 
            request_session_id, 
            resource_type, 
            request_mode, 
            resource_description
          FROM sys.dm_tran_locks
          WHERE resource_database_id = DB_ID(N'OptimizedLockingDemo')
          AND request_session_id = (select sessionID from dbo.Sessions where Processed = 0)
          AND resource_type <> N'DATABASE'

          WAITFOR DELAY '00:00:00.10'

        SET @x = @x + 1
    END
END
GO

EXEC dbo.Watcher;
GO