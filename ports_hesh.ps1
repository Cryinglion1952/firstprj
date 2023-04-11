#  ==================================================================================
#  Clients

$xmldata = [xml](Get-Content "H:\GIT\ps\kkt\CashRegisterSvc.exe.config")
$confdata = $xmldata.configuration.clients.client.add
$confdata | gm

$("Comp = " + $confdata.GetAttribute("ip"))


<clients>
    <!--Если указать, то ошибка: Нет доступных ККМ-->
    <client>
      <add ip="BL-OFORM-SL02.corp.intra" />
      <add ip="BL-OFORM-SL03.corp.intra" />
      <add ip="BL-KASSA01.corp.intra" />
    </client>
  </clients>


#  ==================================================================================
#  PORTS


$comp = "him-oformvw06"

$xmldata = [xml](Get-Content "\\$comp\c$\kkt\00106702707988\CashRegisterSvc.exe.config")
$confdata = $xmldata.configuration.appSettings.add
# $port = $confdata | ? key -eq "PortNumber"
$port = $confdata | where {($_.key -eq "PortNumber")}
# -or ($_.key -eq "SerialNumber")}
$pv = $port.value  #Port Value
$pv = "COM" + $pv

$spis = invoke-command -cn $comp -ScriptBlock {Get-PnpDevice -PresentOnly}
$mashinki = $spis | where {($_.Name -match "ATOL")}
$mashinki.Name
$mash_port = $mashinki.Name -replace '.+COM|\)'
$mash_port

$COMportList = invoke-command -cn $comp -ScriptBlock {[System.IO.Ports.SerialPort]::getportnames()}
$COMportList


Write-Output "Порт из конфы $pv"
$mash_port
$COMportList


#| {$_ -replace '(.+(?=COM\d*)')}
#$mash_port -replace '.+COM|\)'
#$mash_port -replace '.+(?=COM\d*'
$mash_port

#$spis = invoke-command -cn him-oformvw06 -ScriptBlock {Get-CimInstance -Class Win32_SerialPort}
#$spis
#$spis.DeviceID 

if ($pv -eq $spis.DeviceID)
{
Write-host "Порт есть"
}
else
{
Write-Host "Порт не найден"
}
Write-Output "================================================================="
Write-Output $pv + ":" + $spis.DeviceID







$spis = Get-CimInstance -Class Win32_SerialPort
# | Select-Object DeviceID
$spis.DeviceID 





# $port.Count


$port |%{
    if($_.key -eq "PortNumber"){
        Write-host $_.value
    }
}



 
){
        Write-host $_.value
    }





 
 $trp = $port.GetElementsByTagName('PortNumber')

 $trp
 

foreach ($pt in $port)
{
write-host "Значение = " $pt.key
}


 | gm
