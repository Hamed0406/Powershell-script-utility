

## Get name of server and check how maney conection is to IIS ## 

param (
  [string]$S 
)

# IIS Admin module 
Import-Module WebAdministration
$counter=Get-Counter "\Web Service(*)\Current Connections" 

# Get number of conections 
$totalConectinos=$counter.CounterSamples.Count 

Write-Output("Total number of connection to IIS (web servise) "+ $S +" is " +$totalConectinos)


if ($totalConectinos -ge 300 )
 {
 write-host $S  " number of conectino is CRITICAL "
  exit 2
 }
 else {
 write-host  $S " conectino is OK"
 
exit 0


}

