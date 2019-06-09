


use WideWorldImporters
GO
CREATE TABLE dbo.table1 (id int, fname varchar(20))
GO
INSERT dbo.table1 (id, fname) select 1,'John'
GO

BEGIN TRANSACTION
UPDATE dbo.Table1
SET fname = 'John'  --I'm just setting it back to the same value; it doesn't matter what I'm setting it to
WHERE id = 1
GO
rollback

-- start in a secondary session
-- Note the Pagelock: not recommends for production usage
SELECT * FROM dbo.Table1 WITH (PAGLOCK) 

-- in a third session
-- page id, file id, db id
SELECT d.page_resource,page_info.* 
FROM sys.dm_exec_requests AS d 
CROSS APPLY sys.fn_PageResCracker (d.page_resource) AS r 
CROSS APPLY sys.dm_db_page_info(r.db_id, r.file_id, r.page_id, 1) AS page_info