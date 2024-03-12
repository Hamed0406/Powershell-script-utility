
<#
    
    Take IP addres remot and check number of ESTABLISHED conecntion from remot server, It can be used for to see traffic btween frontend, WEB API and Backend 
         ./numberOfConectinos.ps1 -H <HOSTNAM  IP> -S < State{TimeWait,ESTABLISHED}>  -N <Server Name>
    Sharepoint Farm does not use any defualt port for conecntion between servers,    
#>

param (
  [string]$H,
   [string]$S,
   [string]$N
)

## Took away Error banner in case of Zerro 
 $ErrorActionPreference='stop'

# netStat -n |find "131.116.164.116" | find "ESTABLISHED" 
$result= Get-NetTCPConnection  -State $S -RemoteAddress $H -ErrorAction SilentlyContinue
$numberofConection=$result | Measure-Object -Line | Select-Object Lines

# 10 is just guest number 
if($numberofConection.Lines -lt 10) 
{
write-host "Number of $($S) conection from $($N) is " $numberofConection.Lines
write-host "CRITICAL"
  exit 2

}
else {
write-host "Number of $($S) conection from  $($N) is " $numberofConection.Lines
write-host "OK"
exit 0 

}