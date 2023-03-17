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
ALTER DATABASE current SET COMPATIBILITY_LEVEL = 160;
GO
ALTER DATABASE SCOPED CONFIGURATION CLEAR PROCEDURE_CACHE;
GO
ALTER DATABASE current SET QUERY_STORE CLEAR;
GO

-- see parent queries
SELECT qt.query_sql_text
FROM sys.query_store_query_text qt
JOIN sys.query_store_query qq
ON qt.query_text_id = qq.query_text_id
JOIN sys.query_store_query_variant qv
ON qq.query_id = qv.parent_query_id;
GO

-- see query variant
SELECT qp.plan_id, qp.query_plan_hash, cast (qp.query_plan as XML)
FROM sys.query_store_plan qp
JOIN sys.query_store_query_variant qv
ON qp.plan_id = qv.dispatcher_plan_id;
GO

USE WideWorldImporters;
GO
-- Look at the queries and plans for variants
-- Notice each query is from the same parent_query_id and the query_hash is the same
SELECT qt.query_sql_text, qq.query_id, qv.query_variant_query_id, qv.parent_query_id, 
qq.query_hash,qr.count_executions, qp.plan_id, qv.dispatcher_plan_id, qp.query_plan_hash,
cast(qp.query_plan as XML) as xml_plan
FROM sys.query_store_query_text qt
JOIN sys.query_store_query qq
ON qt.query_text_id = qq.query_text_id
JOIN sys.query_store_plan qp
ON qq.query_id = qp.query_id
JOIN sys.query_store_query_variant qv
ON qq.query_id = qv.query_variant_query_id
JOIN sys.query_store_runtime_stats qr
ON qp.plan_id = qr.plan_id
ORDER BY qv.parent_query_id;

-- 0 is the parent compiles plan
select plan_id,query_id,query_plan,plan_type_desc from sys.query_store_plan
where plan_type > 0
GO