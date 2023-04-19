
# ОГЛАВЛЕНИЕ

# **03  - Отправка почты
# **11  - Функция Конвертации
# **55  - Отрисовка формы Пользователей
# **77  - Отрисовка основной Формы



#Удаление всех переменных
Remove-Variable -Name * -Force -ErrorAction SilentlyContinue

# ==== Подтягиваются данные из AD =======
Import-Module ActiveDirectory
$userobj = (Get-ADUser -filter {Enabled -eq "true"} -properties Name, displayname,EmailAddress,pwdLastSet -SearchBase ‘OU=BO,DC=corp,DC=intra’)

#Запуск от имени админа 

If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))

{   
$arguments = "& '" + $myinvocation.mycommand.definition + "'"
Start-Process powershell -Verb runAs -ArgumentList $arguments
Break
}



#Запуск в скрытом режиме 
$t = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
add-type -name win -member $t -namespace native
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)


#Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass –Force
Set-ExecutionPolicy Bypass –Force -Scope CurrentUser

# cls




#=======================================================================================================
#    ФУНКЦИЯ ОСНОВНОГО ДЕЙСТВИЯ
#=======================================================================================================



function pingik 
 {
   # проверка пинга компа 
   #Замена запятых и ю на точку 
$textbox2.Text = $textbox2.Text.Replace(",",".")
$textbox2.Text = $textbox2.Text.Replace("ю",".")
$textbox2.Text = $textbox2.Text.Replace("Ю",".")
$textbox2.Text = $textbox2.Text.Replace("/",".")

 
if ( (Test-Connection -ComputerName $textbox2.Text -Count 1 -Quiet)  -eq $false)
    {
    $impdata = $textbox2.Text
    $textbox2.ForeColor = "red"
    $textbox2.Text = $impdata + " - Кривые данные"
    #[System.Windows.Forms.MessageBox]::Show("Хрен подключишся К " + $textbox2.Text )
    }
else 
    {
    $textbox2.ForeColor = "green"
    OsnovnoeDeystvie
    }
}


function OsnovnoeDeystvie  {
   #переменные даты и времени 
$date = Get-Date -Format "dd_MM_yy"
$datetime = Get-Date -Format "HH:mm"

   #переменная запуска Daemware 
$daem = "C:\Program Files\SolarWinds\DameWare Mini Remote Control x64\DWRCC.exe"
#$allargs  = @('-h:''-c:''-x')

#Запуск Daemware
If ($CheckBoxDW.Checked -eq $true)
{
& $daem -h: -c: -m:$textbox2.Text -x
}
$CheckBoxDW.Checked = $true

 #Получаем логин пользователя 
$userinfo = Get-WmiObject -ComputerName $textbox2.Text -Class Win32_ComputerSystem
$user = $userinfo.UserName -split '\\'

   #Получаем  почту пользователя
$pochta = Get-ADUser $user[1]-Properties * |ft -HideTableHeaders EmailAddress |Out-String
   #Убираем пробелы
$pochta = $pochta.Trim()
   #Получаем ФИО пользователя
$fio = Get-ADUser  $user[1]-Properties * |ft -HideTableHeaders name |Out-String
   #Убираем пробелы
$fio = $fio.Trim()

   #переменная логина
$login = $user[1]
#Убираем пробелы
$login = $login.Trim()

   #Получаем имя компьютера по ip адресу
$comp = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $textbox2.Text  |ft -HideTableHeaders name |out-string
   #Убираем пробелы
$comp = $comp.Trim()

$targetcomp = ($textbox2.Text|Out-String).Trim()
$statusLabel.Text = "Подключен к $targetcomp"

   #Вывод в текстовый  файл лога 
#"имя диска $login.hc `n имя диска  $login.tc ` $comp,  $fio, $datetime,$rabota" |Out-String | out-file -filepath D:\daemware\daemware.txt -append -Force

 #настройки скрипта отправки почты
$SmtpServer='k0mail.corp.intra'
   #от кого 
$From=$pochta
   #кому
 $To='karpushin.r.a@avtomir.ru'
 #$To='vik@avtomir.ru'
 $To2='911@avtomir.ru' 
   #копия письма 
 #$Cc='vik@avtomir.ru'
# тема письма 
$Subject = $fio                
# конец настроек скрипта

# **03

$encoding = [System.Text.Encoding]::UTF8

$Body     = "
 
Имя пользователя  =     $fio

Название работы =   $rabota
имя компа =         $comp   
Время настройки =   $datetime
Выполнил Карпушин Р. 
 "
                                              
IF ($mailflag -eq $true)
{ 
  #[System.Windows.Forms.MessageBox]::Show("Отправил Заявку")::end                  
 Send-MailMessage -Encoding $encoding -SmtpServer $SmtpServer -From $From -To $To -Subject  "Обращение в Службу поддержки"  -Body $Body 
 Send-MailMessage -Encoding $encoding -SmtpServer $SmtpServer -From $From -To $To2   -Subject  "Обращение в Службу поддержки"  -Body $Body
}
#else {[System.Windows.Forms.MessageBox]::Show("НЕЕ Отправил Заявку")}
else{ $statusLabel.Text ="НЕ Отправил Заявку"
sleep 10
$statusLabel.Text ="Готов"}




   #вывод в форму фио  
  $textbox4.Text = $fio
   #вывод в форму логина 
   $pgp = $login +' '

$textbox3.Text =$login


#===================== ВРЕМЯ РАБОТЫ КОМПА ===========================================


	$TimeUp = Invoke-Command -ComputerName $comp {(Get-WmiObject Win32_OperatingSystem).LastBootUpTime}
	$TimeUp = [Management.ManagementDateTimeConverter]::ToDateTime($TimeUp)
	$TimeUp1 = Get-Date
	$tt = ($TimeUp1 - $TimeUp)
	$t1 = $tt.Days
	$t2 = $tt.Hours
	$t3 = $tt.Minutes
	#$RupTextBox1.text = $name
	#$RupTextBox2.text = $login
	#$tsk = $pd6.text
	#$RupTextBox3.text = $NameHost + " ($tsk)"
	#$RupTextBox4.text = $nlp1

    if ($t1 -ge 1)
	{
	$Ruplabel10.BackColor = "red"
	#$oplabel2.Text = "ПК требует апгрейда"
	}
	else
	{
	$Ruplabel10.BackColor = "green"
	}


    $Ruplabel9.Visible = $true
    $Ruplabel10.Visible = $true
    $Ruplabel10.text = "$t1 дней, $t2 часов, $t3 минут"

    $photouser = Get-ADUser -Identity $textbox3.Text -PR * |Select-Object thumbnailPhoto 
    $pictureBox.Image = $photouser.thumbnailPhoto
	

}

