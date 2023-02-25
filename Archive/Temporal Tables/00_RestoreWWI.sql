

use tempdb
go
alter database wideworldimporters set single_user with rollback immediate;
go
restore database WideWorldImporters
from disk = 'C:\temp\WideWorldImporters-Full.bak'
with replace, recovery, stats = 5
go

dbcc ind('WideWorldImporters','sales.orders_temporal',1)
select * from sys.dm_db_database_page_allocations(

dbcc traceon(3604)
dbcc page('wideworldimporters',1,8232,3)
dbcc traceoff(3604)