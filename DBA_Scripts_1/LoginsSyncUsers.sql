SELECT

        'EXEC sp_change_users_login ''Update_One'', ''' + su.name + ''', ''' + su.name + ''''

        FROM

                sysusers su

                LEFT JOIN master.dbo.syslogins sl ON su.sid = sl.sid

        WHERE

                uid > 3                 -- exclude public, dbo, guest, INFORMATION_SCHEMA

                AND uid <> gid          -- exclude groups

                AND uid < 16384 -- exclude database roles

                AND sl.sid IS NULL      -- user not linked to a login
                
                --EXEC sp_change_users_login 'Update_One', 'sys', 'sys'