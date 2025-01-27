/*******************************************************************************
Written By: John Morehouse
T: @SQLRUS
B: http://sqlrus.com

THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
PARTICULAR PURPOSE.

IN OTHER WORDS: USE AT YOUR OWN RISK.

AUTHOR ASSUMES ZERO LIABILITY OR RESPONSIBILITY

********************************************************************************/

ALTER DATABASE ADR SET ACCELERATED_DATABASE_RECOVERY = ON WITH ROLLBACK IMMEDIATE;
GO

USE ADR

-- look at pages quick (336)
select object_id,object_name(object_id),allocation_unit_type_desc,allocated_page_page_id,allocated_page_iam_page_id, is_iam_page, page_type_desc
from sys.dm_db_database_page_allocations(db_id(),object_id('dbo.People'),null,null,'DETAILED') 



-- show table
SELECT * FROM dbo.People



-- look at current structure
DBCC TRACEON(3604);
DBCC PAGE('ADR', 1, 336, 3);
DBCC TRACEOFF(3604);




/** change data **/
CHECKPOINT;

BEGIN TRANSACTION;

-- update a row
/** Duke Morehouse 8/11/21 **/
UPDATE dbo.people 
   SET firstname = 'Duke';

-- data page
DBCC TRACEON(3604);
DBCC PAGE('ADR', 1, 336, 3);
DBCC TRACEOFF(3604);

/**
4D6F72 65686F75 7365 = "Morehouse"
0200	0000	  0203	fcff	9a04
page	unknown	  file	slot	time
**/

-- look at inrow/offrow PVS
SELECT index_id,
       index_level,
       page_count,
       record_count,
       version_record_count,
       inrow_version_record_count,
       inrow_diff_version_record_count,
       total_inrow_version_payload_size_in_bytes,
       offrow_regular_version_record_count,
       offrow_long_term_version_record_count
  FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.people'), NULL, NULL, 'DETAILED');

-- look at the off-row version
-- note the xdes_ts_push value
SELECT *
  FROM sys.dm_tran_persistent_version_store;
  
-- update a row
/** Pete Morehouse 5/6/21 **/
UPDATE dbo.people
   SET firstname = 'Pete';

-- data page -  look at version history
DBCC TRACEON(3604);
DBCC PAGE('ADR', 1, 336, 3);
DBCC TRACEOFF(3604);
 
/**
PartitionId = 
8001 0080	0100	0000	0316
page		file	slot	time
**/
-- Transaction Timestamp 5643


 -- look at inrow/offrow PVS
SELECT index_id,
       index_level,
       page_count,
       record_count,
       version_record_count,
       inrow_version_record_count,
       inrow_diff_version_record_count,
       total_inrow_version_payload_size_in_bytes,
       offrow_regular_version_record_count,
       offrow_long_term_version_record_count
  FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.people'), NULL, NULL, 'DETAILED');

-- look at the off-row version
-- get rowset_id
SELECT *
  FROM sys.dm_tran_persistent_version_store;

  /**
select partition_id, object_name(object_id) ObjectName
	FROM sys.partitions where partition_id = 72057594043170816
**/
   
ROLLBACK;


-- KEEP SCROLLING




/** 
	Let's do that again, this time looking at extended events 

	note to John: start the XE session
**/


BEGIN TRANSACTION;

-- update a row skipping in-row versioning
UPDATE dbo.people
   SET firstname = 'Duke';
   
UPDATE dbo.people
   SET firstname = 'Pete';


/** 
	Get the PVS page ID from XE, look at the record prior to the pvs_add_record 
**/
-- this is the original data page
DBCC TRACEON(3604);
DBCC PAGE('ADR', 1, 392, 3);
DBCC TRACEOFF(3604);
-- page = 8801 0080
-- file = 0100
-- slot = 0300
-- timestamp = 1316

rollback

-- just confirm the PVS page is a data page that we can look at
-- look at 2nd column -- it's allocated to the PVS
DECLARE @page INT = 392
SELECT object_id,object_name(object_id),allocation_unit_type_desc,allocated_page_page_id,allocated_page_iam_page_id, is_iam_page, page_type_desc
FROM sys.dm_db_database_page_allocations(db_id(),null,null,null,'DETAILED') 
WHERE allocated_page_page_id = @page




-- data page
/* examine: xdes_ts_push values, see the version values themselves */

DBCC TRACEON(3604);
DBCC PAGE('ADR', 1, 392, 3);
DBCC TRACEOFF(3604);

-- compare xdes_ts_push values
SELECT *
  FROM sys.dm_tran_persistent_version_store;

SELECT *
	FROM sys.dm_tran_active_transactions;

 -- look at inrow/offrow PVS
SELECT index_id,
       index_level,
       page_count,
       record_count,
       version_record_count,
       inrow_version_record_count,
       inrow_diff_version_record_count,
       total_inrow_version_payload_size_in_bytes,
       offrow_regular_version_record_count,
       offrow_long_term_version_record_count
  FROM sys.dm_db_index_physical_stats(DB_ID(), OBJECT_ID('dbo.people'), NULL, NULL, 'DETAILED');

ROLLBACK


/** If audience wants more, show the call stack and call stack resolver **/
-- get the call stack info
SELECT       n.query('.') AS callstack
  FROM       (   SELECT      CAST(target_data AS XML)
                   FROM      sys.dm_xe_sessions AS s
                  INNER JOIN sys.dm_xe_session_targets AS t
                     ON s.address = t.event_session_address
                  WHERE      s.name   = 'PVS_Tracking'
                    AND      t.target_name = 'ring_buffer') AS src(target_data)
 CROSS APPLY target_data.nodes('RingBufferTarget/event/action[@name="callstack"]') AS q(n);



 /** use call stack resolver **/
 /**Bp Sqlmin!VersionMgr::AddRecordToPVS**/

