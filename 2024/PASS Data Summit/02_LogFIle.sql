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

USE Scratch
GO

CREATE TABLE [dbo].[People](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[firstname] [varchar](50) NULL,
	[lastname] [varchar](100) NULL
) ON [PRIMARY]
GO
INSERT dbo.People (FirstName,Lastname) values ('John','Morehouse')
go

-- lets look at VLF's
 DBCC LOGINFO()
 GO

SELECT * FROM sys.dm_db_log_info ( db_id() )
GO

-- Shrink the log file
DBCC SHRINKFILE (Scratch_log,1)
--
/*** run as a block ***/
CHECKPOINT;

-- LOG file examination
BEGIN TRANSACTION LogDemo;
 
-- update a row
UPDATE dbo.people
   SET firstname = 'Monica';

SELECT operation,
       context,
       allocunitid,
       AllocUnitName,
       [Oldest Active Transaction ID],
       [Xact ID],
       [Lock Information],
       [description], *
  FROM ::fn_dblog(NULL, NULL);

ROLLBACK;

-- CHECK OUT THE LOG FILE AFTER ROLLBACK
SELECT [Current LSN],
        operation,
       context,
       allocunitid,
       AllocUnitName,
       [Oldest Active Transaction ID],
       [Xact ID],
       [Lock Information],
       description,
       [Log Record]
  FROM ::fn_dblog(NULL, NULL);

 /** end block **/
