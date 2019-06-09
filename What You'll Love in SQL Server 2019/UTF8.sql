-- Let's see what collations are available
select * from sys.fn_helpcollations() where name like '%UTF8'

GO
USE WideWorldImporters
GO
DROP TABLE IF EXISTS dbo.UTF8
GO
CREATE TABLE dbo.UTF8 (id int, name nchar(50), nameUTF8 char(50) collate LATIN1_GENERAL_100_CI_AS_SC_UTF8) 
GO
SELECT * FROM dbo.UTF8
GO
INSERT dbo.UTF8 (id, name, nameUTF8) values (1,'ༀ ༁ ༂ ༃ ༄ ༅ ༆ ༇ ༈ ༉','ༀ ༁ ༂ ༃ ༄ ༅ ༆ ༇ ༈ ༉')
GO
SELECT DATALENGTH([name]) as UTF16_Size, DATALENGTH([nameUTF8]) as UTF8_Size from dbo.uTF8
GO

select * from sys.databases