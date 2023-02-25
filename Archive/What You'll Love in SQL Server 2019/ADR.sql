-- Let's cheat so we can see transactions in flight
-- DO NOT DO THIS IN PRODUCTION!!!
USE MASTER
GO
ALTER DATABASE AdventureWorksDW2017
	MODIFY FILE (NAME=AdventureWorksDW2017_log, filegrowth=8kb)

DBCC SHRINKFILE (N'AdventureWorksDW2017_log' , 0, TRUNCATEONLY)
GO

-- can also use
SELECT * FROM sys.dm_db_log_space_usage;
GO

-- is it enabled?
SELECT NAME, is_accelerated_database_recovery_on FROM SYS.DATABASES

ALTER DATABASE AdventureWorksDW2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE AdventureWorksDW2017 SET ACCELERATED_DATABASE_RECOVERY=OFF;
ALTER DATABASE AdventureWorksDW2017 SET MULTI_USER;

-- 
DECLARE @x INT = 1
BEGIN TRANSACTION
WHILE @x < 500
BEGIN
	DECLARE @datekey DATE = (SELECT MIN(MovementDate) FROM factproductinventory WHERE productkey = 1)
	WHILE @datekey < (SELECT MAX(MovementDate) FROM factproductinventory WHERE productkey = @x)
		BEGIN
			UPDATE dbo.FactProductInventory
			SET Unitcost = unitcost - .05
			WHERE productkey = @x 
				and datekey = REPLACE(CAST(@datekey AS VARCHAR(10)),'-','')
		
			SET @datekey = DATEADD(DAY,1,@datekey)
		END
	SET @x = @x + 1
END
GO

-- Do the rollback
ROLLBACK TRANSACTION;

-- Enable ADR & do it again
ALTER DATABASE AdventureWorksDW2017 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
ALTER DATABASE AdventureWorksDW2017 SET ACCELERATED_DATABASE_RECOVERY=ON;
ALTER DATABASE AdventureWorksDW2017 SET MULTI_USER;

-- just checking
SELECT NAME, is_accelerated_database_recovery_on FROM SYS.DATABASES
--