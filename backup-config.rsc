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
       
       :local maxBackups 30
       :local fileType   
           #backup, rsc, txt   
       :local allFiles [/file find where name~"ab-*$fileType"]
       :local fileList
       
       :global setArrayElement do={
           :local arr $1
           :local idx $2
           :local newVal $3
           :local arrLen $4   
               #[:len $arr]
           :if (($idx < 0) || ($idx >= $arrLen)) do={:put ("Index \$idx out of range [0..\$arrLen)") }
           :local newArr ([:pick $arr 0 $idx], $newVal,[:pick $arr ($idx + 1) $arrLen] );
           :return $newArr
       }
       
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
       
       ################## DELETE old files  ############################
       :foreach f in=$allFiles do={
           :local fName [/file get $f name];
           :local datePart [/file get $f last-modified];
           :set fileList ($fileList, {$datePart . "|" . $fName})}
       :local fileListLen [:len $fileList];
       
       :for i from=0 to=($fileListLen - 2) do={
           :for j from=($i + 1) to=($fileListLen - 1) do={
               :local val1 [:pick $fileList $i];
               :local val2 [:pick $fileList $j];
               :if ([:totime [ :pick $val1 0 10 ]] > [:totime [ :pick $val2 0 10 ]]) do={
                   :set $fileList [$setArrayElement $fileList $i $val2 $fileListLen ];
                   :set $fileList [$setArrayElement $fileList $j $val1 $fileListLen ];
               } }}
       :local toDelete ($fileListLen - $maxBackups)
       :if ($toDelete > 0) do={
           :for i from=0 to=($toDelete - 1) do={
               :local oldEntry [:pick $fileList $i]
               :local oldFileName [:pick $oldEntry 20 [:len $oldEntry]]
               :do {/file remove $oldFileName} on-error={}
               :put "Backup: removed $oldFileName"    }}
