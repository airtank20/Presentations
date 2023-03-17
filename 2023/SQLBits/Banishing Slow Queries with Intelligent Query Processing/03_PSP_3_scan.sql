USE WideWorldImporters;
GO
-- The best plan for this parameter is an index scan
EXEC Warehouse.GetStockItemsbySupplier 4;
GO