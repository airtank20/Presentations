-- Session 2
USE OptimizedLockingDemo;
GO

SELECT DATABASEPROPERTYEX(DB_NAME(), 'IsOptimizedLockingOn') AS IsOptimizedLockingOn;
GO

insert into dbo.sessions 
    SELECT @@spid,0,cast(DATABASEPROPERTYEX(DB_NAME(), 'IsOptimizedLockingOn') as BIT)

-- Similar scan-ish pattern, but “other half” of rows
UPDATE dbo.Orders
SET Amount = Amount + 7
WHERE (OrderId % 2) = 1
  AND Status = 1;
GO
update dbo.sessions set processed = 1
where sessionID = @@spid