


USE WideWorldImporters
GO
DROP TABLE IF EXISTS dbo.TruncateMsg
GO
CREATE TABLE dbo.TruncateMsg (id int, Comment varchar(10)) 
GO
INSERT dbo.TruncateMsg (id, Comment) values (1,'This string is longer than 10 characters')
GO