# **11
function convertik {

   #Получаем имя компьютера по ip адресу
$comp = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $textbox2.Text  |ft -HideTableHeaders name |out-string
   #Убираем пробелы
$comp = $comp.Trim()
#[System.Windows.Forms.MessageBox]::Show("Ура на компе  " + $textbox2.Text + " Работа " )
$statusLabel.Text ='идет проверка диска H'
invoke-command -ComputerName $comp {chkdsk h: /f /x}
#[System.Windows.Forms.MessageBox]::Show("Ура на компе  " + $comp + " Работа " )
$statusLabel.Text ='идет конвертирование  диска H'
invoke-command -ComputerName $comp {convert h: /fs:ntfs /x /nosecurity}
#[System.Windows.Forms.MessageBox]::Show("Ура на компе  " +$comp + " Диск H в NTFS " )
$statusLabel.Text ="Ура на компе  " + $comp + " Диск H в NTFS "
sleep 10
$statusLabel.Text ="Готов"
}

function test {
[System.Windows.Forms.MessageBox]::Show("Ура на компе  " + $textbox2.Text + " Работа " ) }



#=======================================================================================================
#   КОНЕЦ ФУНКЦИИ ОСНОВНОГО ДЕЙСТВИЯ
#=======================================================================================================

################################################################## Functions
function OpenFile {
    $statusLabel.Text = "Open File"
	$selectOpenForm = New-Object System.Windows.Forms.OpenFileDialog
	$selectOpenForm.Filter = "All Files (*.*)|*.*"
	$selectOpenForm.InitialDirectory = ".\"
	$selectOpenForm.Title = "Select a File to Open"
	$getKey = $selectOpenForm.ShowDialog()
	If ($getKey -eq "OK") {
            $inputFileName = $selectOpenForm.FileName
	}
    $statusLabel.Text = "Ready"
}

function SaveAs {
    $statusLabel.Text = "Save As"
    $selectSaveAsForm = New-Object System.Windows.Forms.SaveFileDialog
	$selectSaveAsForm.Filter = "All Files (*.*)|*.*"
	$selectSaveAsForm.InitialDirectory = ".\"
	$selectSaveAsForm.Title = "Select a File to Save"
	$getKey = $selectSaveAsForm.ShowDialog()
	If ($getKey -eq "OK") {
            $outputFileName = $selectSaveAsForm.FileName
	}
    $statusLabel.Text = "Ready"
}

function SaveFile {
}

# **55
# ===== КНОПКА РАЗБЛОКИРОВКИ ПОЛЬЗОВАТЕЛЕЙ  ========================================
function FullScreen {
# [System.Windows.Forms.MessageBox]::Show("Загрузка базы может занять секунд 30" )

# $userobj=  (Get-ADUser -filter {Enabled -eq "true"} -properties Name, displayname,EmailAddress,pwdLastSet -SearchBase ‘OU=BO,DC=corp,DC=intra’)
$seluser = $userobj | Out-GridView –title “Выберите пользователя чтобы сбросить пароль” -PassThru 
$oumassiv = ((Get-ADUser -Identity $seluser -Properties *).CanonicalName).Split("/")

# [System.Windows.Forms.MessageBox]::Show("Пользователь в домене  " + $oumassiv[2] + "!" )

$uform = New-Object System.Windows.Forms.Form
$uform.Text = "Работа с Пользователем "
$uform.StartPosition = "manual"
$uform.Location = "1000, 200"
$uform.AutoSize = $true
$uform.Size = New-Object System.Drawing.Size(390,450)

$ulabel1 = New-Object System.Windows.Forms.label
$ulabel1.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",$Object_title.size,[System.Drawing.FontStyle]::Bold)
$ulabel1.Text = "User:  " + $seluser.name
$ulabel1.Location = New-Object System.Drawing.Point(20,20)
$ulabel1.AutoSize = $true
$ulabel1.Visible = $true
$uform.Controls.Add($ulabel1)

$ulabel2 = New-Object System.Windows.Forms.label
$ulabel2.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",$Object_title.size,[System.Drawing.FontStyle]::Regular)
$ulabel2.Text = " Интернет "
$ulabel2.Location = New-Object System.Drawing.Point(20,60)
$ulabel2.AutoSize = $true
$ulabel2.Visible = $true
$uform.Controls.Add($ulabel2)

$ulabel3 = New-Object System.Windows.Forms.label
$ulabel3.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",$Object_title.size,[System.Drawing.FontStyle]::Regular)
$ulabel3.Text = " CPN "
$ulabel3.Location = New-Object System.Drawing.Point(20,100)
$ulabel3.AutoSize = $true
$ulabel3.Visible = $true
$uform.Controls.Add($ulabel3)

$ulabel4 = New-Object System.Windows.Forms.label
$ulabel4.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",$Object_title.size,[System.Drawing.FontStyle]::Regular)
$ulabel4.Text = " Lync "
$ulabel4.Location = New-Object System.Drawing.Point(20,140)
$ulabel4.AutoSize = $true
$ulabel4.Visible = $true
$uform.Controls.Add($ulabel4)

$ulabel5 = New-Object System.Windows.Forms.label
$ulabel5.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",$Object_title.size,[System.Drawing.FontStyle]::Regular)
$ulabel5.Text = " Учетка активна "
$ulabel5.Location = New-Object System.Drawing.Point(20,180)
$ulabel5.AutoSize = $true
$ulabel5.Visible = $true
$uform.Controls.Add($ulabel5)

$ulabel5 = New-Object System.Windows.Forms.label
$ulabel5.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",$Object_title.size,[System.Drawing.FontStyle]::Regular)
$ulabel5.Text = " Пароль истекает: "
$ulabel5.Location = New-Object System.Drawing.Point(20,220)
$ulabel5.AutoSize = $true
$ulabel5.Visible = $true
$uform.Controls.Add($ulabel5)





    # if (2 -ge 1)
	#{
	$ulabel10.BackColor = "red"
	##$oplabel2.Text = "ПК требует апгрейда"
	#}
	#else
	#{
	#$ulabel10.BackColor = "green"
	#}


   
	

# }


$ulabel10 = New-Object System.Windows.Forms.label

#$ulabel1.Font =  [System.Drawing.Font]::new("Times New Roman", 9, [System.Drawing.FontStyle]::Underline) 
$ulabel10.Font = New-Object System.Drawing.Font("Wingdings",22,[System.Drawing.FontStyle]::Bold)
$ulabel10.Text = ""
$ulabel10.Location = New-Object System.Drawing.Point(170,60)
$ulabel10.AutoSize = $true
$ulabel10.Visible = $false
$ulabel10.ForeColor = "green"
$uform.Controls.Add($ulabel10)

 $ulabel9.Visible = $true
    $ulabel10.Visible = $true
    $ulabel10.text = " ü "


$ulabel11 = New-Object System.Windows.Forms.label
$ulabel11.Font = New-Object System.Drawing.Font("Wingdings",22,[System.Drawing.FontStyle]::Bold)
$ulabel11.Text = ""
$ulabel11.Location = New-Object System.Drawing.Point(170,100)
$ulabel11.AutoSize = $true
$ulabel11.Visible = $false
#$ulabel11.BackColor = "red"
$ulabel11.ForeColor = "red"
$uform.Controls.Add($ulabel11)


    $ulabel11.Visible = $true
    $ulabel11.text = " û "


$ulabel12 = New-Object System.Windows.Forms.label
$ulabel12.Font = New-Object System.Drawing.Font("Wingdings",22,[System.Drawing.FontStyle]::Bold)
$ulabel12.Text = ""
$ulabel12.Location = New-Object System.Drawing.Point(170,140)
$ulabel12.AutoSize = $true
$ulabel12.Visible = $false
$ulabel12.ForeColor = "green"
$uform.Controls.Add($ulabel12)


    $ulabel12.Visible = $true
    $ulabel12.text = " ü "

$ulabel13 = New-Object System.Windows.Forms.label
$ulabel13.Font = New-Object System.Drawing.Font("Wingdings",22,[System.Drawing.FontStyle]::Bold)
$ulabel13.Text = ""
$ulabel13.Location = New-Object System.Drawing.Point(170,180)
$ulabel13.AutoSize = $true
$ulabel13.Visible = $false
$ulabel13.ForeColor = "green"
$uform.Controls.Add($ulabel13)


    $ulabel13.Visible = $true
    $ulabel13.text = " ü "


$ulabel14 = New-Object System.Windows.Forms.label
$ulabel14.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",$Object_title.size,[System.Drawing.FontStyle]::Regular)
$ulabel14.Text = " 01.07.2022 "
$ulabel14.Location = New-Object System.Drawing.Point(160,220)
$ulabel14.AutoSize = $true
$ulabel14.Visible = $true
$ulabel14.ForeColor = "green"
$uform.Controls.Add($ulabel14)

$pictureBox = new-object Windows.Forms.PictureBox
$pictureBox.Location = New-Object System.Drawing.Size(50,50)
$pictureBox.Size = New-Object System.Drawing.Size($img.Width,$img.Height)
$pictureBox.Image = $seluser.thumbnailPhoto
$uform.controls.add($pictureBox)



# Кнопки 
$uButton1 = New-Object System.Windows.Forms.Button
$uButton1.Location = New-Object System.Drawing.Point(50,290)
$uButton1.Font =  [System.Drawing.Font]::new("Times New Roman", 9, [System.Drawing.FontStyle]::bold) 
$uButton1.Text               =  " Наградить медалью "
$uButton1.Size = New-Object System.Drawing.Size(120,50)
#  вызываем функцию отправки сообщения
$uButton1.add_click({
[System.Windows.Forms.MessageBox]::Show("Награждение произведено" )

})

#вывод на форму 
$uform.Controls.Add($uButton1)

$uButton2 = New-Object System.Windows.Forms.Button
$uButton2.Location = New-Object System.Drawing.Point(190,290)
$uButton2.Font =  [System.Drawing.Font]::new("Times New Roman", 9, [System.Drawing.FontStyle]::bold) 
$uButton2.Text               =  " Наградить орденом "
$uButton2.Size = New-Object System.Drawing.Size(120,50)
#  вызываем функцию отправки сообщения
$uButton2.add_click({
[System.Windows.Forms.MessageBox]::Show("Награждение произведено" )

})

#вывод на форму 
$uform.Controls.Add($uButton2)

$uform.Topmost = $true

$result = $uform.ShowDialog()


 
 
# $url = "https://yandex.ru" 
# $ie = New-Object -com internetexplorer.application; 
# $ie.visible = $true; 
# $ie.navigate($url);

}

