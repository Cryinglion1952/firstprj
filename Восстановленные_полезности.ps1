workflow  wfSetDNS {

 

 param($computerName)



foreach -parallel($computer in $computerName) {

Copy-Item "\\himadmin\d$\adext.dll" -Destination "\\$computer\c$"



       #inlinescript {if ((Get-WmiObject win32_networkadapterconfiguration -ComputerName $Using:computer.DNSHostName `

        #      -filter «ipenabled = ‘true'»).SetDNSServerSearchOrder(@(«172.0.0.10», «172.0.0.11»)).ReturnValue -eq 0 ) {«$($Using:computer.DNSHostName) — Ok»} else {«$($Using:computer.DNSHostName) — Error»}}

     }

 

}

 

#$comps = Get-Content C:\computerlist.txt | % {$_.Trim()} | % { Get-ADComputer  $_ }

#$comps = Get-ADComputer -Filter * -SearchBase «OU=Main,DC=domain,DC=ru»

$comps = "yar-virt02","yam-admin"

wfSetDNS $comps

===========================================================================================================


Clear-Host
$RRR = Get-Content -Raw H:\bat\1c7\users.usr
$string1 = $rrr -replace  '(\r|\n)', ''

Write-Host "Начал работать"
$string3 = $string1 -replace  '.*(Container\.Contents)', ''
$string4 = $string3 -replace  '}}.*', ''
#$string5 = $string4 -replace  '(?<!([А-Я]|[а-я]|_))' 
Write-Host "Обрубил хвосты"

$string5 =$null
$string5 = $string4 -replace  '([A-Za-z]|\"|\,|\d|\}|\{)'
$spisok=$string5.Split('.')
$users = @()

Write-Host "Почистил логины"

foreach ($element in $spisok)
{
if ($element -match '[А-Яа-я]')
    {
    $users = $users + $element
    Write-Host $element "Записал"
    }
else
    {
    Write-Host -ForegroundColor Red $element "Не соответствует" 
    }
}
$users

============================================================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = 'Select a Computer'
$form.Size = New-Object System.Drawing.Size(300,200)
$form.StartPosition = 'CenterScreen'

$OKButton = New-Object System.Windows.Forms.Button
$OKButton.Location = New-Object System.Drawing.Point(75,120)
$OKButton.Size = New-Object System.Drawing.Size(75,23)
$OKButton.Text = 'OK'
$OKButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
$form.AcceptButton = $OKButton
$form.Controls.Add($OKButton)

$CancelButton = New-Object System.Windows.Forms.Button
$CancelButton.Location = New-Object System.Drawing.Point(150,120)
$CancelButton.Size = New-Object System.Drawing.Size(75,23)
$CancelButton.Text = 'Cancel'
$CancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
$form.CancelButton = $CancelButton
$form.Controls.Add($CancelButton)

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(280,20)
$label.Text = 'Please select a computer:'
$form.Controls.Add($label)

$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10,40)
$listBox.Size = New-Object System.Drawing.Size(260,20)
$listBox.Height = 80

[void] $listBox.Items.Add('Screen in building 1 first floor')
[void] $listBox.Items.Add('Screen in building 1 second floor')
[void] $listBox.Items.Add('Screen in building 2 4th floor')
[void] $listBox.Items.Add('Screen in building 3 basement')

$form.Controls.Add($listBox)

$form.Topmost = $true

$result = $form.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK)
{
    $c = Get-Credential Domain\Username
    Restart-Computer -ComputerName "Variable 2 of selection from listbox" -Credential $c -Force
    $x = $listBox.SelectedItem
    $x
}


=================================================================================================================

