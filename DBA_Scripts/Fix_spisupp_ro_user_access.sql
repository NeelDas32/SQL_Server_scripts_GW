use DB_Name
go

IF EXISTS (SELECT 'X'
           FROM DB_Name.dbo.sysusers
                WHERE name = 'spisupp_ro_user')
  BEGIN
       EXEC ('sp_revokedbaccess ' + 'spisupp_ro_user' )
       EXEC ('sp_grantdbaccess ' + 'spisupp_ro_user' );
       exec sp_addrolemember 'db_datareader', 'spisupp_ro_user';
       ALTER USER spisupp_ro_user WITH DEFAULT_SCHEMA = [dbo];
  END
ELSE
   BEGIN  
       EXEC ('sp_grantdbaccess ' + 'spisupp_ro_user' );
       exec sp_addrolemember 'db_datareader', 'spisupp_ro_user';
       ALTER USER spisupp_ro_user WITH DEFAULT_SCHEMA = [dbo];
   END
go