function Terms {
$url = "http://avtomirnet.corp.intra/info/DocLib2/Forms/All.aspx?RootFolder=%2Finfo%2FDocLib2%2F%D0%A6%D0%95%D0%9D%D0%A2%D0%A0&FolderCTID=0x012000BB6B47D4371AA347930759025EB5D92D&View={61FE4A15-BEED-445E-AE13-5CD147EE3E9B}" 
$ie = New-Object -com internetexplorer.application; 
$ie.visible = $true; 
$ie.navigate($url);

}

function DAEM {
$mailflag = $false
pingik
}

function Knopki_2010 {

$ProgressBar = New-Object System.Windows.Forms.ProgressBar
$ProgressBar.Location  = New-Object System.Drawing.Point(170,350)
$ProgressBar.Value = 5
$ProgressBar.Visible = $true
$form.Controls.add($ProgressBar)

$targetcomp = ($textbox2.Text|Out-String).Trim()
$statusLabel.Text = "Подключение к $targetcomp"

$path = "\\ftp\install\Avtomir\utils\lnk\"
$path_c = "\\ftp\install\Avtomir\utils\c\"
$path_s = "\\ftp.corp.intra\install\Avtomir\utils\send\"

# [System.Windows.Forms.MessageBox]::Show("Готов копировать" )

$ProgressBar.Value = 30
$ProgressBar.Refresh()
$statusLabel.Text = "Получаю список обновляемых профилей"


if ((Test-Connection -count 1 -computer $targetcomp -quiet) -eq $true)
{

if ((Test-Path -Path $path) -ne $false)
{
$path1 = "\\$targetcomp\c$\users\"
$path1_c = "\\$targetcomp\c$\"
$dir = (Get-ChildItem -Path $path1 -Directory).Name
$dir += "default"

$ProgressBar.Value = 60
$ProgressBar.Refresh()
$statusLabel.Text = "Начал копировать"

foreach ($i in $dir)
{
$path2 = "$path1$i\Quick Start\"
$path3 = "$path1$i\AppData\Roaming\Microsoft\Windows\SendTo\"

if ((Test-Path -Path $path2) -ne $false)
{
Get-ChildItem -Path $path2 | Where {$_.Name -Like "*2010*"} | Remove-Item -force
Copy-Item -Path "$path\*.*" -Destination $path2 -Force
}
Copy-Item -Path "$path_s\*.*" -Destination $path3 -Force
}
Copy-Item -Path "$path_c\*.*" -Destination $path1_c -Force

$ProgressBar.Value = 80
$ProgressBar.Refresh()
$statusLabel.Text = "Ярлыки скопированы"
$statusLabel.Refresh()
$ProgressBar.Refresh()
}
else
{
$statusLabel.Text = "Указанный путь не существует"
}
}
else 
{
$statusLabel.Text = "$targetcomp не доступен"
}
$ProgressBar.Value = 99
$ProgressBar.Refresh()
sleep 20
$ProgressBar.Refresh()
$statusLabel.Text ="Готов"
$ProgressBar.Visible = $false
}



