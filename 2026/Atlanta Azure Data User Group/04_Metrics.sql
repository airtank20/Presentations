  -- Let's look at the locks taken for who
  SELECT spid, 
     resource_type ,
     COUNT(*) LockCounts,
     s.IsoptimizedLockingEnabled
 FROM dbo.locks l
    inner join dbo.Sessions s on l.spid = s.sessionID
 WHERE resource_type IN ('KEY','PAGE','OBJECT','XACT')
 GROUP BY spid, resource_type, s.IsoptimizedLockingEnabled

 