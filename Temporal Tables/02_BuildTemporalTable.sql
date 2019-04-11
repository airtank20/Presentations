USE [WideWorldImporters]
GO

IF EXISTS (SELECT 1 FROM sys.tables WHERE NAME = 'orders_temporal' AND schema_id = schema_id('sales')
	AND temporal_type > 0)
		begin 
			ALTER TABLE sales.orders_temporal_2 SET (SYSTEM_VERSIONING=OFF)
			DROP TABLE IF EXISTS sales.orders_temporal
			DROP TABLE IF EXISTS sales.orders_temporal_history
		end
GO

CREATE TABLE [Sales].[Orders_Temporal](
	[OrderID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[SalespersonPersonID] [int] NOT NULL,
	[PickedByPersonID] [int] NULL,
	[ContactPersonID] [int] NOT NULL,
	[BackorderOrderID] [int] NULL,
	[OrderDate] [date] NOT NULL,
	[ExpectedDeliveryDate] [date] NOT NULL,
	[CustomerPurchaseOrderNumber] [nvarchar](20) NULL,
	[IsUndersupplyBackordered] [bit] NOT NULL,
	[Comments] [nvarchar](max) NULL,
	[DeliveryInstructions] [nvarchar](max) NULL,
	[InternalComments] [nvarchar](max) NULL,
	[PickingCompletedWhen] [datetime2](7) NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL,
	 CONSTRAINT [PK_Sales_Orders_Temporal] PRIMARY KEY CLUSTERED 
	(
		[OrderID] ASC
	), 
	ValidFrom datetime2(7) GENERATED ALWAYS AS ROW START NOT NULL, --HIDDEN
	ValidTo datetime2(7) GENERATED ALWAYS AS ROW END NOT NULL, --HIDDEN
	PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [Sales].[Orders_Temporal_History]));

-- insert 
INSERT Sales.Orders_Temporal (
[OrderID]   
	, [CustomerID]
	, [SalespersonPersonID] 
	, [PickedByPersonID]  
	, [ContactPersonID] 
	, [BackorderOrderID]   
	, [OrderDate]  
	, [ExpectedDeliveryDate]  
	, [CustomerPurchaseOrderNumber] 
	, [IsUndersupplyBackordered] 
	, [Comments] 
	, [DeliveryInstructions]  
	, [InternalComments]
	, [PickingCompletedWhen]
	, [LastEditedBy]
	, [LastEditedWhen]
)
SELECT
	[OrderID]   
	, [CustomerID]
	, [SalespersonPersonID] 
	, [PickedByPersonID]  
	, [ContactPersonID] 
	, [BackorderOrderID]   
	, [OrderDate]  
	, [ExpectedDeliveryDate]  
	, [CustomerPurchaseOrderNumber] 
	, [IsUndersupplyBackordered] 
	, [Comments] 
	, [DeliveryInstructions]  
	, [InternalComments]
	, [PickingCompletedWhen]
	, [LastEditedBy]
	, [LastEditedWhen]
FROM sales.orders

-- check to make sure we have data
SELECT TOP 10 * FROM sales.orders_temporal
SELECT TOP 10 * FROM sales.orders_temporal_history

-- update some data
UPDATE sales.orders_temporal
SET comments = 'Customer has questions as well'
WHERE orderid = 1

WAITFOR DELAY '00:00:02'

UPDATE sales.orders_temporal
SET comments = 'Customer says that John has the best customer service ever!!!'
WHERE orderid = 2

WAITFOR DELAY '00:00:02'

UPDATE sales.orders_temporal
SET comments = 'Customer says "Damn the man!" '
WHERE orderid = 3

SELECT IIF(Year(ValidTo) = 9999, 1,0) AS IsCurrentVersion, OrderID, CustomerID, Comments, ValidFrom, ValidTo 
FROM [Sales].[Orders_Temporal]
FOR SYSTEM_TIME ALL
WHERE OrderID IN (1, 2, 3)
ORDER BY OrderID, IsCurrentVersion ASC

-- I can build my own indexes on the history table
CREATE NONCLUSTERED INDEX cli_ix1 ON sales.orders_temporal_history (orderid)

-- verify
SELECT object_name(object_id),* FROM sys.indexes
WHERE object_id in (object_id('sales.orders_temporal'),object_id('sales.orders_temporal_history'))

-- I can add columns just once; it'll be added to both locations
ALTER TABLE sales.orders_temporal
	ADD OrderComments nvarchar(250)

-- I can select directly from the history table
SELECT * FROM sales.orders_temporal_history



--select *, validto, validfrom from sales.orders_temporal
--where orderid in (1,2,3)

--update sales.orders_temporal
--set comments = 'blah blah blah'
--where orderid = 2


