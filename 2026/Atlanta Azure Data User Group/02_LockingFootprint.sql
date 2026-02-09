USE OptimizedLockingDemo;
GO

--ALTER DATABASE OptimizedLockingDemo SET OPTIMIZED_LOCKING = ON WITH ROLLBACK IMMEDIATE;

/* Confirm current state */
SELECT DATABASEPROPERTYEX(DB_NAME(), 'IsOptimizedLockingOn') AS IsOptimizedLockingOn; -- :contentReference[oaicite:8]{index=8}
GO

INSERT dbo.sessions 
    SELECT @@spid,0,CAST(DATABASEPROPERTYEX(DB_NAME(), 'IsOptimizedLockingOn') as BIT)
    
BEGIN TRAN;

UPDATE TOP (2000) dbo.Orders
SET Amount = Amount + 1
WHERE Status = 1;      -- scan-ish; still fine for this footprint demo

-- Look at locks for *this* session
SELECT
    resource_type,
    request_mode,
    request_status,
    COUNT(*) AS lock_count
FROM sys.dm_tran_locks
WHERE request_session_id = @@SPID
  AND resource_type IN ('PAGE','RID','KEY','XACT')
GROUP BY resource_type, request_mode, request_status
ORDER BY resource_type, request_mode;

-- Keep transaction open so you can talk through it
WAITFOR DELAY '00:00:10';

COMMIT;   -- ROLLBACK;

UPDATE dbo.sessions 
SET processed = 1
WHERE sessionID = @@spid
GO
