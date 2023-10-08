
/***********************************************************
					NON-ADR RUN
***********************************************************/
ALTER DATABASE ADR SET ACCELERATED_DATABASE_RECOVERY = OFF WITH ROLLBACK IMMEDIATE;
GO

USE [ADR]
GO
--
/*** run as a block ***/
CHECKPOINT;

-- LOG file examination
BEGIN TRANSACTION;
 
-- update a row
UPDATE dbo.people
   SET firstname = 'Monica';

ROLLBACK;

-- CHECK OUT THE LOG FILE AFTER ROLLBACK
SELECT operation,
       context,
       allocunitid,
       AllocUnitName,
       [Oldest Active Transaction ID],
       [Xact ID],
       [Lock Information],
       description
  FROM ::fn_dblog(NULL, NULL);

 /** end block **/



/***********************************************************
					ADR RUN
***********************************************************/

/** examing the log file after ADR **/
ALTER DATABASE ADR SET ACCELERATED_DATABASE_RECOVERY = ON WITH ROLLBACK IMMEDIATE;
GO

/*** run as a block ***/
CHECKPOINT;

BEGIN TRANSACTION;

-- update a row
UPDATE dbo.people
   SET firstname = 'Monica';

ROLLBACK;

-- CHECK OUT THE LOG FILE AFTER ROLLBACK
SELECT operation,
       context,
       allocunitid,
       AllocUnitName,
       [Oldest Active Transaction ID],
       [Xact ID],
       [Lock Information],
       description
  FROM ::fn_dblog(NULL, NULL);

  /** end block **/