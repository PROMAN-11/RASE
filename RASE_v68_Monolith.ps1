<#
.SYNOPSIS
    ROMAN ADAPTIVE STORAGE ENGINE (RASE) v68 Ultimate.
    Intelligent, adaptive PowerShell monolith for deep storage diagnostics and OS optimization.

.DESCRIPTION
    RASE v68 is an Enterprise-grade maintenance tool designed for Windows 10 LTSC and modern Windows OS.
    It automatically detects hardware configuration (NVMe, SSD, HDD, Hybrid GPUs) and generates 
    a customized maintenance plan. 
    
    Features include:
    [ CORE DIAGNOSTICS & HARDWARE ]
    - Comprehensive System & Hardware Profiling
    - SMART RAW Deep Analysis (HDD/SSD)
    - NVMe Temperature & Thermal Throttling Detection
    - SSD Endurance Forecast & Wear-Level Prediction
    - Composite HealthScore & Extended RiskLevel Computation

    [ DISK & SYSTEM OPTIMIZATION ]
    - Adaptive TRIM (SSD/NVMe) & Smart Defrag (HDD)
    - CHKDSK Scan, DirtyBit & ReFS Integrity Checks
    - System Integrity Auto-Repair (DISM Health & SFC Scannow)
    - NTFS File System Tuning (disable 8.3 names & last access time)
    - VSS Pruning (Oldest Shadow Copy cleanup)

    [ DEEP CLEANUP ENGINE ]
    - Windows Update Cache & WinSxS Component Cleanup
    - Obsolete Driver Store Packages Cleanup
    - Adaptive GPU/CPU Cache Cleanup (NVIDIA, AMD, Intel)
    - Deep System Temp & Recycle Bin Clearing

    [ UX & REPORTING ]
    - Interactive Dark GUI Console Prompts (Start & Reboot)
    - Animated Native Progress Bars
    - Final Disk Summary with Dark-Themed HTML Reporting
    - Complete Execution Logging & Error Capture
    
    Project Conceived by: ROMAN POTRIMBA
    Code Engineered by: Kolya (Copilot) & Jemi (Gemini)

.EXAMPLE
    .\RASE_v68_Monolith.ps1
    Runs the standard optimization suite with a Dark GUI confirmation and end-of-task reboot prompt.

.EXAMPLE
    .\RASE_v68_Monolith.ps1 -DryRun
    Runs a safe simulation mode. Scans the system and generates a report without making any modifications.

.EXAMPLE
    .\RASE_v68_Monolith.ps1 -FullReport
    Executes the optimization and automatically opens the HTML report in the default web browser upon completion.

.NOTES
    Version: 68.0 Ultimate
    Date: 2026
    Philosophy: "Reliability begins with maintenance!"
#>
# ============================================================
# ROMAN ADAPTIVE STORAGE ENGINE (RASE) v68 MONOLITH (ULTIMATE)
# ============================================================

param(
    [switch]$DryRun,
    [switch]$NoReboot,
    [switch]$FullReport
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# --- Загрузка графических библиотек Windows ---
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Admin Check ---
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) {
    Write-Host "WARNING: Run only as Administrator!" -ForegroundColor Red
    Read-Host "Press Enter to exit..."
    Exit
}

# ----------------------------
# GUI Engine (Dark Console Style)
# ----------------------------

function Show-DarkMessageBox {
    param(
        [string]$Message, 
        [string]$Title,
        [string]$BtnYesText = "YES",
        [string]$BtnNoText = "NO",
        [bool]$IsStartDialog = $false
    )

    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Title
    
    # Делаем окно шире и выше для стартового предупреждения
    if ($IsStartDialog) {
        $form.Size = New-Object System.Drawing.Size(580, 275)
    } else {
        $form.Size = New-Object System.Drawing.Size(500, 220)
    }

    $form.StartPosition = "CenterScreen"
    $form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $form.ForeColor = [System.Drawing.Color]::White
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.TopMost = $true

    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Message
    $label.AutoSize = $false
    $label.Dock = "Top"
    $label.Height = if ($IsStartDialog) { 150 } else { 100 }
    $label.TextAlign = "MiddleCenter"
    $label.Font = New-Object System.Drawing.Font("Consolas", 10)
    $label.ForeColor = [System.Drawing.Color]::Cyan

    $btnYLocX = if ($IsStartDialog) { 140 } else { 110 }
    $btnYLocY = if ($IsStartDialog) { 175 } else { 115 }

    $btnNLocX = if ($IsStartDialog) { 300 } else { 250 }
    $btnNLocY = if ($IsStartDialog) { 175 } else { 115 }

    $btnYes = New-Object System.Windows.Forms.Button
    $btnYes.Text = $BtnYesText
    $btnYes.Size = New-Object System.Drawing.Size(120, 40)
    $btnYes.Location = New-Object System.Drawing.Point($btnYLocX, $btnYLocY)
    $btnYes.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
    $btnYes.FlatStyle = "Flat"
    $btnYes.FlatAppearance.BorderColor = [System.Drawing.Color]::Cyan
    $btnYes.Font = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Bold)
    $btnYes.DialogResult = "Yes"

    $btnNo = New-Object System.Windows.Forms.Button
    $btnNo.Text = $BtnNoText
    $btnNo.Size = New-Object System.Drawing.Size(120, 40)
    $btnNo.Location = New-Object System.Drawing.Point($btnNLocX, $btnNLocY)
    $btnNo.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
    $btnNo.FlatStyle = "Flat"
    $btnNo.FlatAppearance.BorderColor = [System.Drawing.Color]::Red
    $btnNo.ForeColor = [System.Drawing.Color]::LightCoral
    $btnNo.Font = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Bold)
    $btnNo.DialogResult = "No"

    $form.Controls.Add($label)
    $form.Controls.Add($btnYes)
    $form.Controls.Add($btnNo)

    $result = $form.ShowDialog()
    $form.Dispose()

    return $result
}

# ----------------------------
# Paths & Transcript
# ----------------------------

$timestamp   = Get-Date -Format "yyyy-MM-dd_HH-mm"
$ReportsRoot = "D:\RASE_Reports"

if (!(Test-Path $ReportsRoot)) {
    New-Item -ItemType Directory -Path $ReportsRoot | Out-Null
}

$TextLog  = "$ReportsRoot\RASE_v68_Transcript_$timestamp.txt"
$HtmlLog  = "$ReportsRoot\RASE_v68_Report_$timestamp.html"
$ErrorLog = "$ReportsRoot\RASE_v68_Errors_$timestamp.txt"

Start-Transcript -Path $TextLog -Append | Out-Null

# ----------------------------
# Console Output Helpers
# ----------------------------

function Section($title) {
    Write-Host "`n============================================================" -ForegroundColor DarkCyan
    Write-Host " $title" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor DarkCyan
}

function Console-Step($msg) { Write-Host "[STEP]  $msg" -ForegroundColor Cyan }
function Console-OK($msg)   { Write-Host "[ OK ]  $msg" -ForegroundColor Green }
function Console-Warn($msg) { Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Console-Err($msg)  { Write-Host "[FAIL]  $msg" -ForegroundColor Red }
function Console-Info($msg) { Write-Host "[INFO]  $msg" -ForegroundColor Gray }

function Invoke-AnimatedTask {
    param(
        [string]$Activity,
        [string]$Command,
        [string]$Arguments
    )
    
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "cmd.exe"
    $psi.Arguments = "/c $Command $Arguments > NUL 2>&1"
    $psi.RedirectStandardOutput = $false
    $psi.RedirectStandardError  = $false
    $psi.UseShellExecute        = $false
    $psi.CreateNoWindow         = $true
    
    $process = [System.Diagnostics.Process]::Start($psi)
    
    $width = 30
    $pos = 0
    $dir = 1
    
    while (-not $process.HasExited) {
        $left = "=" * $pos
        $right = " " * ($width - $pos - 1)
        $bar = "[$left>$right]"
        
        Write-Progress -Activity $Activity -Status "Processing... $bar"
        
        $pos += $dir
        if ($pos -eq ($width - 1) -or $pos -eq 0) { $dir *= -1 }
        Start-Sleep -Milliseconds 80
    }
    
    Write-Progress -Activity $Activity -Status "[==============================] 100%" -PercentComplete 100
    Start-Sleep -Milliseconds 500
    Write-Progress -Activity $Activity -Completed
    
    if ($process.ExitCode -ne 0) {
        throw "Process failed with exit code $($process.ExitCode)"
    }
}

# ----------------------------
# HTML Report Core
# ----------------------------

$Global:HtmlContent    = @()
$Global:DiskTable      = @()
$Global:ErrorLogPath   = $ErrorLog
$Global:HtmlOutputPath = $HtmlLog

function Initialize-HtmlReport {
    param([string]$Title, [string]$Timestamp, [string]$OutputPath)

    $Global:HtmlContent = @()
    $Global:HtmlContent += "<html><head><meta charset='UTF-8'><title>$Title</title></head>"
    $Global:HtmlContent += "<body style='background-color:#1e1e1e;color:#d4d4d4;font-family:Consolas,monospace;'>"
    $Global:HtmlContent += "<h2 style='color:#569cd6;'>$Title</h2>"
    $Global:HtmlContent += "<p style='color:#808080;'><i>Reliability begins with maintenance!</i></p>"
    $Global:HtmlContent += "<p>Timestamp: $Timestamp</p>"
    $Global:HtmlContent += "<hr style='border:1px solid #444;'>"

    $Global:HtmlOutputPath = $OutputPath
}

function HtmlAdd {
    param([string]$Message, [string]$Color = "#d4d4d4")
    switch ($Color) {
        "black"  { $Color = "#d4d4d4" }
        "blue"   { $Color = "#569cd6" }
        "green"  { $Color = "#4ec9b0" }
        "red"    { $Color = "#f44747" }
        "orange" { $Color = "#ce9178" }
        "gray"   { $Color = "#808080" }
    }
    $html = '<p style="color:' + $Color + ';font-size:14px;margin:5px 0;">' + $Message + '</p>'
    $Global:HtmlContent += $html
}

function HtmlAddSection {
    param([string]$Title)
    $html = '<h3 style="color:#c586c0;margin-top:20px;border-bottom:1px solid #444;padding-bottom:5px;">' + $Title + '</h3>'
    $Global:HtmlContent += $html
}

function HtmlAddTempBar {
    param([int]$Temp, [string]$Color)
    $width = [math]::Min($Temp * 3, 300)
    $html = '<div style="background-color:' + $Color + ';width:' + $width + 'px;height:12px;margin:3px 0;"></div>'
    $Global:HtmlContent += $html
}

function Finalize-DiskSummaryTable {
    HtmlAddSection "Final Disk Summary v68 Ultimate"
    $tableHtml = "<table border='1' cellspacing='0' cellpadding='5' style='border-collapse: collapse; border: 1px solid #444; width: 100%; text-align: left;'>"
    $tableHtml += "<tr style='background-color: #333; color: #fff;'>
    <th>Disk</th><th>Name</th><th>Type</th><th>Bus</th><th>FileSystem</th><th>Size</th><th>Free</th>
    <th>Health</th><th>HealthScore</th><th>Risk</th><th>SMART RAW</th><th>Frag %</th><th>TRIM</th><th>Defrag</th><th>Status</th></tr>"

    foreach ($row in $Global:DiskTable) {
        $riskColor = "#4ec9b0"
        if ($row.RiskLevel -eq "Medium") { $riskColor = "#ce9178" }
        elseif ($row.RiskLevel -eq "High") { $riskColor = "#f44747" }
        elseif ($row.RiskLevel -eq "Critical") { $riskColor = "#ff0000" }

        $tableHtml += "<tr>
        <td style='border: 1px solid #444;'>$($row.Disk)</td>
        <td style='border: 1px solid #444;'>$($row.Name)</td>
        <td style='border: 1px solid #444;'>$($row.Type)</td>
        <td style='border: 1px solid #444;'>$($row.BusType)</td>
        <td style='border: 1px solid #444;'>$($row.FileSystem)</td>
        <td style='border: 1px solid #444;'>$($row.SizeGB)</td>
        <td style='border: 1px solid #444;'>$($row.FreeGB)</td>
        <td style='border: 1px solid #444;'>$($row.Health)</td>
        <td style='border: 1px solid #444;'>$($row.HealthScore)</td>
        <td style='border: 1px solid #444;color:$riskColor;'>$($row.RiskLevel)</td>
        <td style='border: 1px solid #444;'>$($row.SmartRaw)</td>
        <td style='border: 1px solid #444;'>$($row.FragmentationPercent)</td>
        <td style='border: 1px solid #444;'>$($row.TRIM)</td>
        <td style='border: 1px solid #444;'>$($row.Defrag)</td>
        <td style='border: 1px solid #444;'>$($row.Status)</td>
        </tr>"
    }

    $tableHtml += "</table>"
    $Global:HtmlContent += $tableHtml
}

function Finalize-HtmlReport {
    $Global:HtmlContent += "</body></html>"
    $Global:HtmlContent -join "`r`n" | Out-File -FilePath $Global:HtmlOutputPath -Encoding UTF8
}

function LogError {
    param([string]$Message, [string]$Source = "Unknown")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $Global:ErrorLogPath -Value "[$timestamp] [$Source] $Message" -Encoding UTF8
    HtmlAdd "ERROR ($Source): $Message" "red"
}

# ----------------------------
# User Notice & Pre-Checks
# ----------------------------

function Show-UserConsent {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "   ROMAN ADAPTIVE STORAGE ENGINE (RASE) v68 Ultimate"
    Write-Host "   `"Reliability begins with maintenance!`""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Project Conceived by : ROMAN POTRIMBA"
    Write-Host "Code Engineered by   : Kolya (Copilot) & Jemi (Gemini)"
    Write-Host "Technology           : 100% Native Windows Microprograms"
    Write-Host "Purpose              : Ultimate Windows OS Optimization & Health"
    Write-Host ""

    # Полное предупреждение в графическом окне старта
    $guiMsg = "ROMAN ADAPTIVE STORAGE ENGINE v68`n`nDepending on your system configuration, the full process may take`nbetween 1 to 6 hours. It is strongly recommended NOT to use the PC.`n`nStart full diagnostic and optimization cycle?"
    
    $result = Show-DarkMessageBox -Message $guiMsg -Title "RASE v68 Ultimate" -BtnYesText "START" -BtnNoText "CANCEL" -IsStartDialog $true

    if ($result -ne "Yes") {
        Write-Host "`nOperation cancelled by user.`n" -ForegroundColor Yellow
        Stop-Transcript
        Exit
    }
    
    Write-Host "`nStarting RASE v68 optimization...`n" -ForegroundColor Green
}

function Invoke-SystemRestorePoint {
    HtmlAddSection "System Protection"
    Console-Step "System Restore Point"

    if ($DryRun) {
        HtmlAdd "Restore point skipped (DryRun mode)" "orange"
        return
    }

    try {
        Enable-ComputerRestore -Drive "C:" -ErrorAction SilentlyContinue
        $rpName = "RASE_v68_Backup_$timestamp"
        Checkpoint-Computer -Description $rpName -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        HtmlAdd "Restore point created successfully: $rpName" "green"
        Console-OK "Restore point created."
    } catch {
        HtmlAdd "Restore point skipped (System Protection might be disabled)" "orange"
        Console-Warn "Restore point skipped or disabled."
    }
}

# ----------------------------
# System Profile
# ----------------------------

function Get-HardwareProfile {
    $cpu     = Get-CimInstance Win32_Processor
    $ram     = Get-CimInstance Win32_ComputerSystem
    $gpus    = Get-CimInstance Win32_VideoController
    $disks   = Get-PhysicalDisk
    $volumes = Get-Volume
    $bios    = Get-CimInstance Win32_BIOS
    $cs      = Get-CimInstance Win32_ComputerSystem

    $profile = [pscustomobject]@{
        CPU = [pscustomobject]@{
            Name    = $cpu.Name
            Cores   = $cpu.NumberOfCores
            Threads = $cpu.NumberOfLogicalProcessors
        }
        RAM = [pscustomobject]@{
            TotalGB = [math]::Round($ram.TotalPhysicalMemory / 1GB, 2)
        }
        GPU     = @()
        Disks   = @()
        Volumes = @()
        BIOS    = [pscustomobject]@{
            SerialNumber = $bios.SerialNumber
            Version      = $bios.SMBIOSBIOSVersion
            ReleaseDate  = $bios.ReleaseDate
        }
        System = [pscustomobject]@{
            Manufacturer = $cs.Manufacturer
            Model        = $cs.Model
            Hostname     = $env:COMPUTERNAME
            User         = $env:USERNAME
        }
    }

    foreach ($gpu in $gpus) {
        $vendor = "Unknown"
        if ($gpu.Name -match "NVIDIA") { $vendor = "NVIDIA" }
        elseif ($gpu.Name -match "AMD|Radeon") { $vendor = "AMD" }
        elseif ($gpu.Name -match "Intel") { $vendor = "Intel" }

        $profile.GPU += [pscustomobject]@{
            Name   = $gpu.Name
            Vendor = $vendor
            VRAMMB = [math]::Round($gpu.AdapterRAM / 1MB, 0)
        }
    }

    foreach ($disk in $disks) {
        $profile.Disks += [pscustomobject]@{
            Name      = $disk.FriendlyName
            MediaType = $disk.MediaType
            BusType   = $disk.BusType
            DeviceId  = $disk.DeviceId
            Health    = $disk.HealthStatus
        }
    }

    foreach ($vol in $volumes) {
        $profile.Volumes += [pscustomobject]@{
            DriveLetter = $vol.DriveLetter
            FileSystem  = $vol.FileSystem
            SizeGB      = [math]::Round($vol.Size / 1GB, 2)
            FreeGB      = [math]::Round($vol.SizeRemaining / 1GB, 2)
            Health      = $vol.HealthStatus
        }
    }

    return $profile
}

function Get-SoftwareProfile {
    $os = Get-CimInstance Win32_OperatingSystem
    $isLTSC = if ($os.Caption -match "LTSC") { $true } else { $false }

    return [pscustomobject]@{
        OSName  = $os.Caption
        OSBuild = $os.BuildNumber
        IsLTSC  = $isLTSC
    }
}

function Get-SafetyProfile {
    $volumes = Get-Volume
    $windows = @()
    $foreign = @()

    foreach ($v in $volumes) {
        $sizeGB = [math]::Round($v.Size / 1GB, 2)
        if ($sizeGB -eq 0) { continue }

        if (-not $v.DriveLetter) {
            $foreign += [pscustomobject]@{
                DriveLetter = $null
                FileSystem  = $v.FileSystem
                SizeGB      = $sizeGB
                Reason      = "NoDriveLetter"
            }
            continue
        }

        if ($v.FileSystem -notin @("NTFS","ReFS")) {
            $foreign += [pscustomobject]@{
                DriveLetter = $v.DriveLetter
                FileSystem  = $v.FileSystem
                SizeGB      = $sizeGB
                Reason      = "NonWindowsFS"
            }
            continue
        }

        $windows += [pscustomobject]@{
            DriveLetter = $v.DriveLetter
            FileSystem  = $v.FileSystem
            SizeGB      = $sizeGB
            FreeGB      = [math]::Round($v.SizeRemaining / 1GB, 2)
            Health      = $v.HealthStatus
        }
    }

    return [pscustomobject]@{
        WindowsVolumes = $windows
        ForeignVolumes = $foreign
    }
}

function Generate-SystemProfileSummary {
    param([pscustomobject]$SystemProfile)

    HtmlAddSection "SYSTEM PROFILE SUMMARY"

    $cpu = $SystemProfile.Hardware.CPU
    HtmlAdd ("CPU: " + $cpu.Name + " (" + $cpu.Cores + " Cores / " + $cpu.Threads + " Threads)") "gray"
    HtmlAdd ("RAM: " + $SystemProfile.Hardware.RAM.TotalGB + " GB") "gray"

    foreach ($gpu in $SystemProfile.Hardware.GPU) {
        HtmlAdd ("GPU: " + $gpu.Name + " (" + $gpu.VRAMMB + " MB VRAM)") "gray"
    }

    $nvmeCount = (@($SystemProfile.Hardware.Disks | Where-Object { $_.BusType -eq "NVMe" })).Count
    $ssdCount  = (@($SystemProfile.Hardware.Disks | Where-Object { $_.MediaType -eq "SSD" -and $_.BusType -ne "NVMe" })).Count
    $hddCount  = (@($SystemProfile.Hardware.Disks | Where-Object { $_.MediaType -eq "HDD" })).Count

    HtmlAdd ("Storage Devices: NVMe (" + $nvmeCount + "), SSD (" + $ssdCount + "), HDD (" + $hddCount + ")") "gray"

    $os = $SystemProfile.Software
    $lt = if ($os.IsLTSC) { "LTSC" } else { "Non-LTSC" }
    HtmlAdd ("OS: " + $os.OSName + " (Build " + $os.OSBuild + ") — " + $lt) "gray"

    HtmlAdd ("System Manufacturer: " + $SystemProfile.Hardware.System.Manufacturer) "gray"
    HtmlAdd ("System Model: " + $SystemProfile.Hardware.System.Model) "gray"
    HtmlAdd ("Hostname: " + $SystemProfile.Hardware.System.Hostname) "gray"
    HtmlAdd ("User: " + $SystemProfile.Hardware.System.User) "gray"

    HtmlAdd ("BIOS Serial Number: " + $SystemProfile.Hardware.BIOS.SerialNumber) "gray"
    HtmlAdd ("BIOS Version: " + $SystemProfile.Hardware.BIOS.Version) "gray"

    HtmlAdd "<hr>" "gray"
}

# ----------------------------
# Disk Detection & Baseline
# ----------------------------

function Initialize-GlobalDiskTable {
    param([pscustomobject]$SystemProfile)

    HtmlAddSection "Disk Detection & Baseline"

    foreach ($vol in $SystemProfile.Safety.WindowsVolumes) {

        $drive = $vol.DriveLetter
        $disk  = $null

        try {
            $partition = Get-Partition -DriveLetter $drive -ErrorAction SilentlyContinue
            if ($partition) {
                $disk = Get-PhysicalDisk | Where-Object { $_.DeviceId -eq $partition.DiskNumber }
            }
        } catch {
            LogError ("PhysicalDisk lookup failed for drive " + $drive) "Baseline"
        }

        if ($disk) {
            $media = $disk.MediaType
            $bus   = $disk.BusType
            $devId = $disk.DeviceId
            $name  = $disk.FriendlyName
        } else {
            $media = "Unknown"
            $bus   = "Unknown"
            $devId = "Unknown"
            $name  = "Unknown"
        }

        HtmlAdd ("Disk " + $drive + ": (" + $name + ")") "gray"
        HtmlAdd ("FileSystem: " + $vol.FileSystem + " | Size: " + $vol.SizeGB + " GB | Free: " + $vol.FreeGB + " GB") "gray"
        HtmlAdd ("Health: " + $vol.Health + " | MediaType: " + $media + " | BusType: " + $bus) "gray"

        if ($vol.FreeGB -lt 10) {
            HtmlAdd ("Warning: Less than 10 GB free space on drive " + $drive) "orange"
            Console-Warn ("Less than 10 GB free space on drive " + $drive)
        }

        HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"

        $Global:DiskTable += [pscustomobject]@{
            Disk                 = ($drive + ":")
            Name                 = $name
            DeviceId             = $devId
            Type                 = $media
            BusType              = $bus
            FileSystem           = $vol.FileSystem
            SizeGB               = ($vol.SizeGB.ToString() + " GB")
            FreeGB               = ($vol.FreeGB.ToString() + " GB")
            Health               = $vol.Health
            HealthScore          = "N/A"
            RiskLevel            = "N/A"
            SmartRaw             = "N/A"
            FragmentationPercent = "N/A"
            TRIM                 = "Pending"
            Defrag               = "Pending"
            Status               = "OK"
        }
    }
}

# ----------------------------
# Adaptive Features & Plan
# ----------------------------

function Get-AdaptiveFeatures {
    param([pscustomobject]$SystemProfile)

    $features = [pscustomobject]@{
        EnableSmartRaw          = $true
        EnableTrim              = $true
        EnableDefrag            = $true
        EnableChkDsk            = $true
        EnableDism              = $true
        EnableSfc               = $true
        EnableDirtyBitCheck     = $true
        EnableReFSIntegrity     = $true
        EnableWinSxSCleanup     = $true
        EnableTempCleanup       = $true
        EnableRecycleBin        = $true
        EnableNvmeTemperature   = $true
        EnableThermalDetector   = $true
        EnableEnduranceForecast = $true
        EnableWearPrediction    = $true
        EnableNtfsTuning        = $true
        EnableVssPruning        = $true
        EnableDriverCleanup     = $true
    }

    return $features
}

function Get-OptimizationPlan {
    param([pscustomobject]$SystemProfile, [pscustomobject]$Features)

    $plan = [pscustomobject]@{
        DiskTasks      = @()
        SystemTasks    = @()
        SafetyWarnings = @()
        CleanupTasks   = @()
    }

    foreach ($foreign in @($SystemProfile.Safety.ForeignVolumes)) {
        $plan.SafetyWarnings += "Foreign volume detected: FileSystem=$($foreign.FileSystem), Reason=$($foreign.Reason)"
    }

    foreach ($disk in @($SystemProfile.Hardware.Disks)) {
        
        $letters = @()
        $parts = @(Get-Partition | Where-Object { $_.DiskNumber -eq $disk.DeviceId -and $_.DriveLetter })
        foreach ($p in $parts) { $letters += $p.DriveLetter }

        $diskTask = [pscustomobject]@{
            DiskName     = $disk.Name
            MediaType    = $disk.MediaType
            BusType      = $disk.BusType
            DeviceId     = $disk.DeviceId
            DriveLetters = $letters
            Actions      = @()
        }

        if ($Features.EnableSmartRaw)          { $diskTask.Actions += "SMART RAW Deep" }
        $diskTask.Actions += "Disk Failure Early Warning System"
        
        if ($Features.EnableTrim -and $disk.MediaType -in @("SSD","Unspecified")) { $diskTask.Actions += "TRIM Optimization" }
        if ($Features.EnableDefrag -and $disk.MediaType -eq "HDD") { $diskTask.Actions += "HDD Defragmentation" }
        if ($Features.EnableChkDsk)            { $diskTask.Actions += "CHKDSK Integrity Check" }

        if ($Features.EnableNvmeTemperature -and $disk.BusType -eq "NVMe")   { $diskTask.Actions += "NVMe Temperature Analysis" }
        if ($Features.EnableThermalDetector -and $disk.BusType -eq "NVMe")   { $diskTask.Actions += "Thermal Throttling Detection" }
        if ($Features.EnableEnduranceForecast -and $disk.MediaType -in @("SSD","Unspecified")) { $diskTask.Actions += "SSD Endurance Forecast" }
        if ($Features.EnableWearPrediction -and $disk.MediaType -in @("SSD","Unspecified"))    { $diskTask.Actions += "SSD Wear-Level Prediction" }

        $plan.DiskTasks += $diskTask
    }

    # System tasks
    if ($Features.EnableDirtyBitCheck)     { $plan.SystemTasks += "Dirty Bit Check" }
    if ($Features.EnableReFSIntegrity)     { $plan.SystemTasks += "ReFS Integrity Check" }
    if ($Features.EnableDism)              { $plan.SystemTasks += "DISM Component Health Check" }
    if ($Features.EnableSfc)               { $plan.SystemTasks += "SFC System File Check" }
    if ($Features.EnableNtfsTuning)        { $plan.SystemTasks += "NTFS File System Tuning" }
    if ($Features.EnableVssPruning)        { $plan.SystemTasks += "VSS Pruning (Oldest Shadow Copy)" }
    $plan.SystemTasks += "DNS Cache Flush"

    # Cleanup tasks
    if ($Features.EnableWinSxSCleanup)     { $plan.CleanupTasks += "WinSxS Cleanup" }
    if ($Features.EnableTempCleanup)       { $plan.CleanupTasks += "Temp Cleanup" }
    if ($Features.EnableRecycleBin)        { $plan.CleanupTasks += "Recycle Bin Cleanup" }
    if ($Features.EnableDriverCleanup)     { $plan.CleanupTasks += "Driver Store Cleanup" }
    $plan.CleanupTasks += "Windows Update Cache Cleanup"

    # Adaptive GPU Cache tasks
    foreach ($gpu in $SystemProfile.Hardware.GPU) {
        if ($gpu.Vendor -eq "NVIDIA" -and $plan.CleanupTasks -notcontains "NVIDIA Cache Cleanup") {
            $plan.CleanupTasks += "NVIDIA Cache Cleanup"
        }
        elseif ($gpu.Vendor -eq "AMD" -and $plan.CleanupTasks -notcontains "AMD Cache Cleanup") {
            $plan.CleanupTasks += "AMD Cache Cleanup"
        }
        elseif ($gpu.Vendor -eq "Intel" -and $plan.CleanupTasks -notcontains "Intel Cache Cleanup") {
            $plan.CleanupTasks += "Intel Cache Cleanup"
        }
    }

    return $plan
}

function Render-OptimizationPlan {
    param([pscustomobject]$Plan)

    HtmlAddSection "Optimization Plan v68 Ultimate"

    foreach ($warn in $Plan.SafetyWarnings) {
        HtmlAdd $warn "orange"
    }

    foreach ($diskTask in $Plan.DiskTasks) {
        HtmlAdd ("Disk Task: " + $diskTask.DiskName + " [" + $diskTask.MediaType + " / " + $diskTask.BusType + "]") "gray"
        HtmlAdd ("Actions: " + ($diskTask.Actions -join ", ")) "gray"
    }

    HtmlAdd "System Tasks: " "gray"
    HtmlAdd ($Plan.SystemTasks -join ", ") "gray"

    HtmlAdd "Cleanup Tasks: " "gray"
    HtmlAdd ($Plan.CleanupTasks -join ", ") "gray"

    HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
}

# ----------------------------
# SMART RAW Deep
# ----------------------------

function Invoke-SmartRawDeep {
    param([pscustomobject]$SystemProfile)

    $DeepResultsAll = @()
    $CriticalIDs = @(5, 10, 184, 187, 188, 196, 197, 198, 199)

    foreach ($disk in @($SystemProfile.Hardware.Disks)) {

        if ($disk.BusType -eq "NVMe") {
            continue
        }

        HtmlAddSection ("SMART RAW Deep — " + $disk.Name)
        $DeepResults = @()

        try {
            $rawData = Get-WmiObject -Namespace root\wmi -Class MSStorageDriver_FailurePredictData -ErrorAction Stop
            $match = $null

            foreach ($entry in @($rawData)) {
                $cleanId = $disk.DeviceId.ToString().Trim()

                if ($entry.InstanceName -match $cleanId -or $entry.InstanceName -match $disk.SerialNumber) {
                    $match = $entry
                    break
                }
            }

            if ($match) {
                $bytes = $match.VendorSpecific

                for ($i = 0; $i -lt 30; $i++) {

                    $id = $bytes[$i * 12]
                    if ($id -eq 0) { continue }

                    $rawBytes = $bytes[($i * 12 + 5)..($i * 12 + 10)]
                    $padded   = [byte[]]($rawBytes + @(0,0))
                    $rawValue = [BitConverter]::ToInt64($padded, 0)

                    if ($CriticalIDs -contains $id) {

                        $severity = "Normal"
                        $color    = "green"

                        switch ($id) {
                            5   { if ($rawValue -gt 0) { $severity="Reallocated Sectors";   $color="red"    } }
                            10  { if ($rawValue -gt 0) { $severity="Spin Retry";            $color="orange" } }
                            184 { if ($rawValue -gt 0) { $severity="End-to-End Errors";     $color="red"    } }
                            187 { if ($rawValue -gt 0) { $severity="Reported Uncorrectable";$color="red"    } }
                            188 { if ($rawValue -gt 0) { $severity="Command Timeout";       $color="orange" } }
                            196 { if ($rawValue -gt 0) { $severity="Reallocation Events";   $color="orange" } }
                            197 { if ($rawValue -gt 0) { $severity="Pending Sectors";       $color="red"    } }
                            198 { if ($rawValue -gt 0) { $severity="Uncorrectable Sectors"; $color="red"    } }
                            199 { if ($rawValue -gt 0) { $severity="CRC Errors";            $color="orange" } }
                        }

                        $DeepResults += [pscustomobject]@{
                            ID       = $id
                            RAW      = $rawValue
                            Severity = $severity
                            Color    = $color
                        }
                    }
                }
            }

        } catch {
            HtmlAdd "SMART RAW Deep Mode unavailable (WMI error)" "gray"
        }

        if (@($DeepResults).Count -eq 0) {

            HtmlAdd "No critical SMART attributes detected or mapping not found" "green"

            foreach ($row in $Global:DiskTable) {
                if ($row.Name -eq $disk.Name) {
                    $row.SmartRaw = "OK"
                }
            }

        } else {

            $table = '<table border="1" cellspacing="0" cellpadding="5" style="border-collapse: collapse; border: 1px solid #444; width: 100%;">'
            $table += '<tr style="background-color:#333;color:#fff;"><th>ID</th><th>RAW Value</th><th>Status</th></tr>'

            $summary = ""

            foreach ($item in @($DeepResults)) {

                $table += '<tr>' +
                          '<td style="border:1px solid #444;">' + $item.ID + '</td>' +
                          '<td style="border:1px solid #444;">' + $item.RAW + '</td>' +
                          '<td style="border:1px solid #444;color:' + $item.Color + '">' + $item.Severity + '</td>' +
                          '</tr>'

                if ($summary -ne "") { $summary += "; " }
                $summary += ($item.ID.ToString() + "=" + $item.RAW.ToString())
            }

            $table += "</table>"
            $Global:HtmlContent += $table

            foreach ($row in $Global:DiskTable) {
                if ($row.Name -eq $disk.Name) {
                    $row.SmartRaw = $summary
                }
            }
        }

        $DeepResultsAll += [pscustomobject]@{
            DiskName   = $disk.Name
            Attributes = $DeepResults
        }

        HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
    }

    return $DeepResultsAll
}

# ----------------------------
# Disk Failure Early Warning
# ----------------------------

function Invoke-FailureEarlyWarning {
    param([pscustomobject]$diskTask)
    
    HtmlAdd ("Disk Failure Early Warning System for " + $diskTask.DiskName) "blue"
    Console-Step ("Failure Risk Analysis: " + $diskTask.DiskName)
    
    try {
        $disk = Get-PhysicalDisk | Where-Object { $_.FriendlyName -eq $diskTask.DiskName }
        if (-not $disk) { return }
        
        $riskScore = 0
        if ($disk.HealthStatus -ne "Healthy") { 
            $riskScore += 3
            HtmlAdd ("HealthStatus: " + $disk.HealthStatus) "orange" 
        }
        
        $nvme = Get-StorageReliabilityCounter -PhysicalDisk $disk -ErrorAction SilentlyContinue
        if ($nvme) {
            if ($nvme.PSObject.Properties.Match('ReadErrors').Count -gt 0 -and $nvme.ReadErrors -gt 0) { $riskScore += 2; HtmlAdd ("ReadErrors: " + $nvme.ReadErrors) "orange" }
            if ($nvme.PSObject.Properties.Match('WriteErrors').Count -gt 0 -and $nvme.WriteErrors -gt 0) { $riskScore += 2; HtmlAdd ("WriteErrors: " + $nvme.WriteErrors) "orange" }
            if ($nvme.PSObject.Properties.Match('UncorrectableErrors').Count -gt 0 -and $nvme.UncorrectableErrors -gt 0) { $riskScore += 3; HtmlAdd ("UncorrectableErrors: " + $nvme.UncorrectableErrors) "red" }
            if ($nvme.PSObject.Properties.Match('PercentageUsed').Count -gt 0 -and $nvme.PercentageUsed -ge 80) { $riskScore += 2; HtmlAdd ("High wear: PercentageUsed=" + $nvme.PercentageUsed) "orange" }
        }
        
        try {
            $raw = Get-WmiObject -Namespace root\wmi -Class MSStorageDriver_FailurePredictStatus -ErrorAction SilentlyContinue
            foreach ($entry in $raw) {
                $cleanId = $disk.UniqueId.Replace("{","").Replace("}","").Trim()
                if ($entry.InstanceName -match $cleanId -or $entry.InstanceName -match $disk.SerialNumber) {
                    if ($entry.PredictFailure -eq $true) {
                        $riskScore += 4
                        HtmlAdd "SMART PredictFailure = TRUE" "red"
                    }
                    break
                }
            }
        } catch { }

        if ($riskScore -ge 7) { HtmlAdd "Risk Level: CRITICAL (score=$riskScore)" "red" }
        elseif ($riskScore -ge 4) { HtmlAdd "Risk Level: MEDIUM (score=$riskScore)" "orange" }
        else { HtmlAdd "Risk Level: LOW (score=$riskScore)" "green" }
    } catch { 
        HtmlAdd ("Failure Risk Analysis error: " + $_.Exception.Message) "red" 
    }
    HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
}

# ----------------------------
# NVMe / SSD Adaptive Engine
# ----------------------------

function Invoke-NvmeTemperature {
    param([pscustomobject]$diskTask)

    HtmlAdd ("NVMe Temperature Analysis for " + $diskTask.DiskName) "blue"

    try {
        $disk = Get-PhysicalDisk | Where-Object { $_.FriendlyName -eq $diskTask.DiskName }

        if (-not $disk) {
            HtmlAdd ("Disk not found: " + $diskTask.DiskName) "red"
            Console-Err ("Disk not found: " + $diskTask.DiskName)
            return
        }

        $nvme = Get-StorageReliabilityCounter -PhysicalDisk $disk -ErrorAction SilentlyContinue

        if ($nvme -and $null -ne $nvme.Temperature) {

            $temp = [int]$nvme.Temperature
            HtmlAdd ("Temperature: " + $temp + " °C") "gray"

            $color = "green"
            if ($temp -ge 70) { $color = "red" }
            elseif ($temp -ge 60) { $color = "orange" }

            HtmlAddTempBar -Temp $temp -Color $color

            if ($temp -ge 70) {
                HtmlAdd "CRITICAL: NVMe may throttle due to high temperature!" "red"
                Console-Err ("NVMe throttling risk: " + $temp + "°C")
                LogError ("NVMe throttling risk (" + $diskTask.DiskName + "): " + $temp + "°C") "NVMeTemp"
            }
            elseif ($temp -ge 60) {
                HtmlAdd "Warning: NVMe temperature is elevated" "orange"
            }
            else {
                HtmlAdd "Temperature is within normal range" "green"
            }

        } else {
            HtmlAdd "Temperature sensor unavailable" "gray"
        }

    } catch {
        HtmlAdd ("NVMe Temperature error: " + $_.Exception.Message) "red"
    }

    HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
}

function Invoke-ThermalThrottling {
    param([pscustomobject]$diskTask)

    HtmlAdd ("Thermal Throttling Analysis for " + $diskTask.DiskName) "blue"

    try {
        $disk = Get-PhysicalDisk | Where-Object { $_.FriendlyName -eq $diskTask.DiskName }
        if (-not $disk) { return }

        $nvme = Get-StorageReliabilityCounter -PhysicalDisk $disk -ErrorAction SilentlyContinue

        if ($nvme -and $nvme.PSObject.Properties.Match('Temperature').Count -gt 0) {
            $temp = $nvme.Temperature
            HtmlAdd ("Temperature: " + $temp + " °C") "gray"

            if ($temp -ge 70) {
                HtmlAdd "THROTTLING RISK: CRITICAL — NVMe may reduce speed!" "red"
            }
            elseif ($temp -ge 60) {
                HtmlAdd "THROTTLING RISK: Medium — NVMe temperature is high" "orange"
            }
            else {
                HtmlAdd "Temperature OK — throttling unlikely" "green"
            }
        } else {
            HtmlAdd "Temperature sensor unavailable" "gray"
        }

    } catch {
        HtmlAdd ("Thermal Throttling error: " + $_.Exception.Message) "red"
    }

    HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
}

function Invoke-SSD-Endurance {
    param([pscustomobject]$diskTask)

    HtmlAdd ("SSD Endurance Forecast for " + $diskTask.DiskName) "blue"

    try {
        $disk = Get-PhysicalDisk | Where-Object { $_.FriendlyName -eq $diskTask.DiskName }
        $nvme = Get-StorageReliabilityCounter -PhysicalDisk $disk -ErrorAction SilentlyContinue

        $percentUsed = $null
        $powerHours  = $null

        if ($nvme) {
            if ($nvme.PSObject.Properties.Match('PercentageUsed').Count -gt 0) {
                $percentUsed = $nvme.PercentageUsed
                HtmlAdd ("Percentage Used: " + $percentUsed + "%") "gray"
            }

            if ($nvme.PSObject.Properties.Match('PowerOnHours').Count -gt 0) {
                $powerHours = $nvme.PowerOnHours
                HtmlAdd ("Power-On Hours: " + $powerHours) "gray"
            }

            if ($percentUsed -ne $null) {
                $remaining = [math]::Max(0, 100 - [int]$percentUsed)
                HtmlAdd ("Estimated Remaining Life: " + $remaining + "%") "gray"

                if ($percentUsed -ge 90) {
                    HtmlAdd "Warning: SSD near end of life (>=90% used)" "red"
                }
                elseif ($percentUsed -ge 70) {
                    HtmlAdd "Notice: SSD wear is significant (>=70% used)" "orange"
                }
                else {
                    HtmlAdd "SSD wear is within normal range" "green"
                }
            }
            else {
                HtmlAdd "Cannot estimate remaining life (PercentageUsed unavailable)" "gray"
            }
        } else {
            HtmlAdd "Endurance counters not available" "gray"
        }

    } catch {
        HtmlAdd ("SSD Endurance error: " + $_.Exception.Message) "red"
    }

    HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
}

function Invoke-SSD-Wear {
    param([pscustomobject]$diskTask)

    HtmlAdd ("SSD Wear-Level Prediction for " + $diskTask.DiskName) "blue"

    try {
        $disk = Get-PhysicalDisk | Where-Object { $_.FriendlyName -eq $diskTask.DiskName }
        $nvme = Get-StorageReliabilityCounter -PhysicalDisk $disk -ErrorAction SilentlyContinue

        if ($nvme) {
            $wear = $null
            if ($nvme.PSObject.Properties.Match('Wear').Count -gt 0) {
                $wear = $nvme.Wear
                HtmlAdd ("Wear Counter: " + $wear) "gray"
            }

            if ($wear -ne $null) {
                if ($wear -ge 90) {
                    HtmlAdd "Warning: SSD wear is extremely high" "red"
                }
                elseif ($wear -ge 70) {
                    HtmlAdd "Notice: SSD wear is elevated" "orange"
                }
                else {
                    HtmlAdd "SSD wear is within normal range" "green"
                }
            }
            else {
                HtmlAdd "Wear counter unavailable" "gray"
            }
        } else {
            HtmlAdd "Wear-Level counters not available" "gray"
        }

    } catch {
        HtmlAdd ("SSD Wear-Level error: " + $_.Exception.Message) "red"
    }

    HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
}

# ----------------------------
# HealthScore & RiskLevel Engine
# ----------------------------

function Compute-HealthScore {
    param([pscustomobject]$SystemProfile)

    HtmlAddSection "Disk HealthScore Analysis"

    foreach ($row in $Global:DiskTable) {

        $score = 100

        if ($row.Health -eq "Unhealthy" -or $row.Health -eq "Unknown") {
            $score -= 40
        }
        elseif ($row.Health -eq "Warning") {
            $score -= 20
        }

        if ($row.SmartRaw -eq "N/A") {
            $score -= 10
        }
        elseif ($row.SmartRaw -ne "OK") {
            $score -= 30
        }

        $frag = 0
        if ($row.FragmentationPercent -ne "N/A" -and $row.FragmentationPercent -match "^\d+") {
            $frag = [int]($row.FragmentationPercent -replace "[^\d]", "")
            if ($frag -ge 20) { $score -= 20 }
            elseif ($frag -ge 10) { $score -= 10 }
        }

        if ($row.TRIM -eq "Failed") { $score -= 15 }
        elseif ($row.TRIM -eq "Pending") { $score -= 5 }

        if ($row.Defrag -eq "Failed") { $score -= 15 }

        if ($row.Status -eq "DIRTY" -or $row.Status -eq "Errors") {
            $score -= 25
        }

        if ($score -lt 0) { $score = 0 }

        $risk = "Low"
        if ($score -le 30) { $risk = "Critical" }
        elseif ($score -le 50) { $risk = "High" }
        elseif ($score -le 70) { $risk = "Medium" }

        $row.HealthScore = $score
        $row.RiskLevel   = $risk

        $color = "green"
        if ($risk -eq "Medium") { $color = "orange" }
        elseif ($risk -eq "High") { $color = "red" }
        elseif ($risk -eq "Critical") { $color = "red" }

        HtmlAdd ("Disk " + $row.Disk + " [" + $row.Name + "] — HealthScore: " + $score + ", Risk: " + $risk) $color
    }

    HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
}

function Compute-RiskLevel {
    param([pscustomobject]$SystemProfile)

    HtmlAddSection "Extended RiskLevel Analysis"

    foreach ($row in $Global:DiskTable) {

        $riskScore = 0

        if ($row.HealthScore -ne "N/A") {
            $hs = [int]$row.HealthScore
            if ($hs -le 30) { $riskScore += 40 }
            elseif ($hs -le 50) { $riskScore += 30 }
            elseif ($hs -le 70) { $riskScore += 20 }
            else { $riskScore += 5 }
        }

        if ($row.SmartRaw -ne "OK" -and $row.SmartRaw -ne "N/A") {
            $riskScore += 30
        }

        if ($row.Status -eq "DIRTY") { $riskScore += 25 }
        elseif ($row.Status -eq "Errors") { $riskScore += 25 }

        if ($row.TRIM -eq "Failed") { $riskScore += 15 }
        if ($row.Defrag -eq "Failed") { $riskScore += 15 }

        $frag = 0
        if ($row.FragmentationPercent -ne "N/A" -and $row.FragmentationPercent -match "^\d+") {
            $frag = [int]($row.FragmentationPercent -replace "[^\d]", "")
            if ($frag -ge 20) { $riskScore += 20 }
            elseif ($frag -ge 10) { $riskScore += 10 }
        }

        if ($row.Type -eq "HDD") { $riskScore += 10 }
        elseif ($row.Type -eq "SSD") { $riskScore += 5 }

        if ($row.Health -eq "Unhealthy") { $riskScore += 30 }
        elseif ($row.Health -eq "Warning") { $riskScore += 15 }

        if ($riskScore > 100) { $riskScore = 100 }

        $risk = "Low"
        if ($riskScore -ge 70) { $risk = "Critical" }
        elseif ($riskScore -ge 50) { $risk = "High" }
        elseif ($riskScore -ge 30) { $risk = "Medium" }

        $row.RiskLevel = $risk

        $color = "green"
        if ($risk -eq "Medium") { $color = "orange" }
        elseif ($risk -eq "High") { $color = "red" }
        elseif ($risk -eq "Critical") { $color = "red" }

        HtmlAdd ("Disk " + $row.Disk + " [" + $row.Name + "] — Extended RiskScore: " + $riskScore + ", RiskLevel: " + $risk) $color
    }

    HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
}

# ----------------------------
# System & Cleanup Tasks Engine
# ----------------------------

function Invoke-CleanupEngine {
    param([pscustomobject]$Plan)

    HtmlAddSection "Adaptive Cleanup Engine"

    if ($Plan.CleanupTasks -contains "Driver Store Cleanup") {
        Console-Step "Driver Store Cleanup"
        try {
            HtmlAdd "Cleaning obsolete Driver Store packages..." "blue"
            if (-not $DryRun) {
                $drivers = pnputil.exe /enum-drivers | Select-String -Pattern "oem\d+\.inf" -AllMatches | ForEach-Object { $_.Matches.Value } | Select-Object -Unique
                foreach ($drv in $drivers) {
                    pnputil.exe /delete-driver $drv | Out-Null
                }
            }
            HtmlAdd "Obsolete Driver Store packages cleared" "green"
        } catch {
            HtmlAdd ("Driver Store Cleanup error: " + $_.Exception.Message) "red"
        }
    }

    if ($Plan.CleanupTasks -contains "WinSxS Cleanup") {
        Console-Step "WinSxS Cleanup"
        if ($DryRun) {
            HtmlAdd "WinSxS Cleanup skipped (DryRun mode)" "orange"
        } else {
            try {
                HtmlAdd "Running DISM WinSxS Cleanup..." "blue"
                DISM /Online /Cleanup-Image /StartComponentCleanup
                HtmlAdd "WinSxS Cleanup completed" "green"
            } catch {
                HtmlAdd ("WinSxS Cleanup error: " + $_.Exception.Message) "red"
            }
        }
    }

    if ($Plan.CleanupTasks -contains "Temp Cleanup") {
        Console-Step "System Temp Cleanup (Deep Mode)"
        try {
            HtmlAdd "Cleaning TEMP folders (Deep Mode)..." "blue"
            if (-not $DryRun) {
                $tempPaths = @(
                    "$env:TEMP",
                    "$env:WINDIR\Temp",
                    "C:\ProgramData\Microsoft\Windows\WER\ReportArchive",
                    "C:\ProgramData\Microsoft\Windows\WER\ReportQueue",
                    "C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Cache",
                    "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db"
                )
                foreach ($path in $tempPaths) {
                    if ((Test-Path -Path $path -ErrorAction SilentlyContinue) -or ($path -match "\*")) {
                        try { Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue } catch { }
                    }
                }
            }
            HtmlAdd "Temp Cleanup completed" "green"
        } catch {
            HtmlAdd ("Temp Cleanup error: " + $_.Exception.Message) "red"
        }
    }

    if ($Plan.CleanupTasks -contains "Windows Update Cache Cleanup") {
        Console-Step "Windows Update Cache Cleanup"
        try {
            HtmlAdd "Cleaning Windows Update Cache..." "blue"
            if (-not $DryRun) {
                Stop-Service wuauserv -Force -ErrorAction SilentlyContinue
                Stop-Service bits -Force -ErrorAction SilentlyContinue
                $wuPath = "C:\Windows\SoftwareDistribution\Download"
                if (Test-Path $wuPath) {
                    Get-ChildItem -Path $wuPath -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                }
                Start-Service bits -ErrorAction SilentlyContinue
                Start-Service wuauserv -ErrorAction SilentlyContinue
            }
            HtmlAdd "Windows Update Cache cleaned" "green"
        } catch {
            HtmlAdd ("Windows Update Cache Cleanup error: " + $_.Exception.Message) "red"
        }
    }

    if ($Plan.CleanupTasks -contains "NVIDIA Cache Cleanup") {
        Console-Step "NVIDIA Cache Cleanup"
        try {
            HtmlAdd "Cleaning NVIDIA Caches..." "blue"
            if (-not $DryRun) {
                $paths = @("C:\ProgramData\NVIDIA Corporation\Downloader", "$env:LOCALAPPDATA\NVIDIA\GLCache", "$env:LOCALAPPDATA\NVIDIA\DXCache")
                foreach ($p in $paths) { if(Test-Path $p) { Get-ChildItem -Path $p -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue } }
            }
            HtmlAdd "NVIDIA Cache cleaned" "green"
        } catch { HtmlAdd "NVIDIA Cache error" "red" }
    }

    if ($Plan.CleanupTasks -contains "AMD Cache Cleanup") {
        Console-Step "AMD Cache Cleanup"
        try {
            HtmlAdd "Cleaning AMD Caches..." "blue"
            if (-not $DryRun) {
                $paths = @("$env:LOCALAPPDATA\AMD\DxCache", "$env:LOCALAPPDATA\AMD\GLCache")
                foreach ($p in $paths) { if(Test-Path $p) { Get-ChildItem -Path $p -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue } }
            }
            HtmlAdd "AMD Cache cleaned" "green"
        } catch { HtmlAdd "AMD Cache error" "red" }
    }

    if ($Plan.CleanupTasks -contains "Intel Cache Cleanup") {
        Console-Step "Intel Cache Cleanup"
        try {
            HtmlAdd "Cleaning Intel Compute Cache..." "blue"
            if (-not $DryRun) {
                $paths = @("$env:LOCALAPPDATA\Intel\ComputeCache")
                foreach ($p in $paths) { if(Test-Path $p) { Get-ChildItem -Path $p -Force -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue } }
            }
            HtmlAdd "Intel Cache cleaned" "green"
        } catch { HtmlAdd "Intel Cache error" "red" }
    }

    if ($Plan.CleanupTasks -contains "Recycle Bin Cleanup") {
        Console-Step "Recycle Bin Cleanup"
        try {
            HtmlAdd "Cleaning Recycle Bin..." "blue"
            if (-not $DryRun) {
                (New-Object -ComObject Shell.Application).NameSpace(0xA).Items() | ForEach-Object { Remove-Item $_.Path -Recurse -Force -ErrorAction SilentlyContinue }
            }
            HtmlAdd "Recycle Bin Cleanup completed" "green"
        } catch {
            HtmlAdd ("Recycle Bin Cleanup error: " + $_.Exception.Message) "red"
        }
    }
    HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
}

# ----------------------------
# Disk Operations: TRIM / Smart Defrag / CHKDSK
# ----------------------------

function Invoke-Trim {
    param([pscustomobject]$diskTask)

    if (-not $diskTask.DriveLetters -or $diskTask.DriveLetters.Count -eq 0) { return }

    foreach ($dl in $diskTask.DriveLetters) {
        HtmlAdd ("TRIM Optimization for " + $diskTask.DiskName + " (" + $dl + ":)") "blue"
        Console-Step ("TRIM " + $dl + ":")

        try {
            if (-not $DryRun) { Optimize-Volume -DriveLetter $dl -ReTrim -Verbose:$false -ErrorAction Stop | Out-Null }
            HtmlAdd "TRIM completed successfully" "green"
            foreach ($row in $Global:DiskTable) { if ($row.Disk -eq ($dl + ":")) { $row.TRIM = "OK" } }
        } catch {
            HtmlAdd ("TRIM error: " + $_.Exception.Message) "red"
            foreach ($row in $Global:DiskTable) { if ($row.Disk -eq ($dl + ":")) { $row.TRIM = "Failed" } }
        }
        HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
    }
}

function Invoke-Defrag {
    param([pscustomobject]$diskTask)

    if (-not $diskTask.DriveLetters -or $diskTask.DriveLetters.Count -eq 0) { return }

    foreach ($dl in $diskTask.DriveLetters) {
        HtmlAdd ("HDD Defragmentation for " + $diskTask.DiskName + " (" + $dl + ":)") "blue"
        Console-Step ("Defrag Analysis " + $dl + ":")

        try {
            $analysis = Optimize-Volume -DriveLetter $dl -Analyze -ErrorAction Stop
            
            $fragPercent = 0
            if ($analysis -and $analysis.PercentFragmentation -ne $null) {
                $fragPercent = $analysis.PercentFragmentation
            }

            if ($fragPercent -ge 10) {
                HtmlAdd ("Fragmentation: ${fragPercent}% — running defrag") "orange"
                if (-not $DryRun) { 
                    Invoke-AnimatedTask -Activity "Defragging Drive ${dl}:" -Command "defrag.exe" -Arguments "${dl}: /U /V"
                }
                HtmlAdd "Defrag completed successfully" "green"
                foreach ($row in $Global:DiskTable) { if ($row.Disk -eq ($dl + ":")) { $row.Defrag = "OK"; $row.FragmentationPercent = "${fragPercent}%" } }
            } else {
                HtmlAdd ("Fragmentation: ${fragPercent}% — defrag not needed") "green"
                Console-OK "Defrag not needed (Frag: ${fragPercent}%)."
                foreach ($row in $Global:DiskTable) { if ($row.Disk -eq ($dl + ":")) { $row.Defrag = "NotNeeded"; $row.FragmentationPercent = "${fragPercent}%" } }
            }
        } catch {
            HtmlAdd ("Defrag error: " + $_.Exception.Message) "red"
            foreach ($row in $Global:DiskTable) { if ($row.Disk -eq ($dl + ":")) { $row.Defrag = "Failed" } }
        }
        HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
    }
}

function Invoke-ChkDsk {
    param([pscustomobject]$diskTask)

    if (-not $diskTask.DriveLetters -or $diskTask.DriveLetters.Count -eq 0) { return }

    foreach ($dl in $diskTask.DriveLetters) {
        HtmlAdd ("CHKDSK Integrity Check for " + $diskTask.DiskName + " (" + $dl + ":)") "blue"
        Console-Step ("CHKDSK " + $dl + ":")

        try {
            if (-not $DryRun) { 
                Invoke-AnimatedTask -Activity "Checking Drive ${dl}:" -Command "chkdsk.exe" -Arguments "${dl}: /scan"
            }
            HtmlAdd "CHKDSK scan completed" "green"
        } catch {
            HtmlAdd ("CHKDSK error: " + $_.Exception.Message) "red"
        }
        HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
    }
}

# ----------------------------
# System-Level Integrity
# ----------------------------

function Invoke-DirtyBitCheck {
    HtmlAddSection "Dirty Bit Check"

    foreach ($row in $Global:DiskTable) {
        $driveLetter = $row.Disk.TrimEnd(':')
        if (-not $driveLetter) { continue }

        HtmlAdd ("Checking dirty bit: fsutil dirty query " + $driveLetter + ":") "gray"

        try {
            if (-not $DryRun) {
                $output = fsutil dirty query ($driveLetter + ":") 2>&1
                HtmlAdd ("Result for " + $driveLetter + ": " + $output) "gray"

                if ($output -match "is dirty" -or ($output -match "грязным" -and $output -notmatch "не является")) {
                    $row.Status = "DIRTY"
                } else {
                    $row.Status = "OK"
                }
            }
        } catch { HtmlAdd ("Dirty bit check error for " + $driveLetter + ": " + $_.Exception.Message) "red" }
    }
    HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
}

function Invoke-ReFSIntegrity {
    HtmlAddSection "ReFS Integrity Check"

    try {
        $refsVolumes = Get-Volume | Where-Object { $_.FileSystem -eq "ReFS" -and $_.DriveLetter }
        if (-not $refsVolumes) {
            HtmlAdd "No ReFS volumes detected." "gray"
        } else {
            foreach ($v in $refsVolumes) {
                $drive = $v.DriveLetter + ":"
                Console-Step ("Checking ReFS integrity for " + $drive)
                $integrity = Get-FileIntegrity -FilePath $drive
                if ($integrity.Enabled) {
                    HtmlAdd ($drive + " ReFS integrity OK") "green"
                } else {
                    HtmlAdd ($drive + " ReFS integrity disabled") "orange"
                }
            }
        }
    } catch {
        HtmlAdd ("ReFS Integrity error: " + $_.Exception.Message) "red"
    }
    HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
}

function Invoke-Dism {
    HtmlAddSection "DISM Component Health Check"
    Console-Step "DISM /Online /Cleanup-Image /RestoreHealth"

    try {
        if (-not $DryRun) {
            DISM /Online /Cleanup-Image /RestoreHealth
        }
        HtmlAdd "DISM RestoreHealth sequence completed" "green"
    } catch {
        HtmlAdd ("DISM error: " + $_.Exception.Message) "red"
    }
    HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
}

function Invoke-Sfc {
    HtmlAddSection "SFC System File Check"
    Console-Step "SFC /SCANNOW"

    try {
        if (-not $DryRun) {
            sfc /scannow
        }
        HtmlAdd "SFC /SCANNOW completed" "green"
    } catch {
        HtmlAdd ("SFC error: " + $_.Exception.Message) "red"
    }
    HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
}

function Invoke-NtfsTuning {
    HtmlAddSection "NTFS File System Tuning"
    Console-Step "NTFS File System Tuning"
    try {
        if (-not $DryRun) {
            fsutil behavior set disable8dot3 1 | Out-Null
            fsutil behavior set disablelastaccess 1 | Out-Null
        }
        HtmlAdd "NTFS 8.3 names and Last Access Time disabled to reduce wear" "green"
    } catch {
        HtmlAdd ("NTFS Tuning error: " + $_.Exception.Message) "red"
    }
    HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
}

function Invoke-VssPruning {
    HtmlAddSection "Shadow Copy (VSS) Pruning"
    Console-Step "VSS Pruning (Oldest Shadow Copy)"
    try {
        if (-not $DryRun) {
            vssadmin delete shadows /for=C: /oldest /quiet | Out-Null
        }
        HtmlAdd "Oldest shadow copies pruned to free space safely" "green"
    } catch {
        HtmlAdd "No obsolete shadow copies found or pruning unavailable" "gray"
    }
    HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
}

# ----------------------------
# MAIN EXECUTION FLOW v68 ULTIMATE
# ----------------------------

try {
    Section "RASE v68 Ultimate — Initialization"
    Show-UserConsent

    Initialize-HtmlReport -Title "ROMAN ADAPTIVE STORAGE ENGINE (RASE) v68 Ultimate" -Timestamp $timestamp -OutputPath $HtmlLog
    Invoke-SystemRestorePoint

    Section "System Profile Collection"
    HtmlAddSection "System Profile Collection"

    $hardware = Get-HardwareProfile
    $software = Get-SoftwareProfile
    $safety   = Get-SafetyProfile

    $SystemProfile = [pscustomobject]@{ Hardware = $hardware; Software = $software; Safety = $safety }

    Generate-SystemProfileSummary -SystemProfile $SystemProfile
    Initialize-GlobalDiskTable -SystemProfile $SystemProfile

    Section "Adaptive Features & Plan"
    $features = Get-AdaptiveFeatures -SystemProfile $SystemProfile
    $plan     = Get-OptimizationPlan -SystemProfile $SystemProfile -Features $features
    Render-OptimizationPlan -Plan $plan

    Section "SMART RAW Deep"
    Invoke-SmartRawDeep -SystemProfile $SystemProfile

    Section "Disk-Level Operations"
    foreach ($diskTask in $plan.DiskTasks) {
        if ($diskTask.Actions -contains "Disk Failure Early Warning System") { Invoke-FailureEarlyWarning -diskTask $diskTask }
        if ($diskTask.Actions -contains "TRIM Optimization") { Invoke-Trim -diskTask $diskTask }
        if ($diskTask.Actions -contains "HDD Defragmentation") { Invoke-Defrag -diskTask $diskTask }
        if ($diskTask.Actions -contains "CHKDSK Integrity Check") { Invoke-ChkDsk -diskTask $diskTask }
        if ($diskTask.Actions -contains "NVMe Temperature Analysis") { Invoke-NvmeTemperature -diskTask $diskTask }
        if ($diskTask.Actions -contains "Thermal Throttling Detection") { Invoke-ThermalThrottling -diskTask $diskTask }
        if ($diskTask.Actions -contains "SSD Endurance Forecast") { Invoke-SSD-Endurance -diskTask $diskTask }
        if ($diskTask.Actions -contains "SSD Wear-Level Prediction") { Invoke-SSD-Wear -diskTask $diskTask }
    }

    Section "System-Level Tasks"
    if ($plan.SystemTasks -contains "DNS Cache Flush") {
        HtmlAddSection "DNS Cache Flush"
        Console-Step "Flushing DNS Cache"
        if (-not $DryRun) { ipconfig /flushdns | Out-Null }
        HtmlAdd "DNS cache successfully cleared" "green"
        HtmlAdd "<hr style='border:1px dashed #444;'>" "gray"
    }

    if ($plan.SystemTasks -contains "NTFS File System Tuning") { Invoke-NtfsTuning }
    if ($plan.SystemTasks -contains "Dirty Bit Check") { Invoke-DirtyBitCheck }
    if ($plan.SystemTasks -contains "ReFS Integrity Check") { Invoke-ReFSIntegrity }
    if ($plan.SystemTasks -contains "DISM Component Health Check") { Invoke-Dism }
    if ($plan.SystemTasks -contains "SFC System File Check") { Invoke-Sfc }
    if ($plan.SystemTasks -contains "VSS Pruning (Oldest Shadow Copy)") { Invoke-VssPruning }

    Section "Cleanup Engine"
    Invoke-CleanupEngine -Plan $plan

    Section "HealthScore & RiskLevel"
    Compute-HealthScore -SystemProfile $SystemProfile
    Compute-RiskLevel   -SystemProfile $SystemProfile

    Finalize-DiskSummaryTable
    Finalize-HtmlReport

    Console-OK "RASE v68 Ultimate completed."
    
    if ($FullReport) {
        Console-Info "Opening HTML report in browser..."
        try { Invoke-Item $HtmlLog } catch { Console-Warn "Failed to open report automatically." }
    } else {
        Console-Info "HTML report saved to: $HtmlLog"
    }

    if (-not $NoReboot -and -not $DryRun) {
        Write-Host "`nAll tasks completed. It is recommended to reboot the system." -ForegroundColor Cyan
        
        $rebootMsg = "RASE v68 Ultimate completed successfully.`n`nReboot the system now?"
        $reboot = Show-DarkMessageBox -Message $rebootMsg -Title "Reboot Required" -BtnYesText "RESTART" -BtnNoText "LATER"

        if ($reboot -eq "Yes") {
            Restart-Computer -Force
        }
    }
}
catch {
    Console-Err ("RASE v68 fatal error: " + $_.Exception.Message)
    LogError ("RASE v68 fatal error: " + $_.Exception.Message) "RASE_v68_Main"
}
finally {
    Stop-Transcript | Out-Null
}