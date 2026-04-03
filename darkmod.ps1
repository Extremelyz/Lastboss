# ===== ADMIN AUTO =====
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell -Verb runAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ===== FUNCTIONS =====

function Apply-PowerCPU {
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
    $guid = (powercfg -list | Select-String "Ultimate").ToString().Split()[3]
    powercfg -setactive $guid

    powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100
    powercfg -setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100

    bcdedit /set disabledynamictick yes
    bcdedit /set useplatformclock true
}

function Apply-RAM {
    $mem = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
    Set-ItemProperty $mem DisablePagingExecutive 1
    Set-ItemProperty $mem LargeSystemCache 0

    Stop-Service SysMain -Force
    Set-Service SysMain -StartupType Disabled
}

function Apply-GPU {
    $gpu = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
    Set-ItemProperty $gpu HwSchMode 2
    Set-ItemProperty $gpu TdrDelay 10

    $gd = "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR"
    Set-ItemProperty $gd AppCaptureEnabled 0
}

function Apply-Network {
    Get-NetAdapter | Where {$_.Status -eq "Up"} | ForEach {
        Set-DnsClientServerAddress -InterfaceIndex $_.InterfaceIndex -ServerAddresses ("1.1.1.1","1.0.0.1")
    }

    netsh int tcp set global autotuninglevel=disabled
    netsh int tcp set global ecncapability=disabled
    netsh int tcp set global rss=disabled
    netsh int tcp set global chimney=disabled
}

function Apply-MouseKeyboard {
    $mouse = "HKCU:\Control Panel\Mouse"
    Set-ItemProperty $mouse MouseSpeed 0
    Set-ItemProperty $mouse MouseThreshold1 0
    Set-ItemProperty $mouse MouseThreshold2 0
}

function Apply-Services {
    $services = @("SysMain","DiagTrack","WSearch","XboxGipSvc","XblGameSave")
    foreach ($s in $services) {
        Stop-Service $s -Force -ErrorAction SilentlyContinue
        Set-Service $s -StartupType Disabled
    }
}

function Apply-Visual {
    $vis = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    Set-ItemProperty $vis VisualFXSetting 2
}

function Apply-Storage {
    fsutil behavior set disablelastaccess 1
    fsutil behavior set disable8dot3 1
}

function Apply-CleanTemp {
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    ipconfig /flushdns
}

function FULL-TWEAK {
    Apply-PowerCPU
    Apply-RAM
    Apply-GPU
    Apply-Network
    Apply-MouseKeyboard
    Apply-Services
    Apply-Visual
    Apply-Storage
    Apply-CleanTemp

    [System.Windows.Forms.MessageBox]::Show("FULL GAMING TWEAK DONE 🔥","Lastboss")
}

# ===== UI =====
$form = New-Object Windows.Forms.Form
$form.Text = "层片始却专状育厂京识适属圆包火住调满县局照参红细引听该铁价"
$form.Size = New-Object Drawing.Size(420,330)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#0d0d0d"

$title = New-Object Windows.Forms.Label
$title.Text = "       最后的老板"
$title.ForeColor = "Azure"
$title.Font = New-Object Drawing.Font("Consolas",16,[Drawing.FontStyle]::Bold)
$title.AutoSize = $true
$title.Location = New-Object Drawing.Point(60,20)
$form.Controls.Add($title)

function NewBtn($text,$y,$action){
    $b = New-Object Windows.Forms.Button
    $b.Text = $text
    $b.Size = New-Object Drawing.Size(260,40)
    $b.Location = New-Object Drawing.Point(70,$y)
    $b.BackColor = "#1a1a1a"
    $b.ForeColor = "White"
    $b.FlatStyle = "Flat"
    $b.Add_Click($action)
    $form.Controls.Add($b)
}

NewBtn " I FULL TWEAK" 90 { FULL-TWEAK }
NewBtn " II NETWORK BOOST" 140 { Apply-Network }
NewBtn " III CLEAN" 190 { Apply-CleanTemp }

$form.TopMost = $true
$form.ShowDialog()