function Options1 {
}

function Options2 {
}

function About {
    $statusLabel.Text = "About"
    # About Form Objects
    $aboutForm          = New-Object System.Windows.Forms.Form
    $aboutFormExit      = New-Object System.Windows.Forms.Button
    $aboutFormImage     = New-Object System.Windows.Forms.PictureBox
    $aboutFormNameLabel = New-Object System.Windows.Forms.Label
    $aboutFormText      = New-Object System.Windows.Forms.Label

    # About Form
    $aboutForm.AcceptButton  = $aboutFormExit
    $aboutForm.CancelButton  = $aboutFormExit
    $aboutForm.ClientSize    = "350, 110"
    $aboutForm.ControlBox    = $false
    $aboutForm.ShowInTaskBar = $false
    $aboutForm.StartPosition = "CenterParent"
    $aboutForm.Text          = "About FormsMenu.ps1"
    $aboutForm.Add_Load($aboutForm_Load)

    # About PictureBox
    $aboutFormImage.Image    = $iconPS.ToBitmap()
    $aboutFormImage.Location = "55, 15"
    $aboutFormImage.Size     = "32, 32"
    $aboutFormImage.SizeMode = "StretchImage"
    $aboutForm.Controls.Add($aboutFormImage)

    # About Name Label
    $aboutFormNameLabel.Font     = New-Object Drawing.Font("Microsoft Sans Serif", 9, [System.Drawing.FontStyle]::Bold)
    $aboutFormNameLabel.Location = "110, 20"
    $aboutFormNameLabel.Size     = "200, 18"
    $aboutFormNameLabel.Text     = "WinForms Menu Demo"
    $aboutForm.Controls.Add($aboutFormNameLabel)

    # About Text Label
    $aboutFormText.Location = "100, 40"
    $aboutFormText.Size     = "300, 30"
    $aboutFormText.Text     = "          Wayne Lindimore `n`r AdminsCache.WordPress.com"
    $aboutForm.Controls.Add($aboutFormText)

    # About Exit Button
    $aboutFormExit.Location = "135, 70"
    $aboutFormExit.Text     = "OK"
    $aboutForm.Controls.Add($aboutFormExit)

    [void]$aboutForm.ShowDialog()
    $statusLabel.Text = "Ready"
} # End About




# **77
#=======================================================================================================
#    МОДУЛЬ ГРАФИКИ
#=======================================================================================================


Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[Windows.Forms.Application]::EnableVisualStyles()
#Clear-Host

# Начинаем описывать форму
$form = New-Object System.Windows.Forms.Form
$form.Text = "HelpDesk Utility v. 12.04.23 Kosmonafft"
#$form.Width = 360
#$form.Height = 260
$form.StartPosition = "manual"
$form.Location = "1000, 200"
$form.AutoSize = $true
$form.Size = New-Object System.Drawing.Size(400,490)
   #переменная описания поля и кнопки 
$ToolTip = New-Object System.Windows.Forms.ToolTip
$ToolTip.BackColor = [System.Drawing.Color]::LightGoldenrodYellow
$ToolTip.IsBalloon = $true

$menuMain                 = New-Object System.Windows.Forms.MenuStrip
$menuFile                 = New-Object System.Windows.Forms.ToolStripMenuItem
$menuView                 = New-Object System.Windows.Forms.ToolStripMenuItem
$menuTools                = New-Object System.Windows.Forms.ToolStripMenuItem
$menuOpen                 = New-Object System.Windows.Forms.ToolStripMenuItem
$menuSave                 = New-Object System.Windows.Forms.ToolStripMenuItem
$menuSaveAs               = New-Object System.Windows.Forms.ToolStripMenuItem
$menuFullScr              = New-Object System.Windows.Forms.ToolStripMenuItem
$menuTerms                = New-Object System.Windows.Forms.ToolStripMenuItem
$menuDAEM                 = New-Object System.Windows.Forms.ToolStripMenuItem
$menuKnopki_2010          = New-Object System.Windows.Forms.ToolStripMenuItem
$menuOptions              = New-Object System.Windows.Forms.ToolStripMenuItem
$menuOptions1             = New-Object System.Windows.Forms.ToolStripMenuItem
$menuOptions2             = New-Object System.Windows.Forms.ToolStripMenuItem
$menuExit                 = New-Object System.Windows.Forms.ToolStripMenuItem
$menuHelp                 = New-Object System.Windows.Forms.ToolStripMenuItem
$menuAbout                = New-Object System.Windows.Forms.ToolStripMenuItem
$mainToolStrip            = New-Object System.Windows.Forms.ToolStrip
$toolStripOpen            = New-Object System.Windows.Forms.ToolStripButton
$toolStripSave            = New-Object System.Windows.Forms.ToolStripButton
$toolStripSaveAs          = New-Object System.Windows.Forms.ToolStripButton
$toolStripFullScr         = New-Object System.Windows.Forms.ToolStripButton
$toolStripDAEM            = New-Object System.Windows.Forms.ToolStripButton
$toolStripKnopki_2010     = New-Object System.Windows.Forms.ToolStripButton
$toolStripTerms           = New-Object System.Windows.Forms.ToolStripButton
$toolStripAbout           = New-Object System.Windows.Forms.ToolStripButton
$toolStripExit            = New-Object System.Windows.Forms.ToolStripButton
$statusStrip              = New-Object System.Windows.Forms.StatusStrip
$statusLabel              = New-Object System.Windows.Forms.ToolStripStatusLabel

################################################################## Icons
# WinForms Icons
# Create Icon Extractor Assembly
$code = @"
using System;
using System.Drawing;
using System.Runtime.InteropServices;

namespace System
{
	public class IconExtractor
	{

	 public static Icon Extract(string file, int number, bool largeIcon)
	 {
	  IntPtr large;
	  IntPtr small;
	  ExtractIconEx(file, number, out large, out small, 1);
	  try
	  {
	   return Icon.FromHandle(largeIcon ? large : small);
	  }
	  catch
	  {
	   return null;
	  }

	 }
	 [DllImport("Shell32.dll", EntryPoint = "ExtractIconExW", CharSet = CharSet.Unicode, ExactSpelling = true, CallingConvention = CallingConvention.StdCall)]
	 private static extern int ExtractIconEx(string sFile, int iIndex, out IntPtr piLargeVersion, out IntPtr piSmallVersion, int amountIcons);

	}
}
"@
Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing

