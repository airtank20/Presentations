/*******************************************************************************
Written By: John Morehouse
T: @SQLRUS
E: john@jmorehouse.com
B: http://sqlrus.com

THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
PARTICULAR PURPOSE.

IN OTHER WORDS: USE AT YOUR OWN RISK.

AUTHOR ASSUMES ZERO LIABILITY OR RESPONSIBILITY

********************************************************************************/

IF db_id('Scratch') IS NOT NULL
	begin
		drop database Scratch
	END
GO
CREATE DATABASE Scratch
GO

USE Scratch
GO
IF OBJECT_ID('Sharknado') IS NOT NULL
BEGIN
	DROP TABLE Sharknado
END
GO
CREATE TABLE Sharknado (
	CustomerID INT
	, CustomerName VARCHAR(50)
	, CustomerState CHAR(2)
	)
GO


-- Insert some data!!
INSERT Sharknado
SELECT 1, REPLICATE('a', 50), 'US' UNION
SELECT 2, REPLICATE('b', 25), 'UK'
GO



-- Find the page
-- DBCC IND first!
DBCC IND('Scratch', 'Sharknado', 1)
GO

-- DBCC PAGE second!  Don't forget TF 3604!!
-- More on Trace Flags (TF): http://technet.microsoft.com/en-us/library/ms188396.aspx
-- CAUTION - Use TF's at your own risk. 
DBCC TRACEON (3604)
GO
DBCC PAGE('Scratch', 1, 328, 3)
GO
DBCC TRACEOFF (3604)
GO


-- BONUS Question!!
-- Now that we now how records & pages work, what happens with this?
USE [Scratch]
GO

IF OBJECT_ID('CustomerAddress') IS NOT NULL
	BEGIN DROP TABLE CustomerAddress END
GO
CREATE TABLE CustomerAddress (CustomerAddress VARCHAR(5000))
GO

INSERT CustomerAddress
SELECT REPLICATE('a', 4030)
GO

-- How many data pages?
DBCC ind('Scratch', 'CustomerAddress', 1)
GO

-- Let's Insert another row
INSERT CustomerAddress
SELECT REPLICATE('b', 4030)
GO

-- Now how many data pages?
DBCC ind('Scratch', 'CustomerAddress', 1)
GO	

INSERT CustomerAddress
SELECT 'c'
GO

-- Now how many pages? Why?
DBCC ind('Scratch', 'CustomerAddress', 1)
GO


-- Let's look at row-overflow storage
/****** 
USE Scratch
GO
IF OBJECT_id('Customer') IS NOT NULL
	BEGIN DROP TABLE Customer END
GO
CREATE TABLE Customer ([Name] varchar(4000)-- 1/2 of 80000
	, Address1 varchar(4000)-- 1/2 of 80000
	, City varchar(4000) -- 1/2 of 80000	 
	, [State] char(2)
	, Zip	varchar(5))
go

INSERT Customer (NAME, ADDRESS1,CITY,[STATE],ZIP)
	SELECT REPLICATE('a',4000),replicate('b',4000),replicate('c',2000),'NE','68048'

DBCC IND('Scratch', 'Customer', 1)
GO

-- What did it shove to off-row storage?
DBCC TRACEON (3604)
GO
DBCC PAGE('Scratch', 1, 352, 3)
GO
DBCC TRACEOFF (3604)
GO
***************/

--BONUS BONUS BONUS
--Let's look at blob storage.  Let's put a file into the database!!
IF OBJECT_id('FileStorageDemo') IS NOT NULL
	BEGIN DROP TABLE FileStorageDemo END
GO
CREATE TABLE FileStorageDemo (theFile VARBINARY(max))
go

INSERT FileStorageDemo (theFile)
SELECT *
FROM OPENROWSET(BULK 'C:\Users\john\Documents\GitHub\Presentations\SQL Server Databaseology\Capture.png', SINGLE_BLOB) AS x

SELECT * FROM FileStorageDemo


DBCC IND('Scratch', 'FileStorageDemo', 1)
GO

-- Let's find how this is stored.
-- Start with the Data page
-- Move to the start of the blob storage
DBCC TRACEON (3604)
GO
DBCC PAGE('Scratch', 1, 353, 3)
GO
DBCC TRACEOFF (3604)
GO