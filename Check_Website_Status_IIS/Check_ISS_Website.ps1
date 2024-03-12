
<#
    
    Take -N name of site , check if it is up and running in IIS . 
    
#>

param (
  [string]$N  
)

## Took away Error banner in case of Zerro 
 $ErrorActionPreference='stop'
 $result=Get-IISSite -Name "YOUR_WEB_SITE" | Select-Object -Property  State
 $flagState=$result | Select-Object State
 if ($flagState.State -eq "Started")
 {
 write-host $N " site is running"
 write-host "OK"
exit 0
 }
 else {
write-host $N "site is not running"
write-host "CRITICAL"
  exit 2

}