# Extract PowerShell Icon from PowerShell Exe
$iconPS   = [Drawing.Icon]::ExtractAssociatedIcon((Get-Command powershell).Path)

################################################################## Main Form Setup
# Main Form
#$form.Height          = 400
#$form.Icon            = $iconPS
#$form.MainMenuStrip   = $menuMain
#$form.Width           = 800
#$form.StartPosition   = "CenterScreen"

$form.Controls.Add($menuMain)

################################################################## Main Menu
# Main ToolStrip
[void]$form.Controls.Add($mainToolStrip)

# Main Menu Bar
[void]$form.Controls.Add($menuMain)

# Menu Options - File
$menuFile.Text = "&File"
[void]$menuMain.Items.Add($menuFile)

# Menu Options - File / Open
$menuOpen.Image        = [System.IconExtractor]::Extract("shell32.dll", 4, $true)
$menuOpen.ShortcutKeys = "Control, O"
$menuOpen.Text         = "&Open"
$menuOpen.Add_Click({OpenFile})
[void]$menuFile.DropDownItems.Add($menuOpen)

# Menu Options - File / Save
$menuSave.Image        = [System.IconExtractor]::Extract("shell32.dll", 36, $true)
$menuSave.ShortcutKeys = "F2"
$menuSave.Text         = "&Save"
$menuSave.Add_Click({SaveFile})
[void]$menuFile.DropDownItems.Add($menuSave)

# Menu Options - File / Save As
$menuSaveAs.Image        = [System.IconExtractor]::Extract("shell32.dll", 45, $true)
$menuSaveAs.ShortcutKeys = "Control, S"
$menuSaveAs.Text         = "&Save As"
$menuSaveAs.Add_Click({SaveAs})
[void]$menuFile.DropDownItems.Add($menuSaveAs)

# Menu Options - File / Exit
$menuExit.Image        = [System.IconExtractor]::Extract("shell32.dll", 10, $true)
$menuExit.ShortcutKeys = "Control, X"
$menuExit.Text         = "&Exit"
$menuExit.Add_Click({$form.Close()})
[void]$menuFile.DropDownItems.Add($menuExit)

# Menu Options - View
$menuView.Text      = "&View"
[void]$menuMain.Items.Add($menuView)

# Menu Options - View / Full Screen
$menuFullScr.Image        = [System.IconExtractor]::Extract("shell32.dll",111, $true)
$menuFullScr.ShortcutKeys = "Control, F"
$menuFullScr.Text         = "&Full Screen"
$menuFullScr.Add_Click({FullScreen})
[void]$menuView.DropDownItems.Add($menuFullScr)


# Menu Options - Tools
$menuTools.Text      = "&Tools"
[void]$menuMain.Items.Add($menuTools)

# Menu Options - Tools / Терминальные ярлыки
$menuTerms.Image        = [System.IconExtractor]::Extract("shell32.dll",17, $true)
$menuTerms.ShortcutKeys = "Control, T"
$menuTerms.Text         = "&Терминальные ярлыки"
$menuTerms.Add_Click({Terms})
[void]$menuTools.DropDownItems.Add($menuTerms)

# Menu Options - Tools / DAEMWARE
$menuDAEM.Image        = [System.IconExtractor]::Extract("shell32.dll",46, $true)
$menuDAEM.ShortcutKeys = "Control, M"
$menuDAEM.Text         = "&DAEMWARE"
$menuDAEM.Add_Click({DAEM})
[void]$menuTools.DropDownItems.Add($menuDAEM)

# Menu Options - Tools / Knopki_2010
$menuKnopki_2010.Image        = [System.IconExtractor]::Extract("shell32.dll",68, $true)
$menuKnopki_2010.ShortcutKeys = "Control, K"
$menuKnopki_2010.Text         = "&Ярлычки 2010"
$menuKnopki_2010.Add_Click({Knopki_2010})
[void]$menuTools.DropDownItems.Add($menuKnopki_2010)


# Menu Options - Tools / Options
$menuOptions.Image     = [System.IconExtractor]::Extract("shell32.dll", 21, $true)
$menuOptions.Text      = "&Options"
[void]$menuTools.DropDownItems.Add($menuOptions)

# Menu Options - Tools / Options / Options 1
$menuOptions1.Image     = [System.IconExtractor]::Extract("shell32.dll", 33, $true)
$menuOptions1.Text      = "&Options 1"
$menuOptions1.Add_Click({Options1})
[void]$menuOptions.DropDownItems.Add($menuOptions1)

# Menu Options - Tools / Options / Options 2
$menuOptions2.Image     = [System.IconExtractor]::Extract("shell32.dll", 35, $true)
$menuOptions2.Text      = "&Options 2"
$menuOptions2.Add_Click({Options2})
[void]$menuOptions.DropDownItems.Add($menuOptions2)

# Menu Options - Help
$menuHelp.Text      = "&Help"
[void]$menuMain.Items.Add($menuHelp)

# Menu Options - Help / About
$menuAbout.Image     = [System.Drawing.SystemIcons]::Information
$menuAbout.Text      = "About MenuStrip"
$menuAbout.Add_Click({About})
[void]$menuHelp.DropDownItems.Add($menuAbout)

################################################################## ToolBar Buttons
# ToolStripButton - Open
$toolStripOpen.ToolTipText  = "Open"
$toolStripOpen.Image = $menuOpen.Image
$toolStripOpen.Add_Click({OpenFile})
[void]$mainToolStrip.Items.Add($toolStripOpen)

# ToolStripButton - Save
$toolStripSave.ToolTipText  = "Save"
$toolStripSave.Image = $menuSave.Image
$toolStripSave.Add_Click({Save})
[void]$mainToolStrip.Items.Add($toolStripSave)

# ToolStripButton - SaveAs
$toolStripSaveAs.ToolTipText  = "SaveAs"
$toolStripSaveAs.Image = $menuSaveAs.Image
$toolStripSaveAs.Add_Click({SaveAs})
[void]$mainToolStrip.Items.Add($toolStripSaveAs)

# ToolStripButton - Full Screen
$toolStripFullScr.ToolTipText  = "Разблокирование"
$toolStripFullScr.Image = $menuFullScr.Image
$toolStripFullScr.Add_Click({FullScreen})
[void]$mainToolStrip.Items.Add($toolStripFullScr)

