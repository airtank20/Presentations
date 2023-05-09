---------------------------------------------------
-- *** Table Variables Demo *** --
---------------------------------------------------
-- Step 1: Create the stored procedure to use a table variable. Pull in pages from Sales.Invoices to make all comparison fair based on a warm buffer pool cache
USE WideWorldImporters
GO

-- check
SELECT * FROM SYS.database_scoped_configurations
WHERE NAME IN ('LAST_QUERY_PLAN_STATS','LIGHTWEIGHT_QUERY_PROFILING', 'DEFERRED_COMPILATION_TV')

ALTER DATABASE SCOPED CONFIGURATION SET LAST_QUERY_PLAN_STATS = ON;
ALTER DATABASE WideWorldImporters SET compatibility_level = 130;

-- create the procedure
USE WideWorldImporters
GO
CREATE or ALTER PROCEDURE [Sales].[CustomerProfits]
AS
BEGIN
-- Declare the table variable
DECLARE @ilines TABLE
(	[InvoiceLineID] [int] NOT NULL primary key,
	[InvoiceID] [int] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[TaxAmount] [decimal](18, 2) NOT NULL,
	[LineProfit] [decimal](18, 2) NOT NULL,
	[ExtendedPrice] [decimal](18, 2) NOT NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL
)

-- Insert all the rows from InvoiceLines into the table variable
INSERT INTO @ilines SELECT * FROM Sales.InvoiceLines

-- Find my total profile by customer
SELECT TOP 1 COUNT(i.CustomerID) as customer_count, SUM(il.LineProfit) as total_profit
FROM Sales.Invoices i
INNER JOIN @ilines il
ON i.InvoiceID = il.InvoiceID
GROUP By i.CustomerID
END
GO

-- Pull these pages into cache to make the comparison fair based on a warm buffer pool cache
SELECT COUNT(*) FROM Sales.Invoices  --70510
GO

-- Step 2: Run the stored procedure under dbcompat = 130
-- show execution plan
USE WideWorldImporters
GO
SET NOCOUNT ON
GO
SET STATISTICS TIME,IO ON
EXEC [Sales].[CustomerProfits]
GO 
SET STATISTICS TIME,IO OFF
SET NOCOUNT OFF
GO

--DBCC FREEPROCCACHE;

-- Step 3: Run the same code under dbcompat = 150
-- show execution plan
USE master
GO
ALTER DATABASE WideWorldImporters SET compatibility_level = 160
GO
USE WideWorldImporters
GO
SET NOCOUNT ON
GO
SET STATISTICS TIME,IO ON
PRINT 'Starting'
EXEC [Sales].[CustomerProfits]
GO 
SET STATISTICS TIME,IO OFF
SET NOCOUNT OFF
GO

-- landed queries
SELECT cp.cacheobjtype, cp.usecounts, cp.plan_handle,st.objectid,st.text,db_name(st.dbid),qps.query_plan   
FROM sys.dm_exec_cached_plans AS cp
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS st
CROSS APPLY sys.dm_exec_query_plan_stats(plan_handle) AS qps
where qps.dbid = db_id('WideWorldImporters')
	and st.objectid IS NOT NULL
GO