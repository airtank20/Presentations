
USE WideWorldImporters
GO
-- what happens in the log
CHECKPOINT 

SELECT * FROM ::fn_dblog(NULL,NULL)

-- update some data
BEGIN transaction

UPDATE sales.orders_temporal
SET comments = 'Cursors are the most evil thing ever. '
WHERE orderid = 8

WAITFOR DELAY '00:00:02'

UPDATE sales.orders_temporal
SET comments = 'Customer would like a refund of 150%'
WHERE orderid = 10

WAITFOR DELAY '00:00:02'

UPDATE sales.orders_temporal
SET comments = 'Elizabeth is like a little gopher, popping up everytime at the world "database"'
WHERE orderid = 12

COMMIT TRANSACTION

SELECT IIF(Year(ValidTo) = 9999, 1,0) AS IsCurrentVersion
, OrderID, CustomerID, Comments, ValidFrom, ValidTo 
FROM [Sales].[Orders_Temporal]
FOR SYSTEM_TIME ALL
WHERE OrderID IN (8, 10, 12)
ORDER BY OrderID, IsCurrentVersion ASC

-- what happens in the log
SELECT Operation, Context,AllocUnitName, *
FROM ::fn_dblog(NULL,NULL)
WHERE allocUnitName LIKE '%Sales.Orders_Temporal%'