# ToolStripButton - Терминальные ярлыки
$toolStripTerms.ToolTipText  = "Терминальные ярлыки"
$toolStripTerms.Image = $menuTerms.Image
$toolStripTerms.Add_Click({Terms})
[void]$mainToolStrip.Items.Add($toolStripTerms)

# ToolStripButton - Запуск DAEMWARE
$toolStripDAEM.ToolTipText  = "DAEMWARE"
$toolStripDAEM.Image = $menuDAEM.Image
$toolStripDAEM.Add_Click({DAEM})
[void]$mainToolStrip.Items.Add($toolStripDAEM)

# ToolStripButton - Копирование ярлыков 2010
$toolStripKnopki_2010.ToolTipText  = "Копирование ярлыков 2010"
$toolStripKnopki_2010.Image = $menuKnopki_2010.Image
$toolStripKnopki_2010.Add_Click({Knopki_2010})
[void]$mainToolStrip.Items.Add($toolStripKnopki_2010)


# ToolStripButton - About
$toolStripAbout.ToolTipText  = "About"
$toolStripAbout.Image = $menuAbout.Image
$toolStripAbout.Add_Click({About})
[void]$mainToolStrip.Items.Add($toolStripAbout)

# ToolStripButton - Exit
$toolStripExit.ToolTipText  = "Exit"
$toolStripExit.Image = $menuExit.Image
$toolStripExit.Add_Click({$form.Close()})
[void]$mainToolStrip.Items.Add($toolStripExit)

################################################################## Status Bar
# Status Bar & Label
[void]$statusStrip.Items.Add($statusLabel)
$statusLabel.AutoSize  = $true
$statusLabel.Text      = "Сделаем это!"
$form.Controls.Add($statusStrip)

# ==== ОПИСАНИЕ РАЗМЕРОВ И КООРДИНАТ =============================

$Object_title = [PSCustomObject]@{
size = 10
}


$Object_button1 = [PSCustomObject]@{
Width = 160
Height = 50
size = 14
}


   # Форма Ввода ip адреса 
$textbox2 = New-Object System.Windows.Forms.TextBox
$textbox2.Location  = New-Object System.Drawing.Point(10,65)
$textbox2.Font =  [System.Drawing.Font]::new("Microsoft Sans Serif", 12, [System.Drawing.FontStyle]::bold)  
$textbox2.Width = 250
$textbox2.Height =30
$textbox2.Text = '    IP или Имя компа '
$textbox2.AutoSize = $false 
   # вывод ip Адреса 
$form.Controls.Add($textbox2)


   #форма Вывода имени pgp диска 
$textbox3 = New-Object System.Windows.Forms.TextBox
$textbox3.Location  = New-Object System.Drawing.Point(10,110)
$textbox3.Width = 250
$textbox3.Height = 30
$textbox3.Font =  [System.Drawing.Font]::new("Microsoft Sans Serif", 12, [System.Drawing.FontStyle]::bold) 
$textbox3.Text ='  Логин пользователя  '
# описание кнопки 
$ToolTip.SetToolTip($textbox3, "Логин для pgp диска ")
# вывод имени диска на форму   New-Object System.Windows.Forms.TextBoxBase
$textbox3.AutoSize = $false
 $form.Controls.Add($textbox3)


   #форма Вывода имени pgp диска 
   $textbox4 = New-Object System.Windows.Forms.TextBox
$textbox4.Location  = New-Object System.Drawing.Point(10,155)
$textbox4.Width = 250
$textbox4.Height = 30
$textbox4.Font =  [System.Drawing.Font]::new("Microsoft Sans Serif", 12, [System.Drawing.FontStyle]::bold) 
$textbox4.Text ='  Здесь будет ФИО   '
   # вывод имени диска на форму   
$textbox4.AutoSize = $false
$form.Controls.Add($textbox4)



 # Кнопка отправки.кнопка 1 
$Button1 = New-Object System.Windows.Forms.Button
$Button1.Location = New-Object System.Drawing.Point(10,200)
$Button1.Font =  [System.Drawing.Font]::new("Times New Roman", 9, [System.Drawing.FontStyle]::bold) 
$Button1.Text               = " Настройка  почты     "
$Button1.Size = New-Object System.Drawing.Size(120,40)
   #вызываем функцию отправки сообщения
$Button1.add_click({
$rabota = $Button1.Text
$Ruplabel10.text = "Уточняем..."
$targetcomp = ($textbox2.Text|Out-String).Trim()
$statusLabel.Text = "Подключение к $targetcomp"
$mailflag = $true
pingik 
}) 
   #вывод на форму
$form.Controls.Add($Button1)



 # Кнопка отправки.кнопка 2 
$Button2 = New-Object System.Windows.Forms.Button
$Button2.Location = New-Object System.Drawing.Point(10,245)
$Button2.Font =  [System.Drawing.Font]::new("Times New Roman", 9, [System.Drawing.FontStyle]::bold) 
$Button2.Text               =  " Установка принтера "
$Button2.Size = New-Object System.Drawing.Size(120,40)
#  вызываем функцию отправки сообщения
$Button2.add_click({
$rabota = $Button2.Text
$Ruplabel10.text = "Уточняем..."
$targetcomp = ($textbox2.Text|Out-String).Trim()
$statusLabel.Text = "Подключение к $targetcomp"
$mailflag = $true
pingik
})
#вывод на форму 
$form.Controls.Add($Button2)


# Кнопка отправки.кнопка 3
$Button3 = New-Object System.Windows.Forms.Button
$Button3.Location = New-Object System.Drawing.Point(10,290)
$Button3.Font =  [System.Drawing.Font]::new("Times New Roman", 9, [System.Drawing.FontStyle]::bold) 
$Button3.Text               =  " Настройка профиля "
$Button3.Size = New-Object System.Drawing.Size(120,40)
#  вызываем функцию отправки сообщения
$Button3.add_click({
$rabota = $Button3.Text
$Ruplabel10.text = "Уточняем..."
$targetcomp = ($textbox2.Text|Out-String).Trim()
$statusLabel.Text = "Подключение к $targetcomp"
$mailflag = $true
pingik
})
   #вывод на форму 
$form.Controls.Add($Button3)

 #Кнопка отправки.кнопка 4
$Button4 = New-Object System.Windows.Forms.Button
$Button4.Location = New-Object System.Drawing.Point(10,335)
$Button4.Font =  [System.Drawing.Font]::new("Times New Romanf", 9, [System.Drawing.FontStyle]::bold) 
$Button4.Text               =  " Консультация "
$Button4.Size = New-Object System.Drawing.Size(120,40)
#  вызываем функцию отправки сообщения
$Button4.add_click({
$rabota = $textBox.Text
$Ruplabel10.text = "Уточняем..."
$targetcomp = ($textbox2.Text|Out-String).Trim()
$statusLabel.Text = "Подключение к $targetcomp"
$mailflag = $false
pingik
})
#вывод на форму 
$form.Controls.Add($Button4)

$CheckBoxDW = New-Object System.Windows.Forms.CheckBox
$CheckBoxDW.Text = 'Запускать DameWare'
$CheckBoxDW.AutoSize = $true
$CheckBoxDW.Checked = $true
$CheckBoxDW.Location  = New-Object System.Drawing.Point(10,380)
$CheckBoxDW.Font =  [System.Drawing.Font]::new("Times New Roman", 8, [System.Drawing.FontStyle]::Underline)
$form.Controls.Add($CheckBoxDW)

# ======== Данные для создания PGP диска

$CheckBoxTC = New-Object System.Windows.Forms.CheckBox
$CheckBoxTC.Text = '.tc'
$CheckBoxTC.AutoSize = $true
$CheckBoxTC.Checked = $false
$CheckBoxTC.Location  = New-Object System.Drawing.Point(265,109)
$form.Controls.Add($CheckBoxTC)

$CheckBoxHC = New-Object System.Windows.Forms.CheckBox
$CheckBoxHC.Text = '.hc'
$CheckBoxHC.AutoSize = $true
$CheckBoxHC.Checked = $false
$CheckBoxHC.Location  = New-Object System.Drawing.Point(265,125)
$form.Controls.Add($CheckBoxHC)

$buttonPGP = New-Object System.Windows.Forms.Button
$buttonPGP.Location = New-Object System.Drawing.Point(302,125)
$buttonPGP.Font =  [System.Drawing.Font]::new("Times New Roman", 9, [System.Drawing.FontStyle]::Underline) 
$buttonPGP.Size = New-Object System.Drawing.Size(60,40)
#$button5.Multiline = $true
#$button5.Bottom = 1
#$textBox.MultilineChanged  = 3
$buttonPGP.text = "COPY в буфер"
$buttonPGP.AutoSize = $false 
$form.Controls.Add($buttonPGP)
$buttonPGP.add_click({
IF ($CheckBoxTC.Checked -eq $true)
{$PGPlogin = $textbox3.Text + '.tc'}
IF ($CheckBoxHC.Checked -eq $true)
{$PGPlogin = $textbox3.Text + '.hc'}
$PGPlogin | Set-Clipboard
$PathToCopy = ($PGPlogin|Out-String).Trim()
$statusLabel.Text = "Имя $PathToCopy скопировано в буфер обмена"
sleep 20
$statusLabel.Text ="Готов"
$CheckBoxTC.Checked = $false
$CheckBoxHC.Checked = $false
#Set-Clipboard -Value $PGPlogin
})



# Кнопка отправки.кнопка 5

$button5 = New-Object System.Windows.Forms.Button
$button5.Location = New-Object System.Drawing.Point(150,200)
$button5.Font =  [System.Drawing.Font]::new("Times New Roman", 9, [System.Drawing.FontStyle]::Underline) 
$button5.Size = New-Object System.Drawing.Size(100,20)
#$button5.Multiline = $true
#$button5.Bottom = 1
#$textBox.MultilineChanged  = 3
$button5.text = "конверт диска H:"
$button5.AutoSize = $false 
$form.Controls.Add($button5)
$button5.add_click({convertik})


# Кнопка отправки.кнопка 6

$button6 = New-Object System.Windows.Forms.Button
$button6.Location = New-Object System.Drawing.Point(150,225)
$button6.Font =  [System.Drawing.Font]::new("Times New Roman", 9, [System.Drawing.FontStyle]::Underline) 
$button6.Size = New-Object System.Drawing.Size(100,20)
#$button5.Multiline = $true
#$button5.Bottom = 1
#$textBox.MultilineChanged  = 3
$button6.text = " ярлык МТCК "
$button6.AutoSize = $false 
$form.Controls.Add($button6)
$button6.add_click(
{
$namehost = $textbox2.Text
copy-item "\\yarprim\Yaroslavka\Sources\!INSTALL\1C_MTCK_CO.rdp" "\\$namehost\c$\Users\Public\Desktop\1C_MTCK_CO.rdp"
}
) 

# Кнопка отправки.кнопка 7

$button7 = New-Object System.Windows.Forms.Button
$button7.Location = New-Object System.Drawing.Point(150,250)
$button7.Font =  [System.Drawing.Font]::new("Times New Roman", 9, [System.Drawing.FontStyle]::Underline) 
$button7.Size = New-Object System.Drawing.Size(100,20)
$button7.text = " установка AMS "
$button7.AutoSize = $false 
$form.Controls.Add($button7)
$button7.add_click(
{
$namehost = $textbox2.Text
copy-item "\\yarprim\Yaroslavka\Sources\!INSTALL\1C_MTCK_CO.rdp" "\\$namehost\c$\Users\Public\Desktop\1C_MTCK_CO.rdp"
}
) 

# Кнопка отправки.кнопка 8

$button8 = New-Object System.Windows.Forms.Button
$button8.Location = New-Object System.Drawing.Point(150,275)
$button8.Font =  [System.Drawing.Font]::new("Times New Roman", 9, [System.Drawing.FontStyle]::Underline) 
$button8.Size = New-Object System.Drawing.Size(100,20)
$button8.text = " Ярлык PGP "
$button8.AutoSize = $false 
$form.Controls.Add($button8)
$button8.add_click(
{
$PGPname = $textbox3.Text
$namehost = $textbox2.Text
$disk_path = '\\$namehost\d$\pgp\$PGPname.tc'

if (Test-Path "\\$namehost\d$\pgp\$PGPname.hc")
{
$Install_Path = "\\$namehost\c$\Users\$PGPname\Desktop\"
$WSShell = New-Object -com WScript.Shell
$ShortcutPath = Join-Path -Path $Install_Path -ChildPath "$PGPname.lnk"
$NewShortcut = $WSShell.CreateShortcut($ShortcutPath)
$NewShortcut.TargetPath = "\\$namehost\d$\pgp\$PGPname.hc"
$NewShortcut.Save()
$statusLabel.Text = "Ярлык $PGPname.lnk создан"
sleep 15
$statusLabel.Text ="Готов"
}
elseif (Test-Path "\\$namehost\d$\pgp\$PGPname.tc")
{
$Install_Path = "\\$namehost\c$\Users\$PGPname\Desktop\"
$WSShell = New-Object -com WScript.Shell
$ShortcutPath = Join-Path -Path $Install_Path -ChildPath "$PGPname.lnk"
$NewShortcut = $WSShell.CreateShortcut($ShortcutPath)
$NewShortcut.TargetPath = "\\$namehost\d$\pgp\$PGPname.tc"
$NewShortcut.Save()
$statusLabel.Text = "Ярлык $PGPname.lnk создан"
sleep 15
$statusLabel.Text ="Готов"
}
else
{
$statusLabel.Text = "ВНИМАНИЕ!!! Ярлык $PGPname.lnk НЕ создан"
sleep 15
$statusLabel.Text ="Готов"
}



#New-Item -ItemType SymbolicLink -Target '\\$namehost\d$\pgp\$PGPname.hc' -Path '\\$namehost\c$\Users\$PGPname\Desktop\$PGPname.lnk'
# copy-item "\\yarprim\Yaroslavka\Sources\!INSTALL\1C_MTCK_CO.rdp" "\\$namehost\c$\Users\$PGPname\Desktop\1C_MTCK_CO.rdp"
}
) 




<#

$button6                    = New-Object System.Windows.Forms.Button
$button6.Location           = New-Object System.Drawing.Point(150,220)
$button6.Size = New-Object System.Drawing.Size(100,20)
$button6.Font =  [System.Drawing.Font]::new("Times New Roman", 9, [System.Drawing.FontStyle]::Underline)
$button6.Text  = "ярлык мтск"
$button6.add_click(
{
copy-item "\\yarprim\Yaroslavka\Sources\!INSTALL\1C_MTCK_CO.rdp" "\\$comp\c$\Users\Public\Desktop\1C_MTCK_CO.rdp"
} 
 )
#$button6.add_click({mctk})

$button6.AutoSize = $false
#$button6.Autosize           = 1
#$button6.TabIndex           = 5
#$ToolTip.SetToolTip($button6, "Тыцни пимпочку")
#$MainSendWindow.Controls.Add($button6)
$form.Controls.Add($button6)
#>


# ======= ВЫВОД ВРЕМЕНИ РАБОТЫ КОМПА ====================

$Ruplabel9 = New-Object System.Windows.Forms.label
$Ruplabel9.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",$Object_title.size,[System.Drawing.FontStyle]::Regular)
$Ruplabel9.Text = "Время работы ПК:"
$Ruplabel9.Location = New-Object System.Drawing.Point(170,310)
$Ruplabel9.AutoSize = $true
$Ruplabel9.Visible = $true
$form.Controls.Add($Ruplabel9)

$Ruplabel10 = New-Object System.Windows.Forms.label
$Ruplabel10.Font = New-Object System.Drawing.Font("Microsoft Sans Serif",$Object_title.size,[System.Drawing.FontStyle]::Regular)
$Ruplabel10.Text = ""
$Ruplabel10.Location = New-Object System.Drawing.Point(170,330)
$Ruplabel10.AutoSize = $true
$Ruplabel10.Visible = $false
$form.Controls.Add($Ruplabel10)



# Окошко ввода данных
<#
$label1 = New-Object System.Windows.Forms.Label
$label1.Text = " <---- сюда вводить IP "
$label1.Location = New-Object System.Drawing.Point(290,50)
$label1.Width = 135
$label1.Height = 20
#$form.Controls.Add($label1)
$form.Controls.Add($label1)
#>


<#
# This base64 string holds the bytes that make up the orange 'G' icon (just an example for a 32x32 pixel image)
$iconBase64      = 'iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAIAAAD8GO2jAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAZdEVYdFNvZnR3YXJlAHBhaW50Lm5ldCA0LjAuMTnU1rJkAAAB50lEQVRIS7WWzytEURTHZ2FhaWFhYWFhYWFhaWFh6c+wsGCapJBJU0hRSrOgLBVSmkQoSpqyUJISapIFJU0i1KQp1PG9826vO9+Z97Pr22dz3pxzv/PO/fUSkvxfOLYOx9bh2DocBzPZKlPtku2VuS7JtMlwIydUw7EnGO50Rd4ehPRdlru87GWUMZVU4LgOqLza0cP56PdHNga4NthgsUc+i3qIQOH9qDzAYLZTyiVd7Ah/8/lGztclNyLbY5JfksKxeuiKRvAzwOy93OsyR+9Pam6HajLHm5UfXhTQT34GqDH1eCGjTZxjkmqQmQ5+6Gdgth5NQLsoIRwca7AoTZ1k1UM0p7Y/QXCsof4sdOvRrRlgeZgyu49eY/0cTDO76ShzcJnTQ0O0NvA2XioWqjIrcKy5PdQ1kLl90CKsVC9F2GiYVVPuiQaDiRb1TzGWw9eHzoEiGGwO6hpHWFRe04vuu4pggCPIFPwowSWmAXa/qdKr5zaOaQBwyps6W+UEh/gGtasFlrjCKC2+ATia15WucHpf76vna/2ylVLntnmeRzbApsUQ4RXZwAFnAC7eMMLNSrWhDEC6RfUac1D3+sRew87HhVzvC4PjYLBecRxhDsByn/qEoYRqOLYOx9bh2DocWyaZ+APgBBKhVfsHwAAAAABJRU5ErkJggg=='
$iconBytes       = [Convert]::FromBase64String($iconBase64)
# initialize a Memory stream holding the bytes
$stream          = [System.IO.MemoryStream]::new($iconBytes, 0, $iconBytes.Length)
$Form.Icon       = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap]::new($stream).GetHIcon()))
#>


# ==== Вывод фотографии

[reflection.assembly]::LoadWithPartialName("System.Windows.Forms")
$file = (get-item 'T:\1\photo1.JPG')
$img = [System.Drawing.Image]::Fromfile($file);

[System.Windows.Forms.Application]::EnableVisualStyles();


# Это описание поля ввода фотографии
# Сама фотография выводится в блоке запроса вывода времени работы компа

$photouser = Get-ADUser -Identity $textbox3.Text -PR * |Select-Object thumbnailPhoto
$pictureBox = new-object Windows.Forms.PictureBox
$pictureBox.Location = New-Object System.Drawing.Size(302,50)
$pictureBox.Size = New-Object System.Drawing.Size(70,70)
# $pictureBox.Size = New-Object System.Drawing.Size($img.Width,$img.Height)
$pictureBox.Image = $img
# $pictureBox.Image = $photouser.thumbnailPhoto

$form.Controls.Add($pictureBox)
# IP  для тестрования 10.77.54.251



	
$form.Icon = New-Object System.Drawing.Icon("\\ftp\install\Distr\HDicon.ico")


$form.Topmost = $true
$result = $form.ShowDialog()



#$login | Set-Clipboard
#Set-Clipboard -Value $login
#=======================================================================================================
#    КОНЕЦ МОДУЛЯ ГРАФИКИ
#=======================================================================================================

