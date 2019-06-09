

USE WideWorldImporters
GO

-- Clean up
-- Show Object explorer
SELECT temporal_type, temporal_type_desc,* FROM sys.tables WHERE name IN ('Orders_temporal', 'Orders_Temporal_History')

-- let's turn things off/on
ALTER TABLE sales.Orders_Temporal SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = sales.orders_temporal_history))   
ALTER TABLE sales.Invoices SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = sales.invoices_temporal_history))   

alter table sales.orders_temporal 
	add col1 int  null
go
alter table sales.orders_temporal
	alter column col1 varchar(10)

-- now what do we see
SELECT temporal_type, temporal_type_desc,* FROM sys.tables WHERE name IN ('Orders_temporal', 'Orders_Temporal_History')

DROP TABLE sales.orders_temporal_history
DROP TABLE sales.orders_temporal
