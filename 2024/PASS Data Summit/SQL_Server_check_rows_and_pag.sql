/*=============================================
  File: SQL_Server_check_rows_and_pages.sql

  Author: Thomas LaRock, https://thomaslarock.com/contact-me/
  Sourced: https://thomaslarock.com/2014/05/size-matters-table-rows-and-database-data-pages/

  Summary: This script will check the number of rows stored on a database 
  data page. The more rows on a page, the better. If you are storing few 
  rows per page then you will want to check the design, specifically the 
  column datatypes chosen.

  Date: May 5th, 2014

  SQL Server Versions: SQL2012, SQL2014

  You may alter this code for your own purposes. You may republish
  altered code as long as you give due credit. 

  THIS CODE AND INFORMATION IS PROVIDED "AS IS" WITHOUT WARRANTY
  OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT
  LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR
  FITNESS FOR A PARTICULAR PURPOSE.

=============================================*/

SELECT st.name, si.name, si.dpages, sp.rows
, 1.0*sp.rows/si.dpages AS [Ratio]
FROM sys.sysindexes si INNER JOIN sys.partitions sp
ON si.id = sp.object_id
INNER JOIN sys.tables st on si.id = st.object_id
WHERE si.dpages > 1 --objects that have used more than one page
AND st.type = 'U' --user tables only
AND si.indid = sp.index_id
AND si.rows > 1000 --objects with more than 1000 rows
ORDER BY [Ratio] ASC