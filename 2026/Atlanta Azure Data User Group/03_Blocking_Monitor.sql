-- Who is waiting on locks right now?
SELECT
    r.session_id,
    r.status,
    r.wait_type,
    r.wait_time,
    r.blocking_session_id,
    DB_NAME(r.database_id) AS db_name,
    t.text
FROM sys.dm_exec_requests r
CROSS APPLY sys.dm_exec_sql_text(r.sql_handle) t
WHERE DB_NAME(r.database_id) = 'OptimizedLockingDemo'
  AND r.session_id <> @@SPID
ORDER BY r.wait_time DESC;
GO
