#This program looking for configuration changes in logs (made by winbox or ssh), when finds, makes backups and log-audit, then emails those files.
##################################################################################################################################################

:local period 24h;    # Set time from logs should be checked

/system/script/run email-config; 
############## PUT YOUR Email credentials   ##################################################################################
:global emailtosend
:global smtpserv
:global Fromaccount
:global Toaccount
:global pass
:global SMTPport 
:global tlsmode          
###############################################################################################################################

:global curlogstate
#################################################### START ############################################################

#Check how many changes there are...
:local currentDate [/system clock get date];
:local start ( [:timestamp] - $period);
:log info "LogChecker: Searching logs for config changes (since $start)";

:local Changecount [:len [/log find where ( ( (message~"winbox" or message~"ssh") and (message~"changed" or message~"added" or message~"removed" or message~"imported" or message~"reboot") )\
                                     and ([:totime (time)]>=$start) )] ];
:log info "LogChecker: $Changecount changes were found";
:if ( $Changecount >"0") do={  
   # If there are changes, send backups and log-audit
   :log info "LogChecker: Starting Backup...";
   #Set file names
   :local sysname [/system identity get name];
   :local filename "ab-$sysname-$currentDate";

   #Save those log-strings with changes
   /log print file="$filename.txt" where ( ( (message~"winbox" or message~"ssh") and (message~"changed" or message~"added" or message~"removed" or message~"imported" or message~"reboot") )\
                                    and ([:totime (time)]>=$start) );

   # Do backups
   :log info "Creating backup: $filename";
   /system backup save name="$filename";
   :delay 2;
    /export file="$filename";
    :delay 2;
   if $emailtosend do={
     :put "Email to smtp-server - $smtpserv";
     :log info "LogChecker: Sending Backup file via E-mail...";
      # Sending email
     /tool e-mail send from="<$Fromaccount>" to=$Toaccount server=$smtpserv port=$SMTPport user=$Fromaccount password=$pass tls=$tlsmode\
        file=("$filename.rsc,$filename.backup,$filename.txt")\
        subject=("$sysname Full Backup $currentDate")\
        body=("$sysname, see backup and log-audit files in attachments.\n$Changecount changes were found.\n\nHave a good day, RSE");
   }
}
:log info "LogChecker: Finished...";
