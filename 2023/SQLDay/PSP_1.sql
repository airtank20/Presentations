USE WideWorldImporters;
GO

-- create procedure
CREATE OR ALTER PROCEDURE [Warehouse].[GetStockItemsbySupplier]  @SupplierID int
AS
BEGIN
SELECT StockItemID, SupplierID, StockItemName, TaxRate, LeadTimeDays
FROM Warehouse.StockItems s
WHERE SupplierID = @SupplierID
ORDER BY StockItemName;
END;
GO

-- rebuild index
ALTER INDEX FK_Warehouse_StockItems_SupplierID ON Warehouse.StockItems REBUILD;
GO

-- setup database for demo
ALTER DATABASE current SET COMPATIBILITY_LEVEL = 150;
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
ALTER DATABASE current SET QUERY_STORE CLEAR;
GO


