
USE tempdb
GO

IF DB_ID('EncryptionDemo') IS NOT NULL
	BEGIN
		DROP DATABASE EncryptionDemo; 
	END
GO

CREATE DATABASE EncryptionDemo
GO

USE EncryptionDemo
GO
SELECT * FROM sys.symmetric_keys

-- start with the master database key or dmk
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'P@ssw0rd1234'
GO
SELECT * FROM sys.symmetric_keys
go

--let's create the certificate
CREATE CERTIFICATE EncryptDemoCert   
   WITH SUBJECT = 'Just for demo purposes',   
   EXPIRY_DATE = '20991231';  -- expiration date is important
GO  

SELECT * FROM sys.certificates

-- create the symmetric key
CREATE SYMMETRIC KEY EncrypteDemoSymKey	   
WITH ALGORITHM = AES_256  
ENCRYPTION BY CERTIFICATE EncryptDemoCert;  
GO  

--stop, it's hammer time
BACKUP CERTIFICATE EncryptDemoCert TO FILE = 'c:\temp\exportedCert'

BACKUP MASTER KEY TO FILE = 'c:\temp\exportedmasterkey'   
    ENCRYPTION BY PASSWORD = 'I_Love_Pittsburgh!';   

BACKUP SERVICE MASTER KEY TO FILE = 'C:\temp\exportedSMK'
	ENCRYPTION BY PASSWORD = 'I_Love_Pittsburgh!'

OPEN MASTER KEY DECRYPTION BY PASSWORD = 'P@ssw0rd1234';   

-- create our test table to play with
CREATE TABLE dbo.People (id INT IDENTITY(1,1), FName VARCHAR(10), LName VARCHAR(10),SSN varbinary(128))
GO

-- open the key decrypting by the certificate
OPEN SYMMETRIC KEY EncrypteDemoSymKey DECRYPTION BY CERTIFICATE EncryptDemoCert
GO

-- insert our test encrypted data
INSERT dbo.People (FName, LName,SSN)
	SELECT 'John', 'Morehouse',ENCRYPTBYKEY(KEY_GUID('EncrypteDemoSymKey'),'123456789')
GO

-- close the symmetric key
CLOSE SYMMETRIC KEY EncrypteDemoSymKey
GO

-- double check our work
SELECT * FROM dbo.People
GO

OPEN SYMMETRIC KEY encryptedemosymkey DECRYPTION BY CERTIFICATE EncryptDemoCert
GO

SELECT SSN, CONVERT(VARCHAR,DECRYPTBYKEY(SSN)), CONVERT(NVARCHAR,decryptbykey(ssn)) FROM dbo.People
GO

-- EncryptByPassPhrase
DROP TABLE dbo.password
CREATE TABLE dbo.password (password VARBINARY(128))
DECLARE @pwd VARCHAR(150) = 'Password12345'
INSERT dbo.password (password) 
	SELECT ENCRYPTBYPASSPHRASE(@pwd,'Hello, my name is John')

SELECT * FROM dbo.password
DECLARE @pwd VARCHAR(150) = 'Password12345'
SELECT CONVERT(VARCHAR,DECRYPTBYPASSPHRASE(@pwd, [password])) FROM dbo.password

