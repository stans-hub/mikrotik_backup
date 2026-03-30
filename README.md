1. This program looks for configuration changes in Mikrotik's logs (made by winbox or ssh), and if finds, makes backups and log-audit, then emails those files.
Tested in ROS 7.18.2 and 7.21.
2. How to install: log in by ssh or winbox (open terminal) and put commands:
   
    /tool/fetch url="https://raw.githubusercontent.com/stans-hub/mikrotik_backup/refs/heads/main/install-backup.rsc" output=file dst-path="install-backup.rsc";

    /import install-backup.rsc;

When you do so, email-settings and backup sckript will be downloaded and imported in your router. 
Also setup-script will add new line in section /system/scheduler to check configuration every day. 
Then editor is going to open email-configuration file. Put there settings for email-service: SMTP-server, login, pass etc.

3. For manual start the program use:
    /system/script/run backup-config.rsc
