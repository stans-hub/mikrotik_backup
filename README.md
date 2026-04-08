1. This program looks for configuration changes in Mikrotik's logs (made by winbox or ssh), and if finds, makes backups and log-audit, then emails those files.
Tested on ROS 7.18.2 and 7.21.
2. How to install/update: login by ssh or winbox (open terminal) and put a command:
   
 **   /tool/fetch url="https://raw.githubusercontent.com/stans-hub/mikrotik_backup/refs/heads/main/install-backup.rsc" output=file dst-path="install-backup.rsc"; /import install-backup.rsc;**

When you do so, email-settings and backup script will be downloaded and imported in your router. 
Also setup-script will add new line in section /system/scheduler to check configuration every day. 
Then editor is going to open email-configuration file. Put there settings for email-service: SMTP-server, login, pass etc.
If you want to edit email-settings later - type: /system/script/edit email-config source

3. For manual start the program use: /system/script/run backup-config

4. Script saves only 30 files (all types), older files will be deleted. You can change the number.
   
   Type: /system/script/edit backup-config source;
   Find ":local maxBackups 30" - Put the number.
