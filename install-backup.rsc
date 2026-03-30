:put "Import files email-configuration and backup-script..."
/tool/fetch url="https://github.com/stans-hub/mikrotik_backup/blob/main/email-config.rsc"\
   output=file dst-path="email-config.rsc";
/tool/fetch url="https://github.com/stans-hub/mikrotik_backup/blob/main/backup-config.rsc"\
   output=file dst-path="backup-config.rsc"; 
/system/script/add name=email-config source=[/file get email-config.rsc contents];
/system/script/add name=backup-config source=[/file get backup-config.rsc contents];
