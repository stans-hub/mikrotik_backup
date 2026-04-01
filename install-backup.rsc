:put "1.Download files email-configuration and backup-script..."
:put " -email-config...";
/tool/fetch url="https://raw.githubusercontent.com/stans-hub/mikrotik_backup/refs/heads/main/email-config.rsc"\
   output=file dst-path="email-config.rsc";
:put " -backup-config...";
/tool/fetch url="https://raw.githubusercontent.com/stans-hub/mikrotik_backup/refs/heads/main/backup-config.rsc"\
   output=file dst-path="backup-config.rsc"; 

:put "\n2.Implement the program into /system/scripts..."
/system/script
:do {remove backup-config} on-error={};
add name=backup-config source=[/file get backup-config.rsc contents];

:put "3. Create a scheduler";
:do {/system/scheduler/remove backup-config} on-error={:put "\tScheduler has been set before installation"};
/system/scheduler/add name="backup-config" start-time="03:15:00" interval=1d on-event="/system script run backup-config"

:put "4. Edit email-creds";
:if ([find where name=email-config]) do={
    :put "\tThere's email-config already. If you need to edit it, use: \n\t/system/script edit email-config source"
    } else={:delay 4;
		add name=email-config source=[/file get email-config.rsc contents]
		edit email-config source;
			}
:put "For manual start type:\n\t/system/script/run backup-config"
/
