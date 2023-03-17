

---------------------------------------------------
-- *** Row-Mode Memory Grant Feedback Demo *** --
---------------------------------------------------
USE WideWorldImporters
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
ALTER DATABASE [WideWorldImporters] SET COMPATIBILITY_LEVEL = 140
go

SELECT * FROM sys.database_scoped_configurations
WHERE NAME LIKE '%MEMORY_GRANT_FEEDBACK'

USE [WideWorldImporters]
GO

-- Actual execution plan, examine plan XML
-- excessive memory grant warning
--SET STATISTICS XML ON 
SELECT 
  OD.CustomerID,OD.CustomerPurchaseOrderNumber,
  OD.InternalComments,OL.Quantity,OL.UnitPrice
  FROM [Sales].[Orders] OD
INNER JOIN [Sales].[OrderLines] OL
ON OD.OrderID = OL.OrderID
ORDER BY OD.[Comments]
GO

-- let's up the compatibility level
ALTER DATABASE [WideWorldImporters] SET COMPATIBILITY_LEVEL = 150
go
ALTER DATABASE WideWorldImporters SET QUERY_STORE CLEAR ALL;
GO


-- Examine plan XML
SELECT 
  OD.CustomerID,OD.CustomerPurchaseOrderNumber,
  OD.InternalComments,OL.Quantity,OL.UnitPrice
  FROM [Sales].[Orders] OD
INNER JOIN [Sales].[OrderLines] OL
ON OD.OrderID = OL.OrderID
ORDER BY OD.[Comments]
GO
