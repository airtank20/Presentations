USE WideWorldImporters;
GO
SET STATISTICS TIME ON
-- The best plan for this parameter is an index seek. Run twice
EXEC Warehouse.GetStockItemsbySupplier 2;
GO
