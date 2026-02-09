-- Session 1
USE OptimizedLockingDemo;
GO

-- Reset a predictable state
UPDATE dbo.Orders
SET Amount = Amount, Status = CASE WHEN OrderId % 10 = 0 THEN 1 ELSE 0 END;
GO

SELECT DATABASEPROPERTYEX(DB_NAME(), 'IsOptimizedLockingOn') AS IsOptimizedLockingOn;
GO

INSERT dbo.sessions 
    SELECT @@spid,0,CAST(DATABASEPROPERTYEX(DB_NAME(), 'IsOptimizedLockingOn') as BIT)

BEGIN TRAN;

-- Intentionally non-sargable filter to force scanning behavior
-- This touches many rows while only updating a subset.
UPDATE dbo.Orders
SET Amount = Amount + 5
WHERE (OrderId % 2) = 0   -- forces scan-like work
  AND Status = 1;

-- Hold the transaction open so Session 2 can run concurrently
WAITFOR DELAY '00:00:25';

COMMIT;
GO

UPDATE dbo.sessions 
SET processed = 1
WHERE sessionID = @@spid;
GO
