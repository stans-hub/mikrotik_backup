:put "1.Download files email-configuration and backup-script..."
:put " -email-config...";
/tool/fetch url="https://raw.githubusercontent.com/stans-hub/mikrotik_backup/refs/heads/main/email-config.rsc"\
   output=file dst-path="email-config.rsc";
:put " -backup-config...";
/tool/fetch url="https://raw.githubusercontent.com/stans-hub/mikrotik_backup/refs/heads/main/backup-config.rsc"\
   output=file dst-path="backup-config.rsc"; 

:put "\n2.Implement them into /system/scripts..."
/system/script
remove email-config;
remove backup-config;
add name=email-config source=[/file get email-config.rsc contents];
add name=backup-config source=[/file get backup-config.rsc contents];

:put "3. Create a scheduler";
#/system/scheduler/remove backup-config;
/system/scheduler/add name="backup-config" start-time="16:48:00" interval=1d on-event="/system script run backup-config"

:put "4. Edit email-creds";
:delay 4;
edit email-config source;
/
