<#
.SYNOPSIS
    ROMAN ADAPTIVE STORAGE ENGINE (RASE) v73.6.6 Single-Console Safety Edition.
    Intelligent, adaptive PowerShell monolith for deep storage diagnostics and OS optimization.

.DESCRIPTION
    RASE v73.6.6 is an Enterprise-grade maintenance framework. 
    It features a 6-phase execution pipeline (Initialization -> Profiling -> Diagnostics -> Restoration -> Optimization -> Assessment), comprising ~28 individual operations across those phases.

    Features include:
    [ CORE DIAGNOSTICS & HARDWARE ]
    - Comprehensive System & Hardware Profiling
    - Storage Reliability / SMART-proxy Health Analysis (HDD/SSD)
    - Pre-Flight Checks (WinRE, Pending Reboot, Boot Mode)
    - Composite HealthScore & Extended RiskLevel Computation

    [ DISK & SYSTEM OPTIMIZATION ]
    - Adaptive TRIM (SSD/NVMe) & Smart Defrag (HDD)
    - CHKDSK Scan, DirtyBit & ReFS Integrity Checks
    - System Integrity Auto-Repair (DISM Health & SFC Scannow)
    - NTFS File System Tuning (disable 8.3 names & last access time)
    - VSS Pruning (Oldest Shadow Copy cleanup)

    [ UX & REPORTING ]
    - Interactive Dark GUI Console Prompts (Start & Reboot)
    - Autonomous Enterprise Status Panel ([Console]::Write & RawUI engine)
    - Complete Execution Logging & Error Capture
    
    Project Conceived by: ROMAN POTRIMBA
    Code Engineered by: Copilot, Gemini, ChatGPT & Claude

.NOTES
    v73.6.6 - Windows Update cleanup accounting fix.
      - A Windows Update cache cleanup run with failed removals and zero successful deletions is
        now reported as Warning instead of incorrectly being reported as OK/"nothing removable".
      - Cleanup:WU operation status, HTML reporting, recommendations and exit-code aggregation
        now remain consistent with the actual removal failures.
      - No changes to elevation, single-console behavior, reboot handling, Restore Point logic,
        CHKDSK, DISM, SFC, TRIM, VSS, NTFS tuning, disk scoring or the maintenance pipeline.

    v73.6.6 - Single-Console Safety Edition.
      - Interactive runs no longer self-elevate into a second PowerShell window.
        RASE now requires the current console to already be elevated and stops cleanly
        with an actionable message when Administrator privileges are missing.
      - The legacy -NoElevate switch is retained for command-line compatibility but no
        longer launches a second process; it has no effect in the elevated path.
      - Full interactive runs retain the existing dark START confirmation and the
        existing RESTART/LATER reboot dialog. -NoReboot remains the absolute reboot veto.
      - After the reboot dialog, choosing LATER leaves the same console open and shows
        a final completion block; the operator must press Enter to close the session.
        This keeps the full run visible instead of allowing the console to disappear.
      - Headless/Silent execution remains non-blocking and does not wait for input.
      - No maintenance engine, phase pipeline, scoring, report schema, or exit-code logic
        changes are introduced by this UX/safety revision.

    v73.6.4 - correction to the v73.6.3 micro-fix.
      - Enable-ComputerRestore is best-effort again. v73.6.3 gave it -ErrorAction Stop, which
        made a failed preparation step abort the checkpoint it was preparing for: where System
        Protection is already on but the enable call errors anyway, Checkpoint-Computer was
        never attempted even though it could have succeeded. The enable failure is now recorded
        and reported as context only if the checkpoint also fails.
      - $systemDrive and $enableError declared before the try, so the catch block can read them
        under Set-StrictMode -Version Latest regardless of where the failure occurred.
      - Changelog corrected: v73.6.3 was applied twice as a heading, which renamed the v73.6.2
        entry and left the file with two v73.6.3 sections and no v73.6.2. Its own heading also
        read "after v73.6.3 audit" rather than v73.6.2.

    v73.6.3 - micro-fix after the v73.6.2 audit.
      - Restore Point creation now targets the actual Windows system volume from $env:SystemDrive
        instead of assuming C:, with strict validation before Enable-ComputerRestore.
      - Physical-disk UniqueId matching now uses an explicit non-empty string check instead of
        PowerShell truthiness, avoiding ambiguous empty identifiers.
      - No changes to the maintenance engine, phase pipeline, scoring, Safety Gate scope,
        diagnostics, optimization actions or exit-code architecture.

    v73.6.2 - correction to the v73.6.1 SFC precedence.
      - SFC reports Repaired again when the exit code is 0 AND CBS.log shows repair activity in
        the run window. v73.6.1 collapsed that case into OK, which made [HealthStatus]::Repaired
        unreachable for SFC: a machine whose system files had to be repaired scored identically
        to one where nothing was ever wrong, and the 5-point System Integrity penalty that
        Repaired carries was never applied. The v73.6.1 ordering is otherwise kept - the exit
        code is still evaluated before CBS evidence in every ambiguous case.
      - CBS timestamps are whitespace-normalised before TryParseExact, so a line padded with more
        than one space between date and time is not counted as an unparseable record.
      - Changelog restructured: v73.6.1 replaced the v73.6 heading in place, which left the v73.6
        entry with no heading of its own and its opening sentence merged into v73.6.1's.

    v73.6.1 - Safety & Evidence Pass. Hardens the v73.6 Event Viewer, SFC evidence handling and
    Safety Gate messaging.
      - Event Viewer readability probe now uses Get-WinEvent -ListLog System instead of requiring
        at least one event. An empty-but-readable System log is no longer misclassified as unreadable.
        A disabled System log is reported explicitly and does not manufacture zero-event health data.
      - CBS.log timestamp filtering now parses timestamps into DateTime values with invariant formats
        instead of comparing timestamp strings. Unparseable CBS records are ignored rather than used
        to make a time-window decision.
      - SFC evidence precedence is hardened: an explicit unrepairable CBS finding is fatal; otherwise
        the SFC process exit code is evaluated before a generic repaired-file token can promote the run.
        A repaired-file token can only produce Repaired when the process did not report an unresolved
        execution result.
      - Safety Gate guidance no longer assumes Windows is installed on C:. It identifies the actual
        Windows system volume dynamically in the recommendation text.

    v73.6 - final pass before publication. Closes every open item from the v73.5.x reviews
    and the first runtime QuickScan; no change to the maintenance engine, the phase pipeline,
    the scoring rules or the exit-code logic.
      - WinRE now raises a recommendation. Previously a disabled recovery environment cost 8
        points of Maintenance Readiness and one summary line but never reached Recommended
        Actions, and an undetermined state reached neither.
      - Dirty-bit volumes whose state could not be resolved are reported in a single
        recommendation instead of one per volume, and the unreachable per-row catch (the CIM
        query moved out of the loop in v73.5.1) no longer claims a Failed status it can never
        set.
      - Event Viewer probes the System log once before reporting. Get-WinEvent raises a
        non-terminating error when nothing matches and -ErrorAction SilentlyContinue swallows
        it, so a clean 30-day history and an unreadable log were both arriving as zero.
      - ReFS timeout moved from a hardcoded 900 into Timeouts.REFS, so it is overridable in
        RASE.config.psd1 and range-validated like every other timeout.
      - JSON export records Mode, ApplyNtfsTuning and ApplyVssPruning. The artifact previously
        could not state which mode produced it; the mode had to be inferred from the number of
        phases in PhaseStatus.
      - Version string unified across .SYNOPSIS, .DESCRIPTION, the MONOLITH banner and
        $Global:RaseVersion.

    v73.5.1 - final locale-neutral safety pass: the source file is pure ASCII and contains no
    Russian or other localized detection strings. Locale-sensitive command text is never used
    as the primary decision source.
      - WinRE state is read from System32\Recovery\ReAgent.xml (fixed element and attribute
        names on every locale) instead of matching translated "reagentc /info" prose. The
        reagentc probe remains as a fallback, matched on the locale-invariant
        \\?\GLOBALROOT device path. Localized status words are never parsed.
      - The dism.exe fallback path no longer carries one translation of "no corruption
        detected" per language. It recognises the English verdicts, and on any other locale
        reports Warning with an explanation instead of assuming corruption and launching a
        full RestoreHealth on no evidence.
      - Dirty Bit detection now uses Win32_Volume.DirtyBitSet as the structured primary source;
        fsutil dirty output and undocumented exit-code semantics are no longer used for state.
      - NTFS fsutil fallback no longer parses generic English prose; an unresolved value is
        reported as Unknown rather than inferred from localized text.
      - WinRE reagentc fallback no longer parses English status words; only the invariant
        GLOBALROOT device path is accepted when the XML source is unavailable.
      - Degree sign written as the HTML entity &deg;; all em dashes replaced with hyphens.
        The file no longer contains a single byte above 0x7F, which means a missing UTF-8
        BOM can no longer corrupt it.
      - No change to the maintenance engine, the phase pipeline, the scoring rules or the
        exit-code logic.

    v73.4.2 - hardening after the first runtime QuickScan.
      - PendingFileRenameOperations read through a property-existence check, so a provider
        read failure cannot manufacture a pending reboot.
      - Separate $Global:Timeout_REFS instead of borrowing the DISM timeout.
      - ReFS scan failure and Windows Update cache cleanup failure each raise a Priority 1
        recommendation, using Sources that match their operation names.
      - "Last Boot Time" relabelled "Boot Duration" - the value is how long the last boot
        took, not when it happened.

    v73.4 - corrections to the v73.3 Safety Pass.
      Production candidate hardening:
      - AutoReboot now checks both real failures and incomplete phases explicitly, matching
        the safety comment and preventing future phase-level skip paths from being overlooked.
      - Interactive reboot wording distinguishes failure/incomplete runs from clean completion.

      - Restore point timestamps are converted from WMI DMTF format before comparison.
        Get-ComputerRestorePoint returns CreationTime as a string like "20260808153000.000000-000";
        casting that with [datetime] throws, so under $ErrorActionPreference = "Stop" the
        "existing recent restore point" lookup always came back empty and the Safety Gate
        blocked far more than intended.
      - Safety Gate narrowed to the operations a System Restore point can actually roll back:
        NTFS behaviour tuning (registry) and VSS shadow-copy deletion (irreversible). Cleanup,
        TRIM and Defrag are no longer gated - restore points do not cover user files or volume
        layout, and both already refuse to run on a volume marked DIRTY/Errors/TimedOut.
      - Gate moved inside those two functions, after their read-only assessment, so the
        detect-only NTFS report and the VSS shadow-copy inventory still reach the report when
        no rollback point exists.
      - Gate recommendation is emitted once per operation instead of once per disk task.
      - "SafetyGate" added to the Source-to-Phase map; its findings were invisible in the
        Issues Logged column.
      - "SMART Data Unavailable" rule restored with a default penalty of 0. v73.3 deleted the
        rule and zeroed the weight, which left Weights.SMARTUnavailable as a config key that
        silently does nothing and made an unverifiable disk report FinalStatus "OK".

    v73.3 - Hardened Safety Pass on v73.2.
      - CHKDSK non-zero scan results are now tracked as Failed consistently with the
        operation registry, disk row status, and exit-code engine.
      - Physical-disk matching no longer treats two null UniqueIds as a match; UniqueId
        comparison is used only when both identifiers are present, otherwise Disk Number
        is authoritative.
      - Storage Reliability / SMART-proxy unavailability no longer reduces physical
        health score; telemetry availability remains a separate Priority-3 recommendation.
      - Restore Point protection is now a real safety gate for higher-risk Full-mode writes.
        A recent existing restore point within 24h counts as usable protection.
      - If Full mode has no usable recent restore point, cleanup, TRIM, Defrag, VSS pruning,
        and NTFS tuning are skipped rather than making higher-risk writes without rollback.
      - DryRun/QuickScan behavior remains non-blocking and read-only.

      v73.2 - audit follow-up on v73.1.
      - Invoke-AnimatedTask captures the child exit code before cleanup and disposes the
        Process object; a full run started ~28 processes and released none of their handles
      - DiskRules now penalises DefragStatus "TimedOut", not only "Failed". A timed-out defrag
        already forced exit code 2 but left the disk score and FinalStatus untouched
      - Volume rows are matched with -eq "<letter>:" instead of the regex -match <letter>
      - Invoke-RaseBackgroundJob clamps a missing/zero timeout instead of treating it as an
        instant timeout (Wait-Job -Timeout 0 returns immediately)
      - Banner credit line matched to the header block (the two had drifted apart)
      - v73.1 changelog corrected - see below

    v73.1 - validation pass on v73.0.
      - Phase-level Skipped separated from Failed in the exit-code engine and in the report
        wording. NOTE: a phase is only ever marked Skipped by Invoke-RasePhase when one of its
        dependencies failed, so in practice a Skipped phase is always accompanied by a Failed
        one and the run still exits 2. The separation is defensive, not a behaviour change, and
        there is currently no "intentional skip" path at phase level - QuickScan simply builds
        a shorter pipeline instead of skipping phases.
      - Cascaded "phase skipped because X failed" recommendations dropped to Priority 2 so the
        root-cause Priority 1 entry from the failing phase stays at the top of the list.
      - ReFS integrity moved onto the shared Invoke-RaseBackgroundJob wrapper (which gained
        -ArgumentList), so it inherits the same timeout and cleanup handling as DISM.
      - Background-job cleanup guaranteed through try/finally.
      - Obsolete "Ultimate" branding removed from UI/title strings.

    v73.0 - audit follow-up on v72.0. Changes owned by this revision:
      - Set-RaseOperationStatus now escalates only (OK < Skipped < Repaired < Warning < Failed),
        so a later volume in the same loop can no longer downgrade an earlier Failed
      - Restore Point "Warning" state re-connected to the Maintenance Readiness penalty
        (the v72 rename left that branch unreachable)
      - Restore Point recommendation Source renamed to "SystemRestorePoint" so the phase
        issue table stops counting one finding twice
      - Event Viewer Disk/NTFS counts split into Error (Level 2) and Warning (Level 3);
        only errors raise a recommendation. BSOD/bugcheck events now raise one too
      - NTFS Last Access tuning preserves the management mode (sets value -bor 1, so
        system-managed stays system-managed) instead of forcing user-managed 1
      - NTFS 8.3 target is configurable (Ntfs.EightDotThreeTarget, default 3 = disabled on
        all volumes except the system volume) and never loosens a stricter existing setting
      - $profile renamed to $hwProfile (it shadowed a PowerShell automatic variable)

    v72.0 - hardening pass on v71.0:
      - SMART terminology corrected to "Storage Reliability / SMART-proxy"
      - Initialize-HtmlReport and Get-HardwareProfile survive unavailable WMI/CIM classes
      - DISM result-shape guards; unusable result reported as Warning instead of throwing
      - Temp cleanup only removes directories left empty by the file pass
      - Event Viewer Disk/NTFS findings surfaced as recommendations
      - WHEA re-sourced to a new "Hardware" phase-map key
      - Last Access state expanded to the documented four values
      - VSS deletion failure raised from Warning to Failed

    v71.0 - consolidation of the v70.5 (Claude) and v70.8/70.9 (Lira) branches.
    Kept from the 70.8/70.9 branch:
      - Unified operation-status registry (Set-RaseOperationStatus) + Warning-level exit code
      - Per-volume VSS storage accounting instead of a system-wide figure
      - Capability-aware optimization plan (NTFS/ReFS filtering, media-aware actions)
      - Honest QuickScan scoring (System Integrity reported as N/A, not 100%)
      - Windows Update cache cleanup with guaranteed service-state restoration (finally)
      - AutoReboot blocked after a failed/incomplete pipeline
      - NTFS 8dot3 / LastAccess treated as multi-valued settings with a post-change verify
    Corrected in v71.0:
      - Assessment no longer depends on the other phases: the report is always written
      - Restoration depends on Profiling again, not Diagnostics
      - Storage Health reports N/A instead of a false 100% when no volumes were profiled
      - NTFS/8dot3 detection is registry-first (locale-independent), fsutil is the fallback
      - $matches automatic-variable collision removed from the fsutil parser
      - Get-RaseNtfs8Dot3State takes [Nullable[int]] so "Unknown" can actually be returned
      - Single shared Source-to-Phase map (the two copies had drifted apart)
      - DISM/SFC statuses mirrored into the operation registry
      - ConvertTo-RaseVolumeId hoisted to script scope
      - Report filenames derive from $Global:RaseVersion
#>
# ============================================================
# ROMAN ADAPTIVE STORAGE ENGINE (RASE) v73.6.6 MONOLITH
# ============================================================

param([switch]$DryRun, [switch]$NoReboot, [switch]$FullReport, [switch]$NoElevate, [switch]$Silent, [switch]$AutoReboot, [ValidateSet("Full", "QuickScan")][string]$Mode = "Full", [switch]$ApplyNtfsTuning, [switch]$ApplyVssPruning)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
# Single source of truth for the version identifier - used everywhere it's reported (banner,
# HTML header, JSON export, console messages) instead of a hardcoded "v70" scattered across
# the file, so the number shown always matches what actually shipped.
$Global:RaseVersion = "73.6.6"
[Console]::Title = "ROMAN ADAPTIVE STORAGE ENGINE v$($Global:RaseVersion)"

# ----------------------------
# Elevation Gate (must run before ANY other action)
# ----------------------------
function Test-IsAdministrator {
    $identity  = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-ElevationGate {
    if (Test-IsAdministrator) { return $true }

    # Single-console safety policy:
    # Do NOT relaunch PowerShell with -Verb RunAs. That creates a second console and
    # makes the original process disappear while the elevated child continues.
    # The operator must start this script from an elevated PowerShell window.
    Write-Host "`n[ERROR] RASE requires Administrator privileges (CHKDSK/DISM/SFC/Restore Point)." -ForegroundColor Red
    Write-Host "        This Single-Console build will NOT open a second PowerShell window." -ForegroundColor Yellow
    if ($NoElevate) {
        Write-Host "        -NoElevate was supplied; no elevation attempt will be made." -ForegroundColor Yellow
    } else {
        Write-Host "        Start PowerShell as Administrator and run RASE again." -ForegroundColor Yellow
    }
    if (-not [Environment]::UserInteractive -or $Silent) {
        return $false
    }
    try {
        Read-Host "        Press Enter to close this RASE session" | Out-Null
    } catch {}
    return $false
}

$Global:IsElevated = Invoke-ElevationGate
if ($Global:IsElevated -eq $false) { exit 1 }

# Headless = explicit -Silent OR no interactive session available (Task Scheduler, remote exec, etc.)
# Either way, GUI dialogs would block forever, so both routes lead to the same non-blocking behavior.
$Global:IsHeadless = $Silent -or (-not [Environment]::UserInteractive)

# --- Enterprise Enums & Execution Context ---
enum HealthStatus { OK; Warning; Repaired; Failed; Skipped }

$Global:Ctx = @{
    Recommendations = @()
    DiskTable       = @()
    Summary_CHKDSK  = 0
    DISM_Status     = [HealthStatus]::Skipped
    SFC_Status      = [HealthStatus]::Skipped
    PendingReboot   = $false
    WinRE_Enabled   = $true
    WinREState      = "Unknown"
    IsAdmin         = $Global:IsElevated
    RestorePointStatus = "Pending"
    PhaseStatus     = [ordered]@{}
    # Unified operation-status registry. The detailed legacy fields (DISM_Status,
    # SFC_Status, per-disk row statuses) remain the source of truth for their own
    # reporting; this registry is the single place the Exit Code Engine and the phase
    # issue table consume operation outcomes from. Declared here - with the rest of the
    # context - rather than as a stray assignment between function definitions.
    OperationStatus = [ordered]@{}
}

# ----------------------------
# Configuration (optional external override via RASE.config.psd1 next to the script)
# ----------------------------
$Global:DefaultConfig = @{
    Weights = @{
        SMART        = 35
        SMARTWarning = 10
        SMARTUnavailable = 0
        FreeSpaceCritical = 15
        FreeSpaceWarning  = 5
        Health       = 20
        Dirty        = 20
        TRIM         = 10
        Defrag       = 5
        Frag         = 10
    }
    Timeouts = @{
        CHKDSK = 7200   # 2h - offline-scale scans on large/failing drives can be slow
        DISM   = 1800   # 30m
        SFC    = 1800   # 30m
        Defrag = 3600   # 1h
        REFS   = 900    # 15m - ReFS Repair-Volume -Scan, independent from the DISM timeout
    }
    Ntfs = @{
        # fsutil "disable8dot3" target used when -ApplyNtfsTuning is passed:
        #   3 = disabled on every volume EXCEPT the system volume (default, conservative)
        #   1 = disabled on every volume including the system volume
        # 3 keeps the compatibility surface that legacy installers and older applications
        # still expect on C:, while removing the short-name write cost from data volumes -
        # which is where the file-creation churn actually happens.
        EightDotThreeTarget = 3
    }
    Thresholds = @{
        FreeSpaceCriticalPercent = 5
        FreeSpaceWarningPercent  = 10
        FragmentationPercent     = 15
        VssMinCopies             = 3
        VssMinUsedGB             = 10
        SmartTempWarningC        = 60
        SmartTempCriticalC       = 70
        SmartWearWarningPercent  = 80
        SmartWearCriticalPercent = 90
        SmartErrorsWarning       = 1
        SmartErrorsCritical      = 11
    }
}

function Merge-RaseConfig {
    param([hashtable]$Base, [hashtable]$Override)
    $result = @{}
    foreach ($group in $Base.Keys) {
        $result[$group] = @{}
        foreach ($key in $Base[$group].Keys) { $result[$group][$key] = $Base[$group][$key] }
        if ($Override.ContainsKey($group) -and $Override[$group] -is [hashtable]) {
            foreach ($key in $Override[$group].Keys) {
                if ($result[$group].ContainsKey($key)) { $result[$group][$key] = $Override[$group][$key] }
            }
        }
    }
    return $result
}

# Sanity-checks a merged config before it's trusted. A syntactically valid RASE.config.psd1
# can still contain nonsense (negative weights, a zero timeout, a critical threshold set
# looser than its own warning threshold) - none of that would fail to parse, so it needs an
# explicit check rather than relying on Import-PowerShellDataFile's try/catch alone.
function Test-RaseConfigValid {
    param([hashtable]$Config)
    $problems = @()
    foreach ($key in $Config.Weights.Keys) {
        $v = $Config.Weights[$key]
        if ($v -isnot [int] -and $v -isnot [double]) { $problems += "Weights.$key is not numeric" }
        elseif ($v -lt 0 -or $v -gt 100) { $problems += "Weights.$key ($v) must be between 0 and 100" }
    }
    foreach ($key in $Config.Timeouts.Keys) {
        $v = $Config.Timeouts[$key]
        if ($v -isnot [int] -and $v -isnot [double]) { $problems += "Timeouts.$key is not numeric" }
        elseif ($v -le 0) { $problems += "Timeouts.$key ($v) must be greater than 0" }
    }
    if ($Config.ContainsKey("Ntfs")) {
        $target8 = $Config.Ntfs.EightDotThreeTarget
        if ($target8 -notin @(1,3)) { $problems += "Ntfs.EightDotThreeTarget ($target8) must be 1 or 3" }
    }

    $t = $Config.Thresholds
    foreach ($key in @("FreeSpaceCriticalPercent","FreeSpaceWarningPercent","FragmentationPercent","SmartWearWarningPercent","SmartWearCriticalPercent")) {
        $v = $t[$key]
        if ($v -isnot [int] -and $v -isnot [double]) { $problems += "Thresholds.$key is not numeric" }
        elseif ($v -lt 0 -or $v -gt 100) { $problems += "Thresholds.$key ($v) must be between 0 and 100" }
    }
    foreach ($key in @("VssMinCopies","VssMinUsedGB","SmartErrorsWarning","SmartErrorsCritical","SmartTempWarningC","SmartTempCriticalC")) {
        $v = $t[$key]
        if ($v -isnot [int] -and $v -isnot [double]) { $problems += "Thresholds.$key is not numeric" }
        elseif ($v -lt 0) { $problems += "Thresholds.$key ($v) must not be negative" }
    }
    if ($t.FreeSpaceCriticalPercent -gt $t.FreeSpaceWarningPercent) { $problems += "Thresholds.FreeSpaceCriticalPercent must be <= FreeSpaceWarningPercent" }
    if ($t.SmartTempWarningC -gt $t.SmartTempCriticalC) { $problems += "Thresholds.SmartTempWarningC must be <= SmartTempCriticalC" }
    if ($t.SmartWearWarningPercent -gt $t.SmartWearCriticalPercent) { $problems += "Thresholds.SmartWearWarningPercent must be <= SmartWearCriticalPercent" }
    if ($t.SmartErrorsWarning -gt $t.SmartErrorsCritical) { $problems += "Thresholds.SmartErrorsWarning must be <= SmartErrorsCritical" }
    return $problems
}

$Global:ConfigPath = Join-Path (Split-Path -Parent $PSCommandPath) "RASE.config.psd1"
if (Test-Path $Global:ConfigPath) {
    try {
        $userConfig = Import-PowerShellDataFile -Path $Global:ConfigPath
        $merged = Merge-RaseConfig -Base $Global:DefaultConfig -Override $userConfig
        $configProblems = Test-RaseConfigValid -Config $merged
        if ($configProblems.Count -gt 0) {
            Write-Host "[WARN] RASE.config.psd1 has invalid values - using built-in defaults instead:" -ForegroundColor Yellow
            foreach ($p in $configProblems) { Write-Host "  - $p" -ForegroundColor Yellow }
            $Global:Config = $Global:DefaultConfig
        } else {
            $Global:Config = $merged
            Write-Host "[INFO] Loaded external config: $($Global:ConfigPath)" -ForegroundColor Cyan
        }
    } catch {
        Write-Host "[WARN] Failed to parse RASE.config.psd1 ($($_.Exception.Message)) - using built-in defaults." -ForegroundColor Yellow
        $Global:Config = $Global:DefaultConfig
    }
} else {
    $Global:Config = $Global:DefaultConfig
}

$Global:Weight_SMART        = $Global:Config.Weights.SMART
$Global:Weight_SMARTWarning = $Global:Config.Weights.SMARTWarning
$Global:Weight_SMARTUnavailable = $Global:Config.Weights.SMARTUnavailable
$Global:Weight_FreeSpaceCritical = $Global:Config.Weights.FreeSpaceCritical
$Global:Weight_FreeSpaceWarning  = $Global:Config.Weights.FreeSpaceWarning
$Global:Weight_Health = $Global:Config.Weights.Health
$Global:Weight_Dirty  = $Global:Config.Weights.Dirty
$Global:Weight_TRIM   = $Global:Config.Weights.TRIM
$Global:Weight_Defrag = $Global:Config.Weights.Defrag
$Global:Weight_Frag   = $Global:Config.Weights.Frag

$Global:Timeout_CHKDSK = $Global:Config.Timeouts.CHKDSK
$Global:Timeout_DISM   = $Global:Config.Timeouts.DISM
# Sourced from config like every other timeout. Test-RaseConfigValid iterates
# $Config.Timeouts.Keys, so this key is range-validated automatically - a hardcoded value
# was the only timeout a user could not tune from RASE.config.psd1.
$Global:Timeout_REFS   = $Global:Config.Timeouts.REFS
$Global:Timeout_SFC    = $Global:Config.Timeouts.SFC
$Global:Timeout_Defrag = $Global:Config.Timeouts.Defrag

$Global:Threshold_FreeSpaceCritical = $Global:Config.Thresholds.FreeSpaceCriticalPercent
$Global:Threshold_FreeSpaceWarning  = $Global:Config.Thresholds.FreeSpaceWarningPercent
$Global:Threshold_Frag              = $Global:Config.Thresholds.FragmentationPercent
$Global:Threshold_VssMinCopies      = $Global:Config.Thresholds.VssMinCopies
$Global:Threshold_VssMinUsedGB      = $Global:Config.Thresholds.VssMinUsedGB
$Global:Threshold_SmartTempWarning  = $Global:Config.Thresholds.SmartTempWarningC
$Global:Threshold_SmartTempCritical = $Global:Config.Thresholds.SmartTempCriticalC
$Global:Threshold_SmartWearWarning  = $Global:Config.Thresholds.SmartWearWarningPercent
$Global:Threshold_SmartWearCritical = $Global:Config.Thresholds.SmartWearCriticalPercent
$Global:Threshold_SmartErrorsWarning  = $Global:Config.Thresholds.SmartErrorsWarning
$Global:Threshold_SmartErrorsCritical = $Global:Config.Thresholds.SmartErrorsCritical

$Global:Ntfs8Dot3Target = $Global:Config.Ntfs.EightDotThreeTarget

# ----------------------------
# Disk Rule Matrix - single source of truth for per-disk HealthScore penalties.
# Both Compute-HealthScore (scoring) and Finalize-ExecutionSummary (penalty
# breakdown display) read this same list, so a new rule only needs one entry
# here instead of being kept in sync in two places.
# ----------------------------
$Global:DiskRules = @(
    @{ Name = "Dirty Volume / FS Errors"; Penalty = $Global:Weight_Dirty;        Severity = "Critical"; Condition = { param($Disk) $Disk.Status -in @("DIRTY", "Errors", "TimedOut") } }
    @{ Name = "Unhealthy Volume";         Penalty = $Global:Weight_Health;       Severity = "Critical"; Condition = { param($Disk) $Disk.Health -eq "Unhealthy" } }
    @{ Name = "SMART Critical";           Penalty = $Global:Weight_SMART;        Severity = "Critical"; Condition = { param($Disk) $Disk.SmartRaw -eq "Failed" } }
    @{ Name = "SMART Warning";            Penalty = $Global:Weight_SMARTWarning; Severity = "Warning";  Condition = { param($Disk) $Disk.SmartRaw -eq "Warning" } }
    # Penalty defaults to 0: missing telemetry is not evidence of a failing drive, so it must
    # not lower the score. The rule itself is kept so the disk is still flagged Warning rather
    # than reported as a verified "OK" - RASE could not check it - and so that
    # Weights.SMARTUnavailable stays a config key that actually does something for anyone who
    # does want unverifiable drives scored down.
    @{ Name = "SMART Data Unavailable";   Penalty = $Global:Weight_SMARTUnavailable; Severity = "Warning"; Condition = { param($Disk) $Disk.SmartRaw -in @("Unavailable", "Error") } }
    @{ Name = "TRIM Failed";              Penalty = $Global:Weight_TRIM;         Severity = "Warning";  Condition = { param($Disk) $Disk.TrimStatus -eq "Failed" } }
    # "TimedOut" is included deliberately: Test-RaseAnyOperationFailed already treats a timed-out
    # defrag as a failure for the exit code, so leaving it out here meant the disk score and the
    # FinalStatus column disagreed with the exit code the same run produced.
    @{ Name = "Defrag Failed";            Penalty = $Global:Weight_Defrag;       Severity = "Warning";  Condition = { param($Disk) $Disk.DefragStatus -in @("Failed", "TimedOut") } }
    @{ Name = "High Fragmentation";       Penalty = $Global:Weight_Frag;         Severity = "Warning";  Condition = { param($Disk) $Disk.FragLevel -ge $Global:Threshold_Frag } }
    @{ Name = "Critical Free Space";      Penalty = $Global:Weight_FreeSpaceCritical; Severity = "Critical"; Condition = { param($Disk) $Disk.PercentFree -lt $Global:Threshold_FreeSpaceCritical } }
    @{ Name = "Low Free Space";           Penalty = $Global:Weight_FreeSpaceWarning;  Severity = "Warning";  Condition = { param($Disk) $Disk.PercentFree -ge $Global:Threshold_FreeSpaceCritical -and $Disk.PercentFree -lt $Global:Threshold_FreeSpaceWarning } }
)

# ----------------------------
# GUI & Console Engine 
# ----------------------------

function Show-ConsoleBanner {
    if ($Silent) { return }
    Write-Host "`n============================================================" -ForegroundColor Cyan
    Write-Host "  ROMAN ADAPTIVE STORAGE ENGINE (RASE) v$($Global:RaseVersion)" -ForegroundColor White
    Write-Host "               `"Reliability begins with maintenance!`"" -ForegroundColor White
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "`nProject Conceived by : ROMAN POTRIMBA" -ForegroundColor White
    # Kept identical to the credit line in the header comment block - the two had drifted
    # into naming different assistants, which is confusing in a project that is reviewed by
    # several of them in rotation. Edit both together if the canonical list changes.
    Write-Host "Code Engineered by   : Copilot, Gemini, ChatGPT & Claude" -ForegroundColor White
    Write-Host "Technology           : 100% Native Windows Microprograms" -ForegroundColor White
    Write-Host "Purpose              : Adaptive Windows Storage, OS Optimization & Health" -ForegroundColor White
    
    Write-Host "`nThis adaptive optimizer performs a full diagnostic and maintenance cycle." -ForegroundColor Gray
    Write-Host "It includes hardware scanning, Storage Reliability / SMART-proxy diagnostics, NVMe analysis," -ForegroundColor Gray
    Write-Host "TRIM, smart defrag, CHKDSK, DISM, SFC, ReFS integrity, and deep cleanup." -ForegroundColor Gray
    
    Write-Host "`nDepending on your system configuration, the full process may take" -ForegroundColor Yellow
    Write-Host "between 1 to 6 hours. It is strongly recommended NOT to use the PC.`n" -ForegroundColor Yellow
}

function Show-DarkMessageBox {
    param([string]$Message, [string]$Title, [string]$BtnYesText = "YES", [string]$BtnNoText = "NO", [bool]$IsStartDialog = $false)
    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        Add-Type -AssemblyName System.Drawing -ErrorAction Stop
        $form = New-Object System.Windows.Forms.Form
        $form.Text = $Title
        $form.Size = if ($IsStartDialog) { New-Object System.Drawing.Size(580, 275) } else { New-Object System.Drawing.Size(500, 220) }
        $form.StartPosition = "CenterScreen"
        $form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
        $form.ForeColor = [System.Drawing.Color]::White
        $form.FormBorderStyle = "FixedDialog"
        $form.MaximizeBox = $false; $form.MinimizeBox = $false; $form.TopMost = $true

        $label = New-Object System.Windows.Forms.Label
        $label.Text = $Message; $label.AutoSize = $false; $label.Dock = "Top"
        $label.Height = if ($IsStartDialog) { 150 } else { 100 }
        $label.TextAlign = "MiddleCenter"
        $label.Font = New-Object System.Drawing.Font("Consolas", 10)
        $label.ForeColor = [System.Drawing.Color]::Cyan

        $btnYLocX = if ($IsStartDialog) { 140 } else { 110 }
        $btnNLocX = if ($IsStartDialog) { 300 } else { 250 }
        $btnLocY  = if ($IsStartDialog) { 175 } else { 115 }

        $btnYes = New-Object System.Windows.Forms.Button
        $btnYes.Text = $BtnYesText; $btnYes.Size = New-Object System.Drawing.Size(120, 40)
        $btnYes.Location = New-Object System.Drawing.Point($btnYLocX, $btnLocY)
        $btnYes.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
        $btnYes.FlatStyle = "Flat"; $btnYes.FlatAppearance.BorderColor = [System.Drawing.Color]::Cyan
        $btnYes.Font = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Bold)
        $btnYes.DialogResult = "Yes"

        $btnNo = New-Object System.Windows.Forms.Button
        $btnNo.Text = $BtnNoText; $btnNo.Size = New-Object System.Drawing.Size(120, 40)
        $btnNo.Location = New-Object System.Drawing.Point($btnNLocX, $btnLocY)
        $btnNo.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
        $btnNo.FlatStyle = "Flat"; $btnNo.FlatAppearance.BorderColor = [System.Drawing.Color]::Red
        $btnNo.ForeColor = [System.Drawing.Color]::LightCoral
        $btnNo.Font = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Bold)
        $btnNo.DialogResult = "No"

        $form.Controls.Add($label); $form.Controls.Add($btnYes); $form.Controls.Add($btnNo)
        $result = $form.ShowDialog(); $form.Dispose()
        return $result
    } catch {
        Write-Host "`n=== $Title ===" -ForegroundColor Cyan
        Write-Host $Message -ForegroundColor White
        $ans = Read-Host "`n[$BtnYesText] (Y) / [$BtnNoText] (N)"
        if ($ans -match "^y|^Y") { return "Yes" } else { return "No" }
    }
}

function Section($title) {
    if ($Silent) { return }
    Write-Host "`n============================================================" -ForegroundColor DarkCyan
    Write-Host " $title" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor DarkCyan
}
function Console-Step($msg) { if (-not $Silent) { Write-Host "[STEP]  $msg" -ForegroundColor Cyan } }
function Console-OK($msg)   { if (-not $Silent) { Write-Host "[ OK ]  $msg" -ForegroundColor Green } }
function Console-Warn($msg) { if (-not $Silent) { Write-Host "[WARN]  $msg" -ForegroundColor Yellow } }
function Console-Err($msg)  { if (-not $Silent) { Write-Host "[FAIL]  $msg" -ForegroundColor Red } }

# ----------------------------
# Autonomous Enterprise Status Panel 
# ----------------------------
function Invoke-AnimatedTask {
    param([string]$Activity, [string]$Command, [string]$Arguments, [switch]$CaptureOutput, [int]$TimeoutSeconds = 0)
    $Global:RaseLastTaskTimedOut = $false
    $tempFile = "$env:TEMP\rase_task_out_$($PID).txt"
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "cmd.exe"
    if ($CaptureOutput) { $psi.Arguments = "/c $Command $Arguments > `"$tempFile`" 2>&1" } 
    else { $psi.Arguments = "/c $Command $Arguments > NUL 2>&1" }
    $psi.RedirectStandardOutput = $false; $psi.RedirectStandardError = $false
    $psi.UseShellExecute = $false; $psi.CreateNoWindow = $true
    
    # 1. BeginPanel: Draw strict layout - skipped entirely under -Silent, which promises
    # "no console chatter" (logs/HTML/JSON/CSV still capture everything regardless).
    if (-not $Silent) {
        Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray
        Write-Host " PROCESS: $Activity" -ForegroundColor White
        Write-Host " STATUS:  Starting..." -ForegroundColor DarkCyan
        Write-Host "------------------------------------------------------------" -ForegroundColor DarkGray
    }
    
    $process = [System.Diagnostics.Process]::Start($psi)
    $capturedExitCode = -1
    $width = 25; $pos = 0; $dir = 1
    $rawUI = $Host.UI.RawUI
    $statusY = -1
    $startTime = Get-Date
    
    try {
        if (-not $Silent) { try { [Console]::CursorVisible = $false } catch {} }
        # 2. UpdatePanel: Autonomous Loop - the wait/timeout logic always runs; only the
        # on-screen drawing is conditional on -Silent.
        while (-not $process.HasExited) {
            if ($TimeoutSeconds -gt 0 -and ((Get-Date) - $startTime).TotalSeconds -ge $TimeoutSeconds) {
                $Global:RaseLastTaskTimedOut = $true
                try { Start-Process -FilePath "taskkill.exe" -ArgumentList "/PID $($process.Id) /T /F" -WindowStyle Hidden -Wait -ErrorAction SilentlyContinue } catch {}
                # taskkill returns as soon as the kill is issued, not when the tree is gone.
                # Waiting briefly here keeps the child from lingering as a zombie while RASE
                # continues into the next operation.
                try { $process.WaitForExit(5000) | Out-Null } catch {}
                break
            }
            if (-not $Silent) {
                # In a non-interactive/headless host, $rawUI.CursorPosition and the console-drawing
                # calls below can throw (there may be no real console buffer at all under Task
                # Scheduler). None of this is essential to the actual diagnostic work, so any
                # failure here is swallowed rather than allowed to abort the whole task/phase.
                try {
                    $currentY = $rawUI.CursorPosition.Y
                    
                    # Auto-Recovery from window minimize or resize
                    if ($statusY -lt 0 -or $statusY -ge $rawUI.BufferSize.Height -or [Math]::Abs($currentY - $statusY) -gt 4) {
                        $statusY = [Math]::Max(0, $currentY - 2)
                    }
                    
                    $left = "=" * $pos; $right = " " * ($width - $pos - 1)
                    $titleSuffix = if ($TimeoutSeconds -gt 0) { " (timeout in {0}s)" -f [int]($TimeoutSeconds - ((Get-Date) - $startTime).TotalSeconds) } else { "" }
                    [Console]::Title = "RASE v$($Global:RaseVersion) | $Activity [$left>$right]$titleSuffix"
                    
                    # Direct API render (No \r, No Write-Host wrapping)
                    [Console]::SetCursorPosition(0, $statusY)
                    [Console]::ForegroundColor = [ConsoleColor]::DarkCyan
                    [Console]::Write((" STATUS:  [{0}] Executing...   " -f ($left+">"+$right)))
                } catch {}
                
                $pos += $dir
                if ($pos -eq ($width - 1) -or $pos -eq 0) { $dir *= -1 }
            }
            Start-Sleep -Milliseconds 80
        }
        
        # 3. EndPanel: Final State
        if (-not $Silent) {
            try { 
                if ($statusY -lt 0) { $statusY = [Math]::Max(0, $rawUI.CursorPosition.Y - 2) }
                [Console]::SetCursorPosition(0, $statusY)
                if ($Global:RaseLastTaskTimedOut) {
                    [Console]::ForegroundColor = [ConsoleColor]::Red
                    [Console]::Write(" STATUS:  [!!!!!!!!!!!!!!!!!!!!!!!!!] TIMED OUT     ")
                } else {
                    [Console]::ForegroundColor = [ConsoleColor]::Green
                    [Console]::Write(" STATUS:  [=========================] COMPLETED      ")
                }
                
                $parkY = [Math]::Min($statusY + 2, $rawUI.BufferSize.Height - 1)
                [Console]::SetCursorPosition(0, $parkY)
            } catch {}
        }
        
        # The exit code is read here, inside the try, because the finally block below disposes
        # the Process object and reading .ExitCode from a disposed Process throws.
        if (-not $Global:RaseLastTaskTimedOut) {
            try { $process.WaitForExit(); $capturedExitCode = $process.ExitCode } catch { $capturedExitCode = -1 }
        }
    } finally {
        if (-not $Silent) {
            try { [Console]::ResetColor() } catch {}
            try { [Console]::CursorVisible = $true } catch {}
            try { [Console]::Title = "ROMAN ADAPTIVE STORAGE ENGINE v$($Global:RaseVersion)" } catch {}
        }
        # System.Diagnostics.Process holds a native handle until it is disposed. A full run
        # starts roughly 28 of these and previously released none of them, inside a process
        # that is expected to stay alive for hours on a large CHKDSK/Defrag cycle.
        try { if ($null -ne $process) { $process.Dispose() } } catch {}
    }
    
    if ($Global:RaseLastTaskTimedOut) {
        $Global:LASTEXITCODE = -1
        Console-Err "$Activity exceeded the ${TimeoutSeconds}s timeout and was terminated."
    } else {
        $Global:LASTEXITCODE = $capturedExitCode
    }
    if ($CaptureOutput) {
        $out = Get-Content -Path $tempFile -Raw -ErrorAction SilentlyContinue
        Remove-Item -Path $tempFile -Force -ErrorAction SilentlyContinue
        return $out
    }
}

# ----------------------------
# Modules & Framework Helpers
# ----------------------------
function Get-WinREState {
    # ReAgent.xml is the configuration file that reagentc.exe itself reads and writes. Its
    # element names and attribute values are fixed on every Windows installation, which makes
    # it the only fully locale-independent source for this answer. "reagentc /info" prints the
    # same information as prose in the Windows display language, so matching that text means
    # hardcoding one translation per locale and silently returning the wrong answer everywhere
    # else. XML first, reagentc second, and an honest "Unknown" if neither is conclusive.
    try {
        $reagentPath = Join-Path $env:SystemRoot "System32\Recovery\ReAgent.xml"
        if (Test-Path -LiteralPath $reagentPath) {
            [xml]$reagentXml = Get-Content -LiteralPath $reagentPath -Raw -ErrorAction Stop
            $root = $reagentXml.DocumentElement
            if ($null -ne $root -and $root.Name -eq "WindowsRE") {
                # SelectSingleNode/GetAttribute are .NET calls rather than the PowerShell XML
                # adapter, so a missing node or attribute returns null/"" instead of throwing
                # under Set-StrictMode -Version Latest.
                $locationNode = $root.SelectSingleNode("WinreLocation")
                if ($null -ne $locationNode) {
                    $winrePath = [string]$locationNode.GetAttribute("path")
                    # "reagentc /disable" clears this attribute but leaves the node in place,
                    # so an empty path is a positive "Disabled", not a failed read.
                    if (-not [string]::IsNullOrWhiteSpace($winrePath)) { return "Enabled" }
                    return "Disabled"
                }
            }
        }
    } catch {
        # Unreadable or unexpected ReAgent.xml - fall through to the reagentc probe below.
    }

    try {
        $winreInfo = (cmd.exe /c "reagentc /info 2>nul") -join " "
        # The device path is emitted verbatim on every locale. Do not parse localized status words.
        if ($winreInfo -match [regex]::Escape('\\?\GLOBALROOT')) { return "Enabled" }
    } catch {
        # reagentc unavailable or blocked - reported as Unknown below.
    }

    return "Unknown"
}

function Add-Recommendation {
    param([int]$Priority, [string]$Message, [string]$Source = "System")
    $Global:Ctx.Recommendations += [pscustomobject]@{ Priority = $Priority; Message = $Message; Source = $Source }
}

function Add-Penalty {
    param([hashtable]$Table, [string]$Reason, [int]$Points)
    if (-not $Table.ContainsKey($Reason)) { $Table[$Reason] = 0 }
    $Table[$Reason] += $Points
}

# Matches a physical disk (from $SystemProfile.Disks) to its row(s) in $Global:Ctx.DiskTable
# by real device identity (UniqueId, falling back to DeviceId/DiskNumber) - never by
# FriendlyName, since two physically distinct disks can share the same model string.
# One physical disk can back multiple rows (e.g. C: and D: as two volumes on one SSD) -
# all of them are correctly returned, since they genuinely share that disk's SMART data.
function Find-DiskTableRows {
    param([Parameter(Mandatory)]$Disk)
    if (-not [string]::IsNullOrWhiteSpace([string]$Disk.UniqueId)) {
        $matched = @($Global:Ctx.DiskTable | Where-Object { $_.DiskUniqueId -and $_.DiskUniqueId -eq $Disk.UniqueId })
        if ($matched.Count -gt 0) { return $matched }
    }
    if ($null -ne $Disk.DeviceId) {
        return @($Global:Ctx.DiskTable | Where-Object { $null -ne $_.DiskNumber -and $_.DiskNumber -eq $Disk.DeviceId })
    }
    return @()
}

# Single honest gate for every destructive/write action. Callers check the return value
# instead of duplicating "if (-not $DryRun) {...}" and then printing a success message
# unconditionally outside that block - the exact bug this exists to prevent.
function Test-RaseDryRun {
    param([Parameter(Mandatory)][string]$Action)
    if ($DryRun) {
        Console-Warn "DRY-RUN: $Action"
        HtmlAdd "DRY-RUN: $Action - no changes were made." "#D7BA7D"
        return $true
    }
    return $false
}

# Single centralized gate for QuickScan's read-only contract. Every write-capable action in
# a phase shared between Full and QuickScan (currently only Assessment: DNS Flush, VSS
# Pruning, NTFS Tuning) must call this before doing anything - not a scattered
# "if ($Mode -eq 'Full')" at each call site, which is exactly how the NTFS Tuning gap
# happened: one of four spots got missed. Centralizing means a future write action only
# needs to call this once to inherit the same protection, instead of being one more place
# to remember.
function Test-RaseWriteAllowed {
    param([Parameter(Mandatory)][string]$Action)
    if ($Mode -ne "Full") {
        # This is an expected policy decision, not an operational warning/error.
        # QuickScan promises system-state read-only behavior, so a blocked write is
        # a successful safety gate and must not turn the run yellow/red by itself.
        HtmlAdd "QuickScan: $Action skipped - QuickScan is system-state read-only (expected)." "#808080"
        Console-Step "QuickScan: write action skipped by read-only policy - $Action"
        return $false
    }
    return $true
}

# Severity ranking used by Set-RaseOperationStatus. Keyed by name rather than by the enum's
# own numeric values, because the enum is declared in reporting order (OK, Warning, Repaired,
# Failed, Skipped), not in severity order - casting it to [int] would rank Skipped above
# Failed. Skipped sits just above OK: "we deliberately did not run this" is more informative
# than a bare OK, but it is not a finding.
$Global:RaseStatusRank = @{
    "OK"       = 0
    "Skipped"  = 1
    "Repaired" = 2
    "Warning"  = 3
    "Failed"   = 4
}

# Records an operation outcome in $Global:Ctx.OperationStatus.
# Statuses are HealthStatus values: OK / Warning / Repaired / Failed / Skipped. Skipped is non-fatal unless a phase is left incomplete.
#
# Escalation only. Several operations (CHKDSK, TRIM, Defrag, VSS, ReFS) call this once per
# volume inside a loop whose iteration order is not defined, and a plain assignment meant the
# LAST volume won: a drive that failed outright could be silently downgraded to Warning by a
# later drive that merely warned, dropping the run from exit code 2 to 1. Status therefore
# only ever moves up the severity ladder. -Force exists for the rare case where a caller
# genuinely needs to reset an operation (e.g. a retry that supersedes the earlier attempt).
function Set-RaseOperationStatus {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][HealthStatus]$Status,
        [switch]$Force
    )
    if (-not $Force -and $Global:Ctx.OperationStatus.Contains($Name)) {
        $currentRank = $Global:RaseStatusRank[$Global:Ctx.OperationStatus[$Name].ToString()]
        $newRank = $Global:RaseStatusRank[$Status.ToString()]
        if ($null -ne $currentRank -and $null -ne $newRank -and $newRank -le $currentRank) { return }
    }
    $Global:Ctx.OperationStatus[$Name] = $Status
}

function Test-RaseAnyOperationFailed {
    foreach ($status in $Global:Ctx.OperationStatus.Values) {
        if ($status -eq [HealthStatus]::Failed) { return $true }
    }

    # Backward-compatible safety net for the detailed legacy fields. These remain checked
    # because several disk operations intentionally store their status on DiskTable rows.
    if ($Global:Ctx.DISM_Status -eq [HealthStatus]::Failed) { return $true }
    if ($Global:Ctx.SFC_Status -eq [HealthStatus]::Failed) { return $true }
    if ($Global:Ctx.Summary_CHKDSK -gt 0) { return $true }
    foreach ($row in $Global:Ctx.DiskTable) {
        if ($row.Status -in @("Errors", "TimedOut", "DIRTY")) { return $true }
        if ($row.TrimStatus -eq "Failed") { return $true }
        if ($row.DefragStatus -in @("Failed", "TimedOut")) { return $true }
        # FinalStatus already aggregates SMART Critical, Unhealthy Volume, and Critical Free
        # Space (via the same DiskRules pass as the score) - checking it here pulls those
        # diagnostic findings into the exit code too, not just the operational failures above.
        if ($row.FinalStatus -eq "Critical") { return $true }
    }
    return $false
}

function Test-RaseAnyOperationWarning {
    foreach ($status in $Global:Ctx.OperationStatus.Values) {
        if ($status -eq [HealthStatus]::Warning) { return $true }
    }
    return $false
}

function Test-RaseAnyPhaseSkipped {
    foreach ($status in $Global:Ctx.PhaseStatus.Values) {
        if ($status -eq [HealthStatus]::Skipped) { return $true }
    }
    return $false
}

# Reads the first present, non-null property from a list of candidate names - safe even
# under Set-StrictMode, and safe even when the object genuinely doesn't have the property
# at all (not just null). This matters for Get-StorageReliabilityCounter specifically:
# Microsoft documents that which counters a device actually exposes varies by drive
# interface, so code that assumes a fixed property name can throw on drives that simply
# don't report that counter - turning a healthy, unremarkable drive into "Error".
function Get-RasePropertyValue {
    param([Parameter(Mandatory)]$Object, [Parameter(Mandatory)][string[]]$Names)
    foreach ($name in $Names) {
        $prop = $Object.PSObject.Properties[$name]
        if ($null -ne $prop -and $null -ne $prop.Value) { return $prop.Value }
    }
    return $null
}

# Encodes untrusted, system-derived strings (hardware/device names) before they're
# interpolated into HTML. HtmlAdd/HtmlAddSection themselves can't do this globally - callers
# routinely pass deliberate markup (<b>, <span>, <hr>) through $Message/$Title, so escaping
# happens at the specific call sites where the untrusted fragment is embedded, not centrally.
function ConvertTo-HtmlSafe {
    param([AllowNull()][object]$Value)
    if ($null -eq $Value) { return "" }
    return [System.Net.WebUtility]::HtmlEncode([string]$Value)
}

# ----------------------------
# Small HTML helper used by optional tuning/report sections.
# Kept as a function so callers do not duplicate raw markup and so Set-StrictMode
# cannot turn a missing helper into a late Assessment failure.
# ----------------------------
function Add-RaseHtmlDivider {
    HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
}

# ----------------------------
# Single source of truth mapping a Recommendation Source / operation name to the phase it
# belongs to. Previously the recommendation map and the operation map were two separate
# literals inside Finalize-PhaseStatusSection, and they had drifted apart: several tracked
# operations ("Cleanup:Temp", "SystemRestorePoint", "DirtyBit") existed in one map and not
# the other, so their findings silently never reached the Issues Logged column.
# Operation names and recommendation Sources use the SAME strings on purpose - that is what
# lets the de-duplication in Finalize-PhaseStatusSection recognise that a recommendation and
# an operation status describe one finding rather than two.
# ----------------------------
# Tracks which operations have already emitted a Safety Gate recommendation this run.
$Global:RaseSafetyGateReported = @{}

$Global:RaseSourcePhaseMap = @{
    "PreFlight"          = "Initialization"
    "Baseline"           = "Initialization"
    "SystemRestorePoint" = "Initialization"
    "SMART"              = "Diagnostics"
    "Storage"            = "Diagnostics"
    "EventLog"           = "Diagnostics"
    "Hardware"           = "Diagnostics"
    "CHKDSK"             = "Restoration"
    "DISM"               = "Restoration"
    "SFC"                = "Restoration"
    "ReFS"               = "Restoration"
    "TRIM"               = "Optimization"
    "Defrag"             = "Optimization"
    "Cleanup:WU"         = "Optimization"
    "Cleanup:Temp"       = "Optimization"
    "Cleanup:RecycleBin" = "Optimization"
    "DirtyBit"           = "Assessment"
    "VSS"                = "Assessment"
    "NTFS"               = "Assessment"
    "WinRE"              = "Initialization"
    "DNS"                = "Assessment"
    "SafetyGate"         = "Assessment"
    "Engine"             = "Assessment"
}

# ----------------------------
# Volume identity normalisation. Win32_ShadowStorage.Volume is a CIM reference, not a plain
# string, while Win32_ShadowCopy.VolumeName and Win32_Volume.DeviceID are strings that may
# differ by a trailing backslash or in case. Comparing them raw silently fails to match,
# which previously meant per-volume shadow storage could not be resolved. Defined at script
# scope (rather than nested inside Invoke-VssPruning) so it is parsed once and reusable.
# ----------------------------
function ConvertTo-RaseVolumeId {
    param([AllowNull()][object]$Value)
    if ($null -eq $Value) { return $null }
    $candidate = $null
    $deviceProp = $Value.PSObject.Properties['DeviceID']
    if ($deviceProp -and $deviceProp.Value) {
        $candidate = [string]$deviceProp.Value
    }
    else {
        $candidate = [string]$Value
        if ($candidate -match '(?i)DeviceID=["'']([^"'']+)["'']') { $candidate = $Matches[1] }
    }
    if ([string]::IsNullOrWhiteSpace($candidate)) { return $null }
    return $candidate.Trim().Trim('"').TrimEnd('\').ToUpperInvariant()
}

# ----------------------------
# Phase Execution Engine (fault isolation between the 6 main phases)
# ----------------------------
function Invoke-RasePhase {
    param(
        [string]$Name,
        [scriptblock]$Action,
        [string[]]$DependsOn = @()
    )

    foreach ($dep in $DependsOn) {
        $depStatus = $Global:Ctx.PhaseStatus[$dep]
        if ($depStatus -eq [HealthStatus]::Failed) {
            $Global:Ctx.PhaseStatus[$Name] = [HealthStatus]::Skipped
            Console-Warn "Phase '$Name' skipped - dependency '$dep' failed."
            Add-Recommendation -Priority 2 -Message "Phase '$Name' was skipped because '$dep' failed. Re-run RASE after resolving the underlying issue." -Source "Engine"
            return
        }
        if ($depStatus -eq [HealthStatus]::Skipped) {
            $Global:Ctx.PhaseStatus[$Name] = [HealthStatus]::Skipped
            Console-Warn "Phase '$Name' skipped - dependency '$dep' was incomplete."
            Add-Recommendation -Priority 2 -Message "Phase '$Name' was skipped because '$dep' was incomplete. Review the Execution Overview before rerunning RASE." -Source "Engine"
            return
        }
    }

    Console-Step "Entering phase: $Name"
    try {
        & $Action
        $Global:Ctx.PhaseStatus[$Name] = [HealthStatus]::OK
    } catch {
        $Global:Ctx.PhaseStatus[$Name] = [HealthStatus]::Failed
        Console-Err "Phase '$Name' failed: $($_.Exception.Message)"
        LogError -Message $_.Exception.Message -Source "Phase:$Name" -Ex $_.Exception
        Add-Recommendation -Priority 1 -Message "Phase '$Name' failed and was aborted: $($_.Exception.Message)" -Source "Engine"
    }
}

function Get-Tier {
    param([int]$Score)
    if ($Score -ge 95) { return [pscustomobject]@{ Text="EXCELLENT"; Color="#4ec9b0"; Level=3 } }
    if ($Score -ge 85) { return [pscustomobject]@{ Text="GOOD"; Color="#6A9955"; Level=2 } }
    if ($Score -ge 70) { return [pscustomobject]@{ Text="ATTENTION"; Color="#D7BA7D"; Level=1 } }
    return [pscustomobject]@{ Text="CRITICAL"; Color="#F44747"; Level=0 }
}

# ----------------------------
# HTML Builder & Reporting
# ----------------------------
$Global:HtmlBuilder = New-Object System.Text.StringBuilder

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm"
$yearMonth = Get-Date -Format "yyyy\\MM"
$driveD = Get-Volume -DriveLetter D -ErrorAction SilentlyContinue
if ($driveD -and $driveD.FileSystem -match "NTFS|ReFS" -and $driveD.DriveType -eq "Fixed") {
    $ReportsRoot = "D:\RASE_Reports\$yearMonth"
} else {
    $ReportsRoot = "$env:ProgramData\RASE\Reports\$yearMonth"
}

# Report directory creation with a real fallback chain (D: -> ProgramData -> TEMP) rather than
# a bare New-Item that, if it throws (e.g. D: exists but isn't writable), would crash before
# the main try/catch even starts - with no report, no transcript, and a confusing raw error.
try {
    if (!(Test-Path $ReportsRoot)) { New-Item -ItemType Directory -Path $ReportsRoot -Force -ErrorAction Stop | Out-Null }
} catch {
    Write-Host "[WARN] Could not create report directory '$ReportsRoot' ($($_.Exception.Message)) - falling back to ProgramData." -ForegroundColor Yellow
    $ReportsRoot = "$env:ProgramData\RASE\Reports\$yearMonth"
    try {
        if (!(Test-Path $ReportsRoot)) { New-Item -ItemType Directory -Path $ReportsRoot -Force -ErrorAction Stop | Out-Null }
    } catch {
        Write-Host "[WARN] Could not create '$ReportsRoot' either ($($_.Exception.Message)) - falling back to TEMP." -ForegroundColor Yellow
        $ReportsRoot = "$env:TEMP\RASE\Reports\$yearMonth"
        try {
            if (!(Test-Path $ReportsRoot)) { New-Item -ItemType Directory -Path $ReportsRoot -Force -ErrorAction Stop | Out-Null }
        } catch {
            Write-Host "[FATAL] Could not create any report directory ($($_.Exception.Message)). RASE cannot write logs or reports." -ForegroundColor Red
            exit 3
        }
    }
}

# Filenames derive from $Global:RaseVersion for the same reason the banner does: hardcoding
# "v70" here meant that later runs still produced files named RASE_v70_*, which makes a folder of
# reports from several versions impossible to tell apart. The dot is stripped so the version
# never introduces an extra extension-looking segment into the filename.
$Global:RaseVersionTag = "v" + ($Global:RaseVersion -replace '[^0-9A-Za-z]', '')
$Global:TextLogPath  = "$ReportsRoot\RASE_$($Global:RaseVersionTag)_Transcript_$timestamp.txt"
$Global:HtmlLogPath  = "$ReportsRoot\RASE_$($Global:RaseVersionTag)_Report_$timestamp.html"
$Global:ErrorLogPath = "$ReportsRoot\RASE_$($Global:RaseVersionTag)_Errors_$timestamp.txt"
$Global:JsonLogPath  = "$ReportsRoot\RASE_$($Global:RaseVersionTag)_Report_$timestamp.json"
$Global:CsvLogPath   = "$ReportsRoot\RASE_$($Global:RaseVersionTag)_DiskTable_$timestamp.csv"

# Stop-Transcript later requires a transcript to actually be running, or it throws a
# terminating error under $ErrorActionPreference = "Stop" - including from inside `finally`,
# where that would surface as a visible error at the very end of every run. Track whether
# Start-Transcript actually succeeded so Stop-Transcript is only ever called when it did.
$Global:TranscriptStarted = $false
try {
    Start-Transcript -Path $Global:TextLogPath -Force -ErrorAction Stop | Out-Null
    $Global:TranscriptStarted = $true
} catch {
    Write-Host "[WARN] Failed to start transcript logging: $($_.Exception.Message)" -ForegroundColor Yellow
}

function Initialize-HtmlReport {
    param([string]$Title, [string]$Timestamp)

    # Reporting must not depend on WMI/CIM being healthy. If Win32_OperatingSystem or
    # Win32_BIOS is temporarily unavailable, RASE still needs to produce the diagnostic
    # artifact - especially when a later phase fails and the report is the recovery clue.
    $os = $null
    $bios = $null
    try { $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop } catch {}
    try { $bios = Get-CimInstance Win32_BIOS -ErrorAction Stop } catch {}

    $psVer = $PSVersionTable.PSVersion.ToString()
    $arch = if ([Environment]::Is64BitOperatingSystem) { "64-bit" } else { "32-bit" }
    $osCaption = if ($os) { [string]$os.Caption } else { "Unavailable" }
    $buildNumber = if ($os) { [string]$os.BuildNumber } else { "Unknown" }
    $biosVersion = if ($bios) { [string]$bios.SMBIOSBIOSVersion } else { "Unavailable" }
    $safeTitle = ConvertTo-HtmlSafe $Title
    $safeOsCaption = ConvertTo-HtmlSafe $osCaption
    $safeBiosVersion = ConvertTo-HtmlSafe $biosVersion
    
    $Global:HtmlBuilder.Clear() | Out-Null
    $Global:HtmlBuilder.AppendLine("<html><head><meta charset='UTF-8'><title>$safeTitle</title>") | Out-Null
    $Global:HtmlBuilder.AppendLine("<style>a {color: #569cd6; text-decoration: none;} a:hover {text-decoration: underline;}</style></head>") | Out-Null
    $Global:HtmlBuilder.AppendLine("<body style='background-color:#1e1e1e;color:#d4d4d4;font-family:Consolas,monospace;'>") | Out-Null
    $Global:HtmlBuilder.AppendLine("<h2 style='color:#569cd6;'>$safeTitle</h2>") | Out-Null
    $Global:HtmlBuilder.AppendLine("<p style='color:#808080;'><i>Reliability begins with maintenance!</i></p>") | Out-Null
    $Global:HtmlBuilder.AppendLine("<div style='font-size:12px;color:#a0a0a0;border:1px solid #444;padding:10px;margin-bottom:10px;'>") | Out-Null
    $Global:HtmlBuilder.AppendLine("<b>Execution Environment</b><br>OS: $safeOsCaption (Build $buildNumber) [$arch]<br>") | Out-Null
    $Global:HtmlBuilder.AppendLine("BIOS: $safeBiosVersion<br>PowerShell: v$psVer<br>RASE Series: v$($Global:RaseVersion)<br>Storage telemetry: Windows Storage Reliability counters (SMART-proxy where exposed)<br>Execution Date: $(ConvertTo-HtmlSafe $Timestamp)</div>") | Out-Null
    $Global:HtmlBuilder.AppendLine("<div style='background-color:#2d2d2d; padding:10px; border-radius:5px; margin-bottom:15px; font-size:13px;'>") | Out-Null
    $Global:HtmlBuilder.AppendLine("<b>Quick Navigation:</b> <a href='#System_Pre-Flight_Checks'>Pre-Flight</a> | <a href='#SYSTEM_PROFILE_SUMMARY'>Profile</a> | <a href='#Executive_Summary'>Executive Summary</a> | <a href='#Final_Disk_Summary'>Disk Summary</a></div><hr style='border:1px solid #444;'>") | Out-Null
}

function HtmlAdd {
    param([string]$Message, [string]$Color = "#d4d4d4")
    $Global:HtmlBuilder.AppendLine("<p style='color:$Color;font-size:14px;margin:5px 0;'>$Message</p>") | Out-Null
}

function HtmlAddSection {
    param([string]$Title)
    $safeTitle = ConvertTo-HtmlSafe $Title
    # anchorId feeds an HTML id='...' attribute - strip anything that isn't a word
    # character/space/hyphen before collapsing whitespace, so a title built from
    # system-derived text can't break out of the attribute.
    $anchorId = ($Title -replace '[^\w\s-]', '') -replace "\s+", "_"
    $Global:HtmlBuilder.AppendLine("<h3 id='$anchorId' style='color:#c586c0;margin-top:20px;border-bottom:1px solid #444;padding-bottom:5px;'>$safeTitle</h3>") | Out-Null
}

function LogError {
    param([string]$Message, [string]$Source = "Unknown", [Exception]$Ex = $null)
    $t = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMsg = "[$t] [$Source] $Message"
    if ($Ex) { $logMsg += "`nInner: $($Ex.InnerException)`nTrace: $($Ex.StackTrace)" }
    Add-Content -Path $Global:ErrorLogPath -Value $logMsg -Encoding UTF8
    HtmlAdd "ERROR ($Source): $Message" "#f44747"
}

# ----------------------------
# System Setup & Pre-Flight
# ----------------------------
function Invoke-SystemRestorePoint {
    HtmlAddSection "System Protection"
    Console-Step "System Restore Point"
    if ($DryRun) { HtmlAdd "Restore point skipped (DryRun mode)" "#D7BA7D"; $Global:Ctx.RestorePointStatus = "Skipped-DryRun"; return }

    # Declared outside the try so the catch block can read them under Set-StrictMode -Version
    # Latest even when the failure happened before they were assigned.
    $systemDrive = $null
    $enableError = $null

    try {
        $systemDrive = [Environment]::GetEnvironmentVariable("SystemDrive")
        if ([string]::IsNullOrWhiteSpace($systemDrive) -or $systemDrive -notmatch '^[A-Za-z]:$') {
            throw "Unable to determine a valid Windows system drive for System Protection."
        }
        # Enabling System Protection is preparation, not the goal - the goal is the checkpoint.
        # -ErrorAction Stop here made a failed preparation step abort the operation it was
        # preparing for: on a machine where protection is already on but Enable-ComputerRestore
        # errors anyway (policy, WMI provider state, an SKU without System Restore), RASE would
        # never even attempt Checkpoint-Computer, which might well have succeeded. The failure is
        # recorded instead, so it can be reported as context if the checkpoint also fails.
        $enableError = $null
        try { Enable-ComputerRestore -Drive $systemDrive -ErrorAction Stop }
        catch { $enableError = $_.Exception.Message }

        $rpName = "RASE_v$($Global:RaseVersion)_Backup_$timestamp"
        Checkpoint-Computer -Description $rpName -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        HtmlAdd "Restore point created successfully: $rpName" "#4ec9b0"
        Console-OK "Restore point created."
        $Global:Ctx.RestorePointStatus = "Created"
        Set-RaseOperationStatus -Name "SystemRestorePoint" -Status ([HealthStatus]::OK)
    } catch {
        # Windows may reject a second restore point during its 24h creation interval.
        # An existing recent checkpoint is still valid rollback protection.
        $recentPoints = @()
        try {
            $cutoff = (Get-Date).AddHours(-24)
            $allPoints = @(Get-ComputerRestorePoint -ErrorAction SilentlyContinue)
            foreach ($rp in $allPoints) {
                $created = Get-RaseRestorePointTime -RestorePoint $rp
                if ($null -ne $created -and $created -ge $cutoff) {
                    $recentPoints += [pscustomobject]@{ CreationTime = $created; Description = [string]$rp.Description }
                }
            }
            $recentPoints = @($recentPoints | Sort-Object CreationTime -Descending)
        } catch { $recentPoints = @() }

        if ($recentPoints.Count -gt 0) {
            $recentDesc = [string]$recentPoints[0].Description
            HtmlAdd "New Restore Point was not created, but an existing Restore Point from the last 24h is available: $(ConvertTo-HtmlSafe $recentDesc)." "#4ec9b0"
            Console-Warn "Using an existing recent Restore Point as the safety checkpoint."
            $Global:Ctx.RestorePointStatus = "ExistingRecent"
            Set-RaseOperationStatus -Name "SystemRestorePoint" -Status ([HealthStatus]::OK)
        } else {
            LogError "System Restore Point creation skipped or failed." "PreFlight" $_.Exception
            if (-not [string]::IsNullOrWhiteSpace($enableError)) {
                HtmlAdd "System Protection could not be enabled on ${systemDrive}: $(ConvertTo-HtmlSafe $enableError)" "#D7BA7D"
            }
            HtmlAdd "No usable Restore Point is available. Higher-risk Full-mode optimization writes will be blocked by the Safety Gate." "#D7BA7D"
            Console-Warn "No usable Restore Point - optimization Safety Gate will limit write operations."
            $Global:Ctx.RestorePointStatus = "Warning"
            Set-RaseOperationStatus -Name "SystemRestorePoint" -Status ([HealthStatus]::Warning)
            Add-Recommendation -Priority 2 -Message "No usable recent Restore Point was found. RASE will skip higher-risk Full-mode optimization writes until rollback protection is available." -Source "SystemRestorePoint"
        }
    }
}


# Get-ComputerRestorePoint returns WMI objects whose CreationTime is a DMTF string
# ("20260808153000.000000-000"), not a DateTime. Casting that with [datetime] throws, and
# under $ErrorActionPreference = "Stop" the throw propagates out of the enclosing pipeline -
# which is exactly how the v73.3 lookup ended up silently returning zero recent points on
# every machine. ManagementDateTimeConverter is the documented converter and is already used
# elsewhere in this file for WMI driver dates.
function Get-RaseRestorePointTime {
    param([Parameter(Mandatory)]$RestorePoint)

    $raw = $null
    $prop = $RestorePoint.PSObject.Properties['CreationTime']
    if ($prop) { $raw = $prop.Value }
    if ($null -eq $raw) { return $null }
    if ($raw -is [datetime]) { return $raw }

    $text = [string]$raw
    if ([string]::IsNullOrWhiteSpace($text)) { return $null }

    try { return [System.Management.ManagementDateTimeConverter]::ToDateTime($text) } catch {}
    try { return $RestorePoint.ConvertToDateTime($text) } catch {}

    $parsed = [DateTime]::MinValue
    if ([DateTime]::TryParse($text, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::AssumeLocal, [ref]$parsed)) {
        return $parsed
    }
    return $null
}

# Rollback gate for the two operations a System Restore point can genuinely undo.
#
# Scope is deliberately narrow. A restore point snapshots the registry and protected system
# files - it does not cover user data, temp files, the Recycle Bin, the Windows Update cache,
# or volume layout. Gating Cleanup/TRIM/Defrag on it (as v73.3 did) blocked work that a
# restore point could never have rolled back anyway, on machines where System Protection is
# simply switched off; and both TRIM and Defrag already refuse to touch a volume marked
# DIRTY/Errors/TimedOut, which is the precondition that actually matters for them.
#
# What IS gated: NTFS behaviour tuning (writes HKLM\SYSTEM\CurrentControlSet\Control\FileSystem,
# which a restore point does capture) and VSS shadow-copy deletion (irreversible, and shadow
# copies are the same storage restore points live in).
function Test-RaseOptimizationSafetyGate {
    param(
        [Parameter(Mandatory)][string]$OperationName
    )

    # QuickScan and DryRun never perform the destructive writes guarded here.
    if ($Mode -eq "QuickScan" -or $DryRun) { return $true }

    $protected = $Global:Ctx.RestorePointStatus -in @("Created", "ExistingRecent")
    if ($protected) { return $true }

    HtmlAdd "Safety Gate: $OperationName skipped because no usable recent Restore Point is available." "#D7BA7D"
    Console-Warn "Safety Gate blocked $OperationName - no usable recent Restore Point."
    Set-RaseOperationStatus -Name $OperationName -Status ([HealthStatus]::Skipped)

    # One recommendation per operation, not one per disk task / per volume - the gate is
    # called from inside loops and v73.3 produced a duplicate entry for every iteration.
    if (-not $Global:RaseSafetyGateReported.Contains($OperationName)) {
        $Global:RaseSafetyGateReported[$OperationName] = $true
        $systemDrive = [Environment]::GetEnvironmentVariable("SystemDrive")
        if ([string]::IsNullOrWhiteSpace($systemDrive)) { $systemDrive = "the Windows system volume" }
        Add-Recommendation -Priority 2 -Message "$OperationName was skipped by the Safety Gate because no usable recent Restore Point is available. Enable System Protection on $systemDrive (or create a restore point manually) and re-run RASE." -Source "SafetyGate"
    }
    return $false
}

function Invoke-PreFlightChecks {
    HtmlAddSection "System Pre-Flight Checks"
    
    Console-Step "Checking Boot Mode (Cascade EFI/Legacy)..."
    $isUEFI = $false
    try { $null = Confirm-SecureBootUEFI -ErrorAction Stop; $isUEFI = $true } 
    catch {
        if ($env:firmware_type -eq 'UEFI') { $isUEFI = $true } 
        else { try { if ((bcdedit /enum) -match "\.efi") { $isUEFI = $true } } catch { Console-Warn "Failed to determine boot mode via bcdedit." } }
    }
    $bootModeText = if ($isUEFI) { "UEFI" } else { "Legacy BIOS" }
    
    Console-Step "Checking Windows RE Status..."
    $winreState = Get-WinREState
    $Global:Ctx.WinREState = $winreState
    $Global:Ctx.WinRE_Enabled = ($winreState -eq "Enabled")

    # A missing recovery environment previously showed up only as a summary line and an 8-point
    # Maintenance Readiness penalty - it never reached Recommended Actions, which is the part of
    # the report an operator actually acts on. "Unknown" is reported separately and at lower
    # priority: it means RASE could not verify WinRE, not that WinRE is absent.
    if ($winreState -eq "Disabled") {
        Add-Recommendation -Priority 2 -Message "Windows Recovery Environment is disabled. Run 'reagentc /enable' from an elevated prompt so startup repair and offline recovery remain available." -Source "WinRE"
    }
    elseif ($winreState -ne "Enabled") {
        Add-Recommendation -Priority 3 -Message "Windows Recovery Environment state could not be determined. Run 'reagentc /info' manually to confirm a recovery environment is present." -Source "WinRE"
    }
    
    Console-Step "Checking Pending Reboot Status..."
    $pendingReboot = $false
    $regKeys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired",
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\PostRebootReporting"
    )
    foreach ($key in $regKeys) { if (Test-Path $key) { $pendingReboot = $true; break } }
    $pendingRenames = @()
    try {
        $sessionManagerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager"
        $sessionManagerProps = Get-ItemProperty -Path $sessionManagerPath -ErrorAction SilentlyContinue

        if ($null -ne $sessionManagerProps) {
            $pendingRenameProperty = $sessionManagerProps.PSObject.Properties["PendingFileRenameOperations"]
            if ($null -ne $pendingRenameProperty) {
                $pendingRenames = @($pendingRenameProperty.Value)
            }
        }
    } catch {
        # Missing PendingFileRenameOperations is a normal "no pending rename" state.
        # A genuine provider/read failure must not manufacture a pending reboot.
        $pendingRenames = @()
    }

    if ($pendingRenames.Count -gt 0) { $pendingReboot = $true }
    
    $Global:Ctx.PendingReboot = $pendingReboot
    $rebootText = if ($pendingReboot) { "Yes (Action Recommended)" } else { "No" }
    
    $tableHtml = "<table border='1' cellspacing='0' cellpadding='5' style='border-collapse: collapse; border: 1px solid #444; width: 100%; text-align: left;'>"
    $tableHtml += "<tr style='background-color: #333; color: #fff;'><th>Check</th><th>Result</th><th>Status</th></tr>"
    $tableHtml += "<tr><td style='border: 1px solid #444;'>Elevation</td><td style='border: 1px solid #444;'>Administrator</td><td style='border: 1px solid #444; color:#4ec9b0;'>OK</td></tr>"
    $tableHtml += "<tr><td style='border: 1px solid #444;'>Boot Mode</td><td style='border: 1px solid #444;'>$bootModeText</td><td style='border: 1px solid #444; color:#a0a0a0;'>Info</td></tr>"
    
    $winReColor = switch ($winreState) { "Enabled" { "#4ec9b0" }; "Disabled" { "#D7BA7D" }; default { "#808080" } }
    $winReStatus = switch ($winreState) { "Enabled" { "OK" }; "Disabled" { "Warning" }; default { "Unknown" } }
    $tableHtml += "<tr><td style='border: 1px solid #444;'>Windows RE</td><td style='border: 1px solid #444;'>$winreState</td><td style='border: 1px solid #444; color:$winReColor;'>$winReStatus</td></tr>"
    
    $rebootColor = if ($pendingReboot) { "#D7BA7D" } else { "#4ec9b0" }
    $rebootStatus = if ($pendingReboot) { "Warning" } else { "OK" }
    $tableHtml += "<tr><td style='border: 1px solid #444;'>Pending Reboot</td><td style='border: 1px solid #444;'>$rebootText</td><td style='border: 1px solid #444; color:$rebootColor;'>$rebootStatus</td></tr>"
    $tableHtml += "</table>"
    $Global:HtmlBuilder.AppendLine($tableHtml) | Out-Null
    if ($Mode -eq "QuickScan") {
        HtmlAdd "QuickScan write protections: expected write-capable operations were skipped by policy; these skips are not counted as failures." "#808080"
    }
    
    if ($pendingReboot) { 
        HtmlAdd "Maintenance started while reboot is pending. Some results may be affected." "#D7BA7D" 
        Add-Recommendation -Priority 1 -Message "Restart Windows to apply pending system changes." -Source "PreFlight"
    }
    if ($winreState -eq "Disabled") {
        Add-Recommendation -Priority 2 -Message "Enable Windows Recovery Environment (reagentc /enable)." -Source "PreFlight"
    } elseif ($winreState -eq "Unknown") {
        Add-Recommendation -Priority 3 -Message "Windows RE status could not be determined - verify manually with 'reagentc /info'." -Source "PreFlight"
    }
}

# ----------------------------
# System Profile & Plan
# ----------------------------
function Get-HardwareProfile {
    # Profiling is best-effort. One unavailable WMI class must not prevent the rest of the
    # machine from being diagnosed or the final report from being written.
    $cpu = @(Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue) | Select-Object -First 1
    $ram = @(Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue) | Select-Object -First 1
    $gpus = @(Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue)

    $disks = @(Get-PhysicalDisk -ErrorAction SilentlyContinue)
    if ($disks.Count -eq 0) {
        $disks = @(Get-CimInstance Win32_DiskDrive -ErrorAction SilentlyContinue |
            Select-Object @{Name="FriendlyName";Expression={$_.Model}},
                          @{Name="MediaType";Expression={"Unknown"}},
                          @{Name="BusType";Expression={$_.InterfaceType}},
                          @{Name="DeviceId";Expression={$_.Index}},
                          @{Name="HealthStatus";Expression={$_.Status}},
                          @{Name="UniqueId";Expression={$_.PNPDeviceID}},
                          @{Name="SpindleSpeed";Expression={$null}})
    }
    
    $powerPlan = "Unknown"
    try { $powerPlan = (Get-CimInstance Win32_PowerPlan -Namespace root\cimv2\power | Where-Object { $_.IsActive }).ElementName } catch { Console-Warn "PowerPlan query skipped." }

    $trimNTFS = "Unknown"; $trimReFS = "Unknown"
    try {
        $trimOut = @(& fsutil.exe behavior query DisableDeleteNotify 2>&1)
        $trimExit = $LASTEXITCODE
        if ($trimExit -eq 0 -and $trimOut.Count -gt 0) {
            # fsutil keeps the filesystem token and DisableDeleteNotify name stable even when
            # the surrounding text is localized. Parse each line independently so a match for
            # one filesystem cannot overwrite the value for the other via $Matches.
            foreach ($line in $trimOut) {
                $text = [string]$line
                if ($text -match '(?i)\bNTFS\s+DisableDeleteNotify\s*=\s*([01])\b') {
                    $trimNTFS = if ([int]$Matches[1] -eq 0) { "Enabled" } else { "Disabled" }
                    continue
                }
                if ($text -match '(?i)\bReFS\s+DisableDeleteNotify\s*=\s*([01])\b') {
                    $trimReFS = if ([int]$Matches[1] -eq 0) { "Enabled" } else { "Disabled" }
                }
            }
        }
        else {
            Console-Warn "DisableDeleteNotify query returned exit code $trimExit."
        }
    } catch { Console-Warn "DisableDeleteNotify query skipped: $($_.Exception.Message)" }

    # Named $hwProfile, not $profile: the latter is a PowerShell automatic variable holding the
    # profile script path, and shadowing it inside a function is a trap waiting for whoever
    # edits this next.
    $hwProfile = [pscustomobject]@{
        CPU = [pscustomobject]@{ Name = if ($cpu) { $cpu.Name } else { "Unavailable" }; Cores = if ($cpu) { $cpu.NumberOfCores } else { $null }; Threads = if ($cpu) { $cpu.NumberOfLogicalProcessors } else { $null } }
        RAM = [pscustomobject]@{ TotalGB = if ($ram) { [math]::Round($ram.TotalPhysicalMemory / 1GB, 2) } else { $null } }
        GPU = @()
        Disks = @($disks); Volumes = @(Get-Volume -ErrorAction SilentlyContinue)
        System = [pscustomobject]@{ PowerPlan = $powerPlan; TrimNTFS = $trimNTFS; TrimReFS = $trimReFS }
    }

    foreach ($gpu in $gpus) {
        $vendor = "Unknown"
        if ($gpu.Name -match "NVIDIA") { $vendor = "NVIDIA" } elseif ($gpu.Name -match "AMD|Radeon") { $vendor = "AMD" } elseif ($gpu.Name -match "Intel") { $vendor = "Intel" }
        $drvDate = "Unknown"
        if ($null -ne $gpu.DriverDate -and [string]::IsNullOrWhiteSpace([string]$gpu.DriverDate) -eq $false) {
            try {
                if ($gpu.DriverDate -is [DateTime]) {
                    $drvDate = $gpu.DriverDate.ToString("yyyy-MM-dd")
                }
                else {
                    $rawDriverDate = [string]$gpu.DriverDate
                    try {
                        $drvDate = [management.managementDateTimeConverter]::ToDateTime($rawDriverDate).ToString("yyyy-MM-dd")
                    }
                    catch {
                        $parsedDriverDate = [DateTime]::MinValue
                        if ([DateTime]::TryParse($rawDriverDate, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::AssumeLocal, [ref]$parsedDriverDate)) {
                            $drvDate = $parsedDriverDate.ToString("yyyy-MM-dd")
                        }
                        else {
                            $drvDate = "Unknown"
                        }
                    }
                }
            }
            catch {
                $drvDate = "Unknown"
            }
        }
        $hwProfile.GPU += [pscustomobject]@{ Name = $gpu.Name; Vendor = $vendor; DriverVersion = $gpu.DriverVersion; DriverDate = $drvDate }
    }
    return $hwProfile
}

function Generate-SystemProfileSummary {
    param([pscustomobject]$SystemProfile)
    HtmlAddSection "SYSTEM PROFILE SUMMARY"
    HtmlAdd ("CPU: " + (ConvertTo-HtmlSafe $SystemProfile.CPU.Name)) "#808080"
    HtmlAdd ("RAM: " + $SystemProfile.RAM.TotalGB + " GB") "#808080"
    foreach ($gpu in $SystemProfile.GPU) { HtmlAdd ("GPU: " + (ConvertTo-HtmlSafe $gpu.Name) + " | Driver: " + (ConvertTo-HtmlSafe $gpu.DriverVersion) + " (" + $gpu.DriverDate + ")") "#808080" }
    HtmlAdd ("Power Plan: " + $SystemProfile.System.PowerPlan) "#808080"
    HtmlAdd ("Global TRIM (OS) - NTFS: " + $SystemProfile.System.TrimNTFS + " | ReFS: " + $SystemProfile.System.TrimReFS) "#808080"
    HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
}

function Initialize-GlobalDiskTable {
    param([pscustomobject]$SystemProfile)
    HtmlAddSection "Disk Detection & Baseline"
    $allParts = @(Get-Partition -ErrorAction SilentlyContinue); $allDisks = @(Get-Disk -ErrorAction SilentlyContinue)

    $windowsVols = @($SystemProfile.Volumes | Where-Object { $_.DriveLetter -and $_.FileSystem -match "NTFS|ReFS" })
    foreach ($vol in $windowsVols) {
        $drive = $vol.DriveLetter; $disk = $null
        try {
            $partition = $allParts | Where-Object { $_.DriveLetter -eq $drive }
            if ($partition) {
                $diskInfo = $allDisks | Where-Object { $_.Number -eq $partition.DiskNumber }
                if ($diskInfo) { $disk = $SystemProfile.Disks | Where-Object { $_.DeviceId -eq $diskInfo.Number -or $_.UniqueId -eq $diskInfo.UniqueId } }
            }
        } catch { LogError "Failed to map partition to disk for drive $drive." "Baseline" $_.Exception }

        $name = if ($disk) { $disk.FriendlyName } else { "Unknown" }
        $sizeGB = [math]::Round($vol.Size / 1GB, 2); $freeGB = [math]::Round($vol.SizeRemaining / 1GB, 2)
        
        HtmlAdd ("Disk " + $drive + ": (" + (ConvertTo-HtmlSafe $name) + ")") "#808080"
        HtmlAdd ("FileSystem: $($vol.FileSystem) | Size: $sizeGB GB | Free: $freeGB GB") "#808080"
        
        $percentFree = if ($sizeGB -gt 0) { ($freeGB / $sizeGB) * 100 } else { 100 }
        if ($percentFree -lt $Global:Threshold_FreeSpaceCritical) { HtmlAdd "CRITICAL: Extremely low free space (<$($Global:Threshold_FreeSpaceCritical)%)" "#f44747" } elseif ($percentFree -lt $Global:Threshold_FreeSpaceWarning) { HtmlAdd "Warning: Low free space" "#D7BA7D" }
        HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"

        $Global:Ctx.DiskTable += [pscustomobject]@{
            Disk = ($drive + ":"); Name = $name; Type = if ($disk) { $disk.MediaType } else { "Unknown" }; Health = $vol.HealthStatus
            DiskNumber = if ($disk) { $disk.DeviceId } else { $null }; DiskUniqueId = if ($disk) { $disk.UniqueId } else { $null }
            InitialHealthScore = "Pending"; FinalHealthScore = "Pending"; RiskLevel = "N/A"; SmartRaw = "Pending"; Status = "OK"
            TrimStatus = if ($Mode -eq "QuickScan") {
                "Skipped-QuickScan"
            } elseif ($disk -and (
                ($disk.MediaType -eq "SSD") -or
                ($disk.BusType -eq "NVMe") -or
                (($disk.MediaType -eq "Unspecified") -and ($null -ne $disk.SpindleSpeed) -and ($disk.SpindleSpeed -eq 0))
            )) {
                "Pending"
            } else {
                "NotApplicable"
            }
            DefragStatus = if ($Mode -eq "QuickScan") {
                "Skipped-QuickScan"
            } elseif ($disk -and (
                ($disk.MediaType -eq "HDD") -or
                (($disk.MediaType -eq "Unspecified") -and ($null -ne $disk.SpindleSpeed) -and ($disk.SpindleSpeed -gt 0))
            )) {
                "Pending"
            } else {
                "NotApplicable"
            }
            FragLevel = $null; PercentFree = [math]::Round($percentFree, 1); FinalStatus = "Pending"
        }
    }
}

function Get-OptimizationPlan {
    param([pscustomobject]$SystemProfile)
    $plan = [pscustomobject]@{ DiskTasks = @(); SystemTasks = @(); CleanupTasks = @() }
    $allParts = @(Get-Partition -ErrorAction SilentlyContinue); $allDisks = @(Get-Disk -ErrorAction SilentlyContinue)

    foreach ($disk in $SystemProfile.Disks) {
        $volumeInfo = @()
        if ($allParts -and $allDisks) {
            foreach ($p in $allParts) {
                $d = $allDisks | Where-Object { $_.Number -eq $p.DiskNumber } | Select-Object -First 1
                if ($d -and $p.DriveLetter) {
                    $uniqueMatch = (
                        -not [string]::IsNullOrWhiteSpace([string]$d.UniqueId) -and
                        -not [string]::IsNullOrWhiteSpace([string]$disk.UniqueId) -and
                        $d.UniqueId -eq $disk.UniqueId
                    )
                    $numberMatch = ($d.Number -eq $disk.DeviceId)
                    if (-not ($uniqueMatch -or $numberMatch)) { continue }
                    $vol = $SystemProfile.Volumes | Where-Object { $_.DriveLetter -eq $p.DriveLetter } | Select-Object -First 1
                    if ($vol) {
                        $volumeInfo += [pscustomobject]@{ DriveLetter = $p.DriveLetter; FileSystem = $vol.FileSystem }
                    }
                }
            }
        }

        # Build the action list from actual volume capabilities. ReFS is handled by its
        # dedicated Repair-Volume path; CHKDSK is NTFS-only. TRIM/Defrag are planned only
        # for NTFS/ReFS volumes, so the execution engine does not have to assign broad
        # actions and then discover incompatible filesystems later.
        $supportedVols = @($volumeInfo | Where-Object { $_.FileSystem -in @('NTFS','ReFS') })
        $ntfsVols = @($volumeInfo | Where-Object { $_.FileSystem -eq 'NTFS' })
        $letters = @($supportedVols | ForEach-Object { $_.DriveLetter } | Select-Object -Unique)
        $actions = @()

        if ($supportedVols.Count -gt 0) {
            if (($disk.MediaType -eq 'SSD') -or ($disk.BusType -eq 'NVMe') -or ($disk.MediaType -eq 'Unspecified' -and $disk.SpindleSpeed -eq 0)) {
                $actions += 'TRIM Optimization'
            }
            if (($disk.MediaType -eq 'HDD') -or ($disk.MediaType -eq 'Unspecified' -and $disk.SpindleSpeed -gt 0)) {
                $actions += 'HDD Defragmentation'
            }
        }
        if ($ntfsVols.Count -gt 0) { $actions += 'CHKDSK Integrity Check' }

        $plan.DiskTasks += [pscustomobject]@{
            DiskName = $disk.FriendlyName; MediaType = $disk.MediaType; BusType = $disk.BusType;
            SpindleSpeed = $disk.SpindleSpeed; DriveLetters = $letters; Actions = @($actions)
        }
    }

    $plan.SystemTasks = @("Dirty Bit Check", "ReFS Integrity Check", "DISM Component Health Check", "SFC System File Check", "NTFS File System Tuning", "VSS Pruning (Oldest Shadow Copy)", "DNS Cache Flush")
    $plan.CleanupTasks = @("Temp Cleanup", "Recycle Bin Cleanup", "Windows Update Cache Cleanup")
    return $plan
}

# ----------------------------
# Diagnostics & Events
# ----------------------------
function Invoke-SystemExtendedDiagnostics {
    HtmlAddSection "System Diagnostics (Extended)"
    try {
        $bootEvent = Get-WinEvent -FilterHashtable @{LogName='Microsoft-Windows-Diagnostics-Performance/Operational'; ID=100} -MaxEvents 1 -ErrorAction SilentlyContinue
        if ($bootEvent) {
            $xml = [xml]$bootEvent.ToXml()
            $bootTimeMs = $xml.Event.EventData.Data | Where-Object { $_.Name -eq 'BootTime' } | Select-Object -ExpandProperty '#text'
            if ($bootTimeMs) {
                $sec = [math]::Round([int]$bootTimeMs / 1000)
                $bootColor = if ($sec -le 40) { "#4ec9b0" } elseif ($sec -le 90) { "#D7BA7D" } else { "#f44747" }
                HtmlAdd ("Boot Duration: $sec seconds") $bootColor
            }
        } else { HtmlAdd "Boot time data unavailable (Diag-Perf disabled)." "#808080" }
    } catch { Console-Warn "BootTime check skipped." }

    try {
        $hv = Get-Service vmms -ErrorAction SilentlyContinue
        if ($hv) { HtmlAdd "Hyper-V Virtual Machine Management: Installed" "#808080" }
    } catch { Console-Warn "Hyper-V check skipped." }
    HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
}

function Invoke-DiskDiagnostics {
    param([pscustomobject]$SystemProfile)
    foreach ($disk in $SystemProfile.Disks) {
        HtmlAddSection ("Deep Storage Diagnostics - " + (ConvertTo-HtmlSafe $disk.FriendlyName))
        # Honest default: we haven't successfully read anything yet, so we don't know the
        # disk's state. This must never silently become "OK" just because nothing went wrong
        # in the try block - "no data" and "healthy" are different claims.
        $smartStatus = "Unavailable"
        try {
            $reliability = Get-StorageReliabilityCounter -PhysicalDisk $disk -ErrorAction SilentlyContinue
            if ($reliability) {
                $sawAnyField = $false
                $severity = 0   # 0=OK, 1=Warning, 2=Critical - driven by whichever signal is worst

                $temperature = Get-RasePropertyValue -Object $reliability -Names @("Temperature")
                if ($null -ne $temperature) {
                    $sawAnyField = $true
                    $t = [int]$temperature
                    $tColor = if ($t -ge $Global:Threshold_SmartTempCritical) { $severity = [Math]::Max($severity, 2); "#f44747" }
                              elseif ($t -ge $Global:Threshold_SmartTempWarning) { $severity = [Math]::Max($severity, 1); "#D7BA7D" }
                              else { "#4ec9b0" }
                    HtmlAdd ("Temperature: " + $t + " &deg;C") $tColor
                }

                # Real property name is "Wear" (percentage of rated life used). Older RASE
                # code assumed "PercentageUsed", which is not a documented property of
                # MSFT_StorageReliabilityCounter.
                $wear = Get-RasePropertyValue -Object $reliability -Names @("Wear", "PercentageUsed", "WearPercentageUsed")
                if ($null -ne $wear) {
                    $sawAnyField = $true
                    $w = [double]$wear
                    $wColor = if ($w -ge $Global:Threshold_SmartWearCritical) { $severity = [Math]::Max($severity, 2); "#f44747" }
                              elseif ($w -ge $Global:Threshold_SmartWearWarning) { $severity = [Math]::Max($severity, 1); "#D7BA7D" }
                              else { "#808080" }
                    HtmlAdd ("Wear Level: " + $w + "%") $wColor
                }

                # Real property names are ReadErrorsUncorrected / WriteErrorsUncorrected (with
                # ...Corrected and ...Total variants also documented). "ReadErrors" and
                # "UncorrectableErrors" - used previously - are not the documented names.
                $errCount = 0
                $readErrUncorrected = Get-RasePropertyValue -Object $reliability -Names @("ReadErrorsUncorrected")
                if ($null -ne $readErrUncorrected) {
                    $sawAnyField = $true; $re = [int64]$readErrUncorrected; $errCount += $re
                    HtmlAdd ("Uncorrected Read Errors: " + $re) $(if($re -gt 0){"#f44747"}else{"#808080"})
                }
                $writeErrUncorrected = Get-RasePropertyValue -Object $reliability -Names @("WriteErrorsUncorrected")
                if ($null -ne $writeErrUncorrected) {
                    $sawAnyField = $true; $we = [int64]$writeErrUncorrected; $errCount += $we
                    HtmlAdd ("Uncorrected Write Errors: " + $we) $(if($we -gt 0){"#f44747"}else{"#808080"})
                }
                if ($errCount -ge $Global:Threshold_SmartErrorsCritical) { $severity = [Math]::Max($severity, 2) }
                elseif ($errCount -ge $Global:Threshold_SmartErrorsWarning) { $severity = [Math]::Max($severity, 1) }

                if ($sawAnyField) {
                    $smartStatus = switch ($severity) { 2 { "Failed" }; 1 { "Warning" }; default { "OK" } }
                } else {
                    # Get-StorageReliabilityCounter returned an object, but none of the counters
                    # we look for were present on it - the interface didn't expose usable data.
                    HtmlAdd "StorageReliability counters returned no usable fields for this drive interface." "#808080"
                }
            } else { HtmlAdd "Deep StorageReliability counters unavailable for this drive interface." "#808080" }
        } catch {
            $smartStatus = "Error"
            HtmlAdd "SMART data query failed for this drive." "#D7BA7D"
            LogError "SMART query exception for $($disk.FriendlyName)." "SMART" $_.Exception
        }

        foreach ($row in (Find-DiskTableRows -Disk $disk)) { $row.SmartRaw = $smartStatus }

        if ($smartStatus -in @("Unavailable", "Error")) {
            # Telemetry availability is not physical drive health. Some USB, RAID, virtual,
            # and vendor-specific storage stacks do not expose Windows Storage Reliability
            # counters even when the underlying drive is healthy.
            Add-Recommendation -Priority 3 -Message "Storage Reliability / SMART-proxy telemetry could not be read for $($disk.FriendlyName). This does not lower the physical HealthScore; verify drive health manually with the manufacturer's diagnostic tool if needed." -Source "SMART"
        }

        $statColor = switch ($smartStatus) {
            "OK"          { "#4ec9b0" }
            "Warning"     { "#D7BA7D" }
            "Failed"      { "#f44747" }
            "Error"       { "#f44747" }
            default       { "#808080" }   # Unavailable
        }
        HtmlAdd ("Overall SMART Status: " + $smartStatus) $statColor
        HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
    }
}

function Invoke-EventViewerDiagnostics {
    HtmlAddSection "Event Viewer Health (Last 30 Days)"
    Console-Step "Parsing Event Viewer (WinEvent)..."
    $date = (Get-Date).AddDays(-30)
    
    # Errors (Level 2) and Warnings (Level 3) are collected separately, exactly as the WHEA
    # block below already does. A single Level 3 Disk entry ("the IO operation ... was retried")
    # is routine on healthy machines, so folding warnings into one count meant almost every run
    # produced a Priority 2 recommendation and exited with code 1. Warnings stay visible in the
    # report as context; only errors are allowed to raise a recommendation.
    $ParseEvents = {
        param($Provider)
        $errors   = @(Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName=$Provider; Level=2; StartTime=$date} -ErrorAction SilentlyContinue)
        $warnings = @(Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName=$Provider; Level=3; StartTime=$date} -ErrorAction SilentlyContinue)
        $lastErr = if ($errors.Count -gt 0) { $errors[0].TimeCreated.ToString("yyyy-MM-dd HH:mm") } else { "None" }
        return [pscustomobject]@{ ErrorCount = $errors.Count; WarningCount = $warnings.Count; LastError = $lastErr }
    }

    try {
        # Get-WinEvent raises a non-terminating error when nothing matches the filter, and
        # -ErrorAction SilentlyContinue swallows it - so "no events in 30 days" and "the log
        # could not be read at all" both arrive here as zero. Probing the log once is what lets
        # the report tell a genuinely clean history apart from a query that never worked.
        $systemLogReadable = $false
        $systemLogEnabled = $null
        try {
            # ListLog tests whether the log itself can be opened. It does not require the log to
            # contain an event, so an empty-but-readable System log is not mistaken for a provider
            # or access failure.
            $systemLogInfo = Get-WinEvent -ListLog 'System' -ErrorAction Stop
            $systemLogReadable = $null -ne $systemLogInfo
            if ($systemLogInfo.PSObject.Properties['IsEnabled']) {
                $systemLogEnabled = [bool]$systemLogInfo.IsEnabled
            }
        } catch {
            $systemLogReadable = $false
        }

        if (-not $systemLogReadable) {
            HtmlAdd "System event log could not be opened - Disk, NTFS, WHEA and crash history were not checked. Zero counts are not reported because they would not be evidence that no errors occurred." "#D7BA7D"
            Add-Recommendation -Priority 2 -Message "RASE could not open the System event log, so Disk/NTFS/WHEA/crash history was not reviewed. Check the Windows Event Log service and log permissions." -Source "EventLog"
            HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
            return
        }

        if ($systemLogEnabled -eq $false) {
            HtmlAdd "System event log is disabled - event history was not evaluated." "#D7BA7D"
            Add-Recommendation -Priority 2 -Message "The System event log is disabled, so RASE could not evaluate Disk/NTFS/WHEA/crash history. Review Windows Event Log configuration before treating the event history as clean." -Source "EventLog"
            HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
            return
        }

        $diskData = &$ParseEvents -Provider "Disk"
        $ntfsData = &$ParseEvents -Provider "Ntfs"
        $bsodData = Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-WER-SystemErrorReporting'; StartTime=$date} -ErrorAction SilentlyContinue
        
        HtmlAdd ("Disk Errors: " + $diskData.ErrorCount + " (Last: " + $diskData.LastError + ") | Warnings: " + $diskData.WarningCount) $(if($diskData.ErrorCount -gt 0){"#f44747"}elseif($diskData.WarningCount -gt 0){"#D7BA7D"}else{"#4ec9b0"})
        HtmlAdd ("NTFS Errors: " + $ntfsData.ErrorCount + " (Last: " + $ntfsData.LastError + ") | Warnings: " + $ntfsData.WarningCount) $(if($ntfsData.ErrorCount -gt 0){"#f44747"}elseif($ntfsData.WarningCount -gt 0){"#D7BA7D"}else{"#4ec9b0"})
        if ($diskData.ErrorCount -gt 0) {
            Add-Recommendation -Priority 2 -Message "System log contains $($diskData.ErrorCount) Disk error event(s) in the last 30 days; review controller, cable, power, and drive health." -Source "EventLog"
        }
        if ($ntfsData.ErrorCount -gt 0) {
            Add-Recommendation -Priority 2 -Message "System log contains $($ntfsData.ErrorCount) NTFS error event(s) in the last 30 days; review the affected volume." -Source "EventLog"
        }

        # WHEA events span a real severity range - Level 2 (Error) events are the ones worth
        # taking seriously; Level 3 (Warning, which includes routine "corrected" hardware
        # events) are common and not evidence the hardware is failing. Splitting them avoids
        # painting every WHEA warning as red, which previously made minor/expected corrected
        # events look as alarming as an actual uncorrected error.
        $wheaErrors = Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-WHEA-Logger'; Level=2; StartTime=$date} -ErrorAction SilentlyContinue
        $wheaWarnings = Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-WHEA-Logger'; Level=3; StartTime=$date} -ErrorAction SilentlyContinue
        $wheaErrCount = if ($wheaErrors) { @($wheaErrors).Count } else { 0 }
        $wheaWarnCount = if ($wheaWarnings) { @($wheaWarnings).Count } else { 0 }
        $wheaLastErr = if ($wheaErrCount -gt 0) { @($wheaErrors)[0].TimeCreated.ToString("yyyy-MM-dd HH:mm") } else { "None" }
        HtmlAdd ("WHEA Errors (uncorrected): " + $wheaErrCount + " (Last: " + $wheaLastErr + ")") $(if($wheaErrCount -gt 0){"#f44747"}else{"#4ec9b0"})
        HtmlAdd ("WHEA Warnings (corrected/informational): " + $wheaWarnCount) $(if($wheaWarnCount -gt 0){"#D7BA7D"}else{"#4ec9b0"})
        if ($wheaErrCount -gt 0) {
            Add-Recommendation -Priority 1 -Message "WHEA logged $wheaErrCount uncorrected hardware error(s) - investigate CPU, RAM, motherboard, power, and storage paths." -Source "Hardware"
        }
        
        $bsodCount = if ($bsodData) { @($bsodData).Count } else { 0 }
        $bsodLast = if ($bsodCount -gt 0) { @($bsodData)[0].TimeCreated.ToString("yyyy-MM-dd HH:mm") } else { "None" }
        HtmlAdd ("BSOD / Crash Events: " + $bsodCount + " (Last: " + $bsodLast + ")") $(if($bsodCount -gt 0){"#f44747"}else{"#4ec9b0"})
        if ($bsodCount -gt 0) {
            # A bugcheck was already painted red but produced no recommendation, so it never
            # reached the Recommended Actions list or the phase issue counts.
            Add-Recommendation -Priority 2 -Message "$bsodCount system crash (bugcheck) event(s) recorded in the last 30 days, most recently $bsodLast. Review the minidumps in $env:WINDIR\Minidump before treating this machine as healthy." -Source "EventLog"
        }
    } catch { HtmlAdd "Event Viewer parsing unavailable" "#808080"; Console-Warn "Event Viewer check skipped." }
    HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
}

# ----------------------------
# System Restoration (CHKDSK, DISM, SFC)
# ----------------------------
function Invoke-ChkDsk {
    param([pscustomobject]$diskTask)
    if (-not $Global:Ctx.OperationStatus.Contains("CHKDSK")) {
        Set-RaseOperationStatus -Name "CHKDSK" -Status ([HealthStatus]::OK)
    }
    if (-not $diskTask.DriveLetters) { return }
    foreach ($dl in $diskTask.DriveLetters) {
        # CHKDSK /scan is documented as NTFS-only - not FAT/FAT32/exFAT, and not ReFS.
        # ReFS volumes are verified separately via Repair-Volume -Scan (see Invoke-ReFSIntegrity).
        # This allow-lists NTFS explicitly rather than deny-listing ReFS, so a stray FAT32/exFAT
        # partition sharing the same physical disk (e.g. a recovery partition) doesn't get /scan.
        $volume = Get-Volume -DriveLetter $dl -ErrorAction SilentlyContinue
        if (-not $volume -or $volume.FileSystem -ne "NTFS") {
            $fsLabel = if ($volume) { $volume.FileSystem } else { "Unknown" }
            HtmlAdd ("Skipping CHKDSK for " + (ConvertTo-HtmlSafe $diskTask.DiskName) + " (" + $dl + ":) - file system is $fsLabel, not NTFS. /scan only applies to NTFS.") "#808080"
            continue
        }
        HtmlAdd ("CHKDSK Integrity Check for " + (ConvertTo-HtmlSafe $diskTask.DiskName) + " (" + $dl + ":)") "#569cd6"
        Console-Step ("CHKDSK " + $dl + ":")
        if (-not (Test-RaseDryRun "Run CHKDSK /scan on drive ${dl}:")) {
            try {
                Invoke-AnimatedTask -Activity "Checking Drive ${dl}:" -Command "chkdsk.exe" -Arguments "${dl}: /scan" -TimeoutSeconds $Global:Timeout_CHKDSK
                if ($Global:RaseLastTaskTimedOut) {
                    $Global:Ctx.Summary_CHKDSK += 1
                    Set-RaseOperationStatus -Name "CHKDSK" -Status ([HealthStatus]::Failed)
                    HtmlAdd "CHKDSK exceeded the ${Global:Timeout_CHKDSK}s timeout and was terminated - drive may be failing." "#f44747"
                    Add-Recommendation -Priority 1 -Message "CHKDSK on ${dl}: did not finish within the timeout. Inspect this drive's physical health immediately." -Source "CHKDSK"
                    foreach ($row in $Global:Ctx.DiskTable) { if ($row.Disk -eq "${dl}:") { $row.Status = "TimedOut" } }
                } elseif ($LASTEXITCODE -eq 0) {
                    HtmlAdd "CHKDSK scan completed. File system is healthy." "#4ec9b0"
                    foreach ($row in $Global:Ctx.DiskTable) { if ($row.Disk -eq "${dl}:") { $row.Status = "OK" } }
                } else {
                    $Global:Ctx.Summary_CHKDSK += 1
                    Set-RaseOperationStatus -Name "CHKDSK" -Status ([HealthStatus]::Failed)
                    HtmlAdd "CHKDSK found warnings or errors (Exit Code: $LASTEXITCODE)!" "#f44747"
                    Add-Recommendation -Priority 2 -Message "Schedule offline CHKDSK scan for ${dl}: (/f)." -Source "CHKDSK"
                    foreach ($row in $Global:Ctx.DiskTable) { if ($row.Disk -eq "${dl}:") { $row.Status = "Errors" } }
                }
            } catch { Set-RaseOperationStatus -Name "CHKDSK" -Status ([HealthStatus]::Failed); HtmlAdd "CHKDSK scan failed to execute." "#f44747"; $Global:Ctx.Summary_CHKDSK += 1; LogError "CHKDSK process failed." "CHKDSK" $_.Exception; Add-Recommendation -Priority 1 -Message "CHKDSK on ${dl}: failed to execute - $($_.Exception.Message)" -Source "CHKDSK"; foreach ($row in $Global:Ctx.DiskTable) { if ($row.Disk -eq "${dl}:") { $row.Status = "Errors" } } }
        }
        HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
    }
}

function Invoke-ReFSIntegrity { 
    HtmlAddSection "ReFS Integrity Check"
    Set-RaseOperationStatus -Name "ReFS" -Status ([HealthStatus]::OK)
    $refsVols = @(Get-Volume -ErrorAction SilentlyContinue | Where-Object { $_.FileSystem -eq "ReFS" -and $_.DriveLetter })
    if ($refsVols.Count -eq 0) {
        HtmlAdd "Skipped (no ReFS volumes detected on this system)." "#808080"
        Set-RaseOperationStatus -Name "ReFS" -Status ([HealthStatus]::Skipped)
        HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
        return
    }

    $cmdletAvailable = [bool](Get-Command Repair-Volume -ErrorAction SilentlyContinue)
    if (-not $cmdletAvailable) {
        Set-RaseOperationStatus -Name "ReFS" -Status ([HealthStatus]::Warning)
    }
    foreach ($vol in $refsVols) {
        $dl = $vol.DriveLetter
        if (-not $cmdletAvailable) {
            # Honest miss: a ReFS volume exists, but this system can't actually verify it -
            # never claim "verified" when no verification ran.
            HtmlAdd "${dl}: - ReFS integrity verification unavailable on this system (Repair-Volume cmdlet not present)." "#D7BA7D"
            Add-Recommendation -Priority 2 -Message "ReFS volume ${dl}: Repair-Volume is unavailable, so integrity could not be verified automatically." -Source "ReFS"
            continue
        }
        if ($DryRun) {
            HtmlAdd "${dl}: - ReFS scan skipped (DryRun mode)." "#D7BA7D"
            Set-RaseOperationStatus -Name "ReFS" -Status ([HealthStatus]::Skipped)
            continue
        }
        try {
            $scanJob = Invoke-RaseBackgroundJob -ScriptBlock { param($d) Repair-Volume -DriveLetter $d -Scan -ErrorAction Stop } -ArgumentList $dl -TimeoutSeconds $Global:Timeout_REFS
            if ($scanJob.Status -eq "TimedOut") {
                HtmlAdd "${dl}: - ReFS scan exceeded the timeout and was terminated." "#f44747"
                Set-RaseOperationStatus -Name "ReFS" -Status ([HealthStatus]::Failed)
                Add-Recommendation -Priority 1 -Message "ReFS scan on ${dl}: did not finish within the timeout. Investigate manually." -Source "ReFS"
                foreach ($row in $Global:Ctx.DiskTable) { if ($row.Disk -eq "${dl}:") { $row.Status = "TimedOut" } }
            } elseif ($scanJob.Status -in @("Error", "CommandNotFound")) {
                HtmlAdd "${dl}: - ReFS scan reported an error: $($scanJob.ErrorMessage)" "#f44747"
                Set-RaseOperationStatus -Name "ReFS" -Status ([HealthStatus]::Failed)
                Add-Recommendation -Priority 1 -Message "ReFS scan on ${dl}: reported an error - investigate." -Source "ReFS"
                foreach ($row in $Global:Ctx.DiskTable) { if ($row.Disk -eq "${dl}:") { $row.Status = "Errors" } }
            } else {
                # Repair-Volume itself returns nothing reliably parseable across PS versions, so the
                # authoritative post-condition is the volume's HealthStatus after the scan.
                $postVol = Get-Volume -DriveLetter $dl -ErrorAction SilentlyContinue
                if ($postVol -and $postVol.HealthStatus -eq "Healthy") {
                    HtmlAdd "${dl}: - ReFS scan completed. Volume reports Healthy." "#4ec9b0"
                    foreach ($row in $Global:Ctx.DiskTable) { if ($row.Disk -eq "${dl}:") { $row.Status = "OK" } }
                } else {
                    $hs = if ($postVol) { $postVol.HealthStatus } else { "Unknown" }
                    HtmlAdd "${dl}: - ReFS scan completed. Volume health: $hs." "#D7BA7D"
                    Set-RaseOperationStatus -Name "ReFS" -Status ([HealthStatus]::Warning)
                    Add-Recommendation -Priority 2 -Message "ReFS volume ${dl}: reported health status '$hs' after scan - investigate." -Source "ReFS"
                    foreach ($row in $Global:Ctx.DiskTable) { if ($row.Disk -eq "${dl}:") { $row.Status = "Errors" } }
                }
            }
        } catch {
            HtmlAdd "${dl}: - ReFS scan failed to execute." "#f44747"
            Set-RaseOperationStatus -Name "ReFS" -Status ([HealthStatus]::Failed)
            LogError "Repair-Volume -Scan failed for ${dl}:." "ReFS" $_.Exception
            Add-Recommendation -Priority 1 -Message "ReFS integrity scan on ${dl} failed to execute. Review the error details and rerun the diagnostic after resolving the underlying issue." -Source "ReFS"
            foreach ($row in $Global:Ctx.DiskTable) { if ($row.Disk -eq "${dl}:") { $row.Status = "Errors" } }
        }
    }
    HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080" 
}

function Invoke-DirtyBitCheck {
    HtmlAddSection "Dirty Bit Check"
    Set-RaseOperationStatus -Name "DirtyBit" -Status ([HealthStatus]::OK)
    if ($Global:Ctx.DiskTable.Count -eq 0) {
        HtmlAdd "No NTFS/ReFS volumes available to check." "#808080"
        HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
        return
    }

    # Win32_Volume.DirtyBitSet is a structured Boolean property and is the primary source.
    # This avoids parsing localized fsutil output and avoids treating an undocumented process
    # exit code as the semantic state of the volume.
    $volumes = @()
    try {
        $volumes = @(Get-CimInstance Win32_Volume -ErrorAction Stop)
    } catch {
        Set-RaseOperationStatus -Name "DirtyBit" -Status ([HealthStatus]::Warning)
        HtmlAdd "Win32_Volume query failed; dirty-bit state could not be determined." "#D7BA7D"
        LogError "Win32_Volume query failed." "DirtyBit" $_.Exception
        Add-Recommendation -Priority 2 -Message "Dirty-bit state could not be determined automatically. Review volume state manually." -Source "DirtyBit"
        HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
        return
    }

    # Volumes whose state cannot be resolved are collected and reported in one recommendation
    # at the end. One entry per volume produced four near-identical lines on a four-volume
    # machine - the same duplication that was removed from the Safety Gate in v73.4.
    $unresolvedVolumes = @()

    foreach ($row in $Global:Ctx.DiskTable) {
        $dl = $row.Disk.TrimEnd(':') + ':'

        # Only the lookup is guarded. Since v73.5.1 the CIM query runs once above the loop, so
        # everything else here is in-memory work that cannot throw; the old per-row catch set a
        # Failed status that was already unreachable.
        $volume = $null
        try { $volume = $volumes | Where-Object { $_.DriveLetter -eq $dl } | Select-Object -First 1 }
        catch { $volume = $null }

        $dirtyProp = if ($volume) { $volume.PSObject.Properties['DirtyBitSet'] } else { $null }

        if ($null -eq $dirtyProp -or $null -eq $dirtyProp.Value) {
            Set-RaseOperationStatus -Name "DirtyBit" -Status ([HealthStatus]::Warning)
            HtmlAdd "$($row.Disk) - dirty bit state is unavailable." "#D7BA7D"
            $unresolvedVolumes += $row.Disk
            continue
        }

        if ([bool]$dirtyProp.Value) {
            HtmlAdd "$($row.Disk) - DIRTY (a CHKDSK repair is scheduled on next reboot)" "#f44747"
            if ($row.Status -eq "OK") { $row.Status = "DIRTY" }
            Set-RaseOperationStatus -Name "DirtyBit" -Status ([HealthStatus]::Warning)
            Add-Recommendation -Priority 1 -Message "$($row.Disk) is marked dirty - reboot to let the scheduled CHKDSK repair run, or run CHKDSK /f manually." -Source "DirtyBit"
        } else {
            HtmlAdd "$($row.Disk) - CLEAN" "#4ec9b0"
        }
    }

    if ($unresolvedVolumes.Count -gt 0) {
        Add-Recommendation -Priority 2 -Message ("Dirty-bit state could not be determined for: " + ($unresolvedVolumes -join ', ') + ". Run 'fsutil dirty query <drive>:' on those volumes to confirm.") -Source "DirtyBit"
    }
    HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
}

function Invoke-RaseBackgroundJob {
    param(
        [Parameter(Mandatory)][scriptblock]$ScriptBlock,
        [object[]]$ArgumentList = @(),
        [int]$TimeoutSeconds
    )
    # Start-Job is retained here because Repair-WindowsImage/Repair-Volume may need module
    # auto-loading in their own PowerShell process. The wrapper is deliberately defensive:
    # every path performs cleanup, including timeout and unexpected exceptions, so a failed
    # maintenance operation cannot leave an orphaned job/process behind.
    # Wait-Job -Timeout 0 returns immediately, which this wrapper would then report as
    # "TimedOut" - a silent, instant failure for any caller that forgot the parameter.
    # Clamping to the DISM timeout keeps an omitted value harmless instead of catastrophic.
    if ($TimeoutSeconds -le 0) { $TimeoutSeconds = $Global:Timeout_DISM }

    $job = $null
    try {
        if ($ArgumentList.Count -gt 0) {
            $job = Start-Job -ScriptBlock $ScriptBlock -ArgumentList $ArgumentList -ErrorAction Stop
        } else {
            $job = Start-Job -ScriptBlock $ScriptBlock -ErrorAction Stop
        }

        $done = Wait-Job -Job $job -Timeout $TimeoutSeconds -ErrorAction SilentlyContinue
        if (-not $done) {
            Stop-Job -Job $job -ErrorAction SilentlyContinue
            return [pscustomobject]@{ Status = "TimedOut"; Result = $null; ErrorMessage = $null }
        }

        $jobErrors = @()
        if ($job.ChildJobs.Count -gt 0) {
            $jobErrors = @($job.ChildJobs[0].Error)
        }
        $result = Receive-Job -Job $job -ErrorAction SilentlyContinue

        if ($jobErrors.Count -gt 0) {
            $firstError = $jobErrors[0]
            $isCommandNotFound = ($firstError.Exception -is [System.Management.Automation.CommandNotFoundException]) -or
                                 ($firstError.CategoryInfo.Category -eq 'ObjectNotFound')
            $status = if ($isCommandNotFound) { "CommandNotFound" } else { "Error" }
            return [pscustomobject]@{ Status = $status; Result = $result; ErrorMessage = $firstError.Exception.Message }
        }

        return [pscustomobject]@{ Status = "Success"; Result = $result; ErrorMessage = $null }
    }
    catch {
        return [pscustomobject]@{ Status = "Error"; Result = $null; ErrorMessage = $_.Exception.Message }
    }
    finally {
        if ($null -ne $job) {
            try { if ($job.State -eq "Running") { Stop-Job -Job $job -ErrorAction SilentlyContinue } } catch {}
            try { Remove-Job -Job $job -Force -ErrorAction SilentlyContinue } catch {}
        }
    }
}

function Invoke-Dism {
    HtmlAddSection "DISM Component Health Check"
    if ($Global:Ctx.PendingReboot) { HtmlAdd "Pending reboot detected. Results may not reflect final system state." "#D7BA7D" }
    Console-Step "DISM ScanHealth"
    if (-not $DryRun) {
        try {
            # Locale-independent path first: Repair-WindowsImage returns a structured
            # ImageHealthState enum (Healthy/Repairable/NonRepairable), not localized text.
            # No parent-process availability pre-check - the job's own outcome (including
            # "cmdlet not found there") drives whether we fall back to dism.exe.
            $scanJob = Invoke-RaseBackgroundJob -ScriptBlock { Repair-WindowsImage -Online -ScanHealth } -TimeoutSeconds $Global:Timeout_DISM

            if ($scanJob.Status -eq "TimedOut") {
                HtmlAdd "DISM ScanHealth exceeded the ${Global:Timeout_DISM}s timeout and was terminated." "#f44747"
                $Global:Ctx.DISM_Status = [HealthStatus]::Failed
                Add-Recommendation -Priority 1 -Message "DISM ScanHealth did not finish within the timeout - investigate manually." -Source "DISM"
            } elseif ($scanJob.Status -eq "CommandNotFound") {
                Invoke-DismLegacyPath
            } elseif ($scanJob.Status -eq "Error") {
                HtmlAdd "DISM ScanHealth failed: $($scanJob.ErrorMessage)" "#f44747"
                $Global:Ctx.DISM_Status = [HealthStatus]::Failed
                Add-Recommendation -Priority 1 -Message "DISM ScanHealth failed: $($scanJob.ErrorMessage)" -Source "DISM"
            } elseif ($scanJob.Result -and $scanJob.Result.PSObject.Properties['ImageHealthState'] -and $scanJob.Result.ImageHealthState -eq "Healthy") {
                HtmlAdd "DISM ScanHealth: No corruption detected." "#4ec9b0"
                $Global:Ctx.DISM_Status = [HealthStatus]::OK
            } elseif ($scanJob.Result -and $scanJob.Result.PSObject.Properties['ImageHealthState']) {
                HtmlAdd "DISM ScanHealth reports state: $($scanJob.Result.ImageHealthState). Running RestoreHealth..." "#D7BA7D"
                Console-Step "DISM RestoreHealth"
                $repairJob = Invoke-RaseBackgroundJob -ScriptBlock { Repair-WindowsImage -Online -RestoreHealth } -TimeoutSeconds $Global:Timeout_DISM

                if ($repairJob.Status -eq "TimedOut") {
                    HtmlAdd "DISM RestoreHealth exceeded the ${Global:Timeout_DISM}s timeout and was terminated." "#f44747"
                    $Global:Ctx.DISM_Status = [HealthStatus]::Failed
                    Add-Recommendation -Priority 1 -Message "DISM RestoreHealth did not finish within the timeout - investigate manually." -Source "DISM"
                } elseif ($repairJob.Status -eq "CommandNotFound") {
                    # ScanHealth found the cmdlet fine, but RestoreHealth's job somehow didn't -
                    # extremely unlikely in the same session, but fall back safely regardless.
                    Invoke-DismLegacyPath -SkipScan
                } elseif ($repairJob.Status -eq "Error") {
                    HtmlAdd "DISM RestoreHealth failed: $($repairJob.ErrorMessage)" "#f44747"
                    $Global:Ctx.DISM_Status = [HealthStatus]::Failed
                    Add-Recommendation -Priority 1 -Message "Investigate unresolved Component Store corruption (DISM): $($repairJob.ErrorMessage)" -Source "DISM"
                } elseif ($repairJob.Result -and $repairJob.Result.PSObject.Properties['ImageHealthState'] -and ($repairJob.Result.ImageHealthState -eq "Healthy" -or ($repairJob.Result.PSObject.Properties['RestoreHealthResult'] -and $repairJob.Result.RestoreHealthResult -eq $true))) {
                    HtmlAdd "DISM RestoreHealth repaired the Component Store successfully." "#4ec9b0"
                    $Global:Ctx.DISM_Status = [HealthStatus]::Repaired
                } else {
                    $dismState = if ($repairJob.Result -and $repairJob.Result.PSObject.Properties['ImageHealthState']) { $repairJob.Result.ImageHealthState } else { "Unknown" }
                    HtmlAdd "DISM failed to confirm a healthy Component Store after RestoreHealth (State: $dismState)." "#f44747"
                    $Global:Ctx.DISM_Status = [HealthStatus]::Failed
                    Add-Recommendation -Priority 1 -Message "Investigate unresolved Component Store corruption (DISM)." -Source "DISM"
                }
            } else {
                HtmlAdd "DISM ScanHealth returned an unusable result object; RestoreHealth was not started automatically." "#D7BA7D"
                $Global:Ctx.DISM_Status = [HealthStatus]::Warning
                Add-Recommendation -Priority 2 -Message "DISM ScanHealth completed but returned no structured health state." -Source "DISM"
            }
        } catch { $Global:Ctx.DISM_Status = [HealthStatus]::Failed; HtmlAdd "DISM execution failed." "#f44747"; LogError "DISM process exception." "DISM" $_.Exception; Add-Recommendation -Priority 1 -Message "DISM execution failed: $($_.Exception.Message)" -Source "DISM" }
    }
    # Mirror the detailed DISM_Status into the unified registry so DISM appears in the phase
    # issue table and the exit-code check through the same path as every other operation.
    Set-RaseOperationStatus -Name "DISM" -Status $Global:Ctx.DISM_Status
    HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
}

function Invoke-DismLegacyPath {
    param([switch]$SkipScan)
    # Legacy fallback: Repair-WindowsImage isn't resolving (verified via actual job failure,
    # not a parent-process guess). Text-matching dism.exe output is best-effort and
    # locale-dependent - flagged clearly in the report.
    HtmlAdd "Repair-WindowsImage cmdlet unavailable - falling back to dism.exe text parsing (locale-dependent)." "#D7BA7D"
    if (-not $SkipScan) {
        $dismOutput = Invoke-AnimatedTask -Activity "DISM ScanHealth" -Command "DISM.exe" -Arguments "/Online /Cleanup-Image /ScanHealth" -CaptureOutput -TimeoutSeconds $Global:Timeout_DISM
        if ($Global:RaseLastTaskTimedOut) {
            HtmlAdd "DISM ScanHealth exceeded the ${Global:Timeout_DISM}s timeout and was terminated." "#f44747"
            $Global:Ctx.DISM_Status = [HealthStatus]::Failed
            return
        } elseif ($LASTEXITCODE -ne 0) {
            # Check the exit code before interpreting output text - a non-zero exit means
            # ScanHealth itself didn't complete properly, which is different from "ran fine
            # and found anomalies". Treating this as "anomalies found" would have sent it
            # straight into RestoreHealth for the wrong reason.
            HtmlAdd "DISM ScanHealth did not complete successfully (Exit Code: $LASTEXITCODE)." "#f44747"
            $Global:Ctx.DISM_Status = [HealthStatus]::Failed
            Add-Recommendation -Priority 1 -Message "DISM ScanHealth failed (Exit Code: $LASTEXITCODE) - investigate manually." -Source "DISM"
            return
        } elseif ($dismOutput -match "(?i)No component store corruption detected") {
            HtmlAdd "DISM ScanHealth: No corruption detected." "#4ec9b0"
            $Global:Ctx.DISM_Status = [HealthStatus]::OK
            return
        } elseif ($dismOutput -match "(?i)component store is repairable") {
            HtmlAdd "DISM ScanHealth detected repairable corruption. Running RestoreHealth..." "#D7BA7D"
            Console-Step "DISM RestoreHealth"
        } else {
            # dism.exe states its verdict as fully localized prose, and this fallback path only
            # runs when the Repair-WindowsImage cmdlet - which returns a locale-independent
            # ImageHealthState - is unavailable. On a non-English installation neither phrase
            # above matches, and the previous behaviour was to assume corruption and launch a
            # full RestoreHealth: a long, network-dependent repair triggered by no evidence at
            # all. Saying what could not be determined is the correct answer here.
            HtmlAdd "DISM ScanHealth completed (Exit Code 0), but its verdict could not be interpreted. dism.exe reports the result in the Windows display language, and the Repair-WindowsImage cmdlet is not available on this system." "#D7BA7D"
            $Global:Ctx.DISM_Status = [HealthStatus]::Warning
            Add-Recommendation -Priority 2 -Message "Component Store health could not be determined automatically on this system. Run 'DISM /Online /Cleanup-Image /ScanHealth' manually and review its output." -Source "DISM"
            return
        }
    }
    $null = Invoke-AnimatedTask -Activity "DISM RestoreHealth" -Command "DISM.exe" -Arguments "/Online /Cleanup-Image /RestoreHealth" -CaptureOutput -TimeoutSeconds $Global:Timeout_DISM
    if ($Global:RaseLastTaskTimedOut) {
        HtmlAdd "DISM RestoreHealth exceeded the ${Global:Timeout_DISM}s timeout and was terminated." "#f44747"
        $Global:Ctx.DISM_Status = [HealthStatus]::Failed
    } elseif ($LASTEXITCODE -eq 0) { 
        HtmlAdd "DISM RestoreHealth repaired the Component Store successfully." "#4ec9b0"
        $Global:Ctx.DISM_Status = [HealthStatus]::Repaired
    } else { 
        HtmlAdd "DISM failed to repair Component Store (Exit Code: $LASTEXITCODE)." "#f44747"
        $Global:Ctx.DISM_Status = [HealthStatus]::Failed
        Add-Recommendation -Priority 1 -Message "Investigate unresolved Component Store corruption (DISM)." -Source "DISM"
    }
}

function ConvertTo-RaseCbsTimestamp {
    param([AllowNull()][string]$Line)
    if ([string]::IsNullOrWhiteSpace($Line)) { return $null }

    # CBS.log timestamps are normally ISO-like and are not localized. Parse the timestamp as
    # data rather than comparing the source line as a string. Accept the common second and
    # fractional-second forms emitted by CBS; unparseable records remain outside the evidence
    # window instead of influencing the SFC verdict.
    $m = [regex]::Match($Line, '^(?<ts>\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}(?:[\.,]\d{1,7})?)')
    if (-not $m.Success) { return $null }
    $text = $m.Groups['ts'].Value.Replace(',', '.')
    # The regex accepts \s+ between the date and the time, but TryParseExact expects exactly one
    # space. Without this, a CBS line padded with two spaces would be counted as an unparseable
    # record and silently dropped from the evidence window.
    $text = [regex]::Replace($text, '\s+', ' ')
    $formats = @('yyyy-MM-dd HH:mm:ss.FFFFFFF','yyyy-MM-dd HH:mm:ss')
    foreach ($format in $formats) {
        $parsed = [datetime]::MinValue
        if ([datetime]::TryParseExact($text, $format, [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::AssumeLocal, [ref]$parsed)) {
            return $parsed
        }
    }
    return $null
}

function Get-CbsRepairSummary {
    param([datetime]$Since)
    $cbsPath = "$env:WINDIR\Logs\CBS\CBS.log"
    if (-not (Test-Path $cbsPath)) {
        return [pscustomobject]@{ Found = $false; Unrepairable = $false; Repaired = $false; ParseFailures = 0 }
    }
    try {
        # CBS.log entries use fixed, locale-independent tokens. Timestamp filtering is performed
        # with parsed DateTime values so lexical ordering cannot create false time-window matches.
        $lines = Get-Content -Path $cbsPath -Tail 20000 -ErrorAction Stop
        $relevant = @()
        $parseFailures = 0
        foreach ($line in $lines) {
            if ($line -notmatch '\[SR\]') { continue }
            $lineTime = ConvertTo-RaseCbsTimestamp -Line $line
            if ($null -eq $lineTime) {
                $parseFailures++
                continue
            }
            if ($lineTime -ge $Since) {
                $relevant += $line
            }
        }
        $unrepairable = @($relevant | Where-Object { $_ -match 'Cannot repair member file' }).Count -gt 0
        $repaired     = @($relevant | Where-Object { $_ -match 'Repairing corrupted file' }).Count -gt 0
        return [pscustomobject]@{
            Found = ($relevant.Count -gt 0)
            Unrepairable = [bool]$unrepairable
            Repaired = [bool]$repaired
            ParseFailures = $parseFailures
        }
    } catch {
        return [pscustomobject]@{ Found = $false; Unrepairable = $false; Repaired = $false; ParseFailures = 0 }
    }
}

function Invoke-Sfc {
    HtmlAddSection "SFC System File Check"
    if ($Global:Ctx.PendingReboot) { HtmlAdd "Pending reboot detected. Results may not reflect final system state." "#D7BA7D" }
    Console-Step "SFC Scannow"
    if (-not $DryRun) {
        $scanStart = Get-Date
        try {
            $null = Invoke-AnimatedTask -Activity "SFC Scannow" -Command "sfc.exe" -Arguments "/scannow" -CaptureOutput -TimeoutSeconds $Global:Timeout_SFC
            if ($Global:RaseLastTaskTimedOut) {
                HtmlAdd "SFC Scannow exceeded the ${Global:Timeout_SFC}s timeout and was terminated." "#f44747"
                $Global:Ctx.SFC_Status = [HealthStatus]::Failed
                Add-Recommendation -Priority 1 -Message "SFC /scannow did not finish within the timeout - investigate manually." -Source "SFC"
            } else {
                $sfcExitCode = $LASTEXITCODE
                $cbs = Get-CbsRepairSummary -Since $scanStart

                if ($cbs.Found -and $cbs.Unrepairable) {
                    # An explicit unrepairable CBS finding is the strongest available evidence.
                    HtmlAdd "SFC found corrupt files but was unable to fix some of them (per CBS.log)." "#f44747"
                    $Global:Ctx.SFC_Status = [HealthStatus]::Failed
                    Add-Recommendation -Priority 1 -Message "Investigate unresolved System File corruption (SFC)." -Source "SFC"
                } elseif ($sfcExitCode -eq 0 -and $cbs.Found -and $cbs.Repaired) {
                    # Both signals agree, so this is the one case where CBS evidence is safe to
                    # promote: the process finished cleanly AND the [SR] records inside this run's
                    # own time window show files being repaired. sfc.exe returns 0 both for
                    # "nothing was wrong" and for "something was wrong and I fixed it", so CBS is
                    # the only thing that separates them. Collapsing this into a plain OK erases
                    # the fact that the system HAD corruption, and skips the 5-point System
                    # Integrity penalty that Repaired carries - the run would score identically to
                    # one where nothing was ever broken.
                    HtmlAdd "SFC found corrupt files and repaired them (exit code 0, confirmed by CBS.log within the run window)." "#4ec9b0"
                    $Global:Ctx.SFC_Status = [HealthStatus]::Repaired
                } elseif ($sfcExitCode -eq 0) {
                    HtmlAdd "SFC verification completed. No integrity violations reported." "#4ec9b0"
                    $Global:Ctx.SFC_Status = [HealthStatus]::OK
                } elseif ($cbs.Found -and $cbs.Repaired) {
                    # Non-zero execution result plus scoped repair evidence is useful, but the
                    # process did not return a clean success code, so do not overstate it as OK.
                    HtmlAdd "SFC reported a non-zero exit code ($sfcExitCode), but CBS.log shows repair activity within the run window." "#D7BA7D"
                    $Global:Ctx.SFC_Status = [HealthStatus]::Warning
                    Add-Recommendation -Priority 2 -Message "SFC returned exit code $sfcExitCode despite CBS.log repair activity. Review CBS.log and rerun SFC if necessary." -Source "SFC"
                } else {
                    HtmlAdd "SFC returned a non-zero exit code ($sfcExitCode) and CBS.log gave no clear repair verdict - treat as unresolved." "#D7BA7D"
                    $Global:Ctx.SFC_Status = [HealthStatus]::Warning
                    Add-Recommendation -Priority 2 -Message "SFC returned exit code $sfcExitCode without a clear CBS.log repair verdict. Review the CBS log manually." -Source "SFC"
                }

                if ($cbs.ParseFailures -gt 0) {
                    HtmlAdd "CBS.log: $($cbs.ParseFailures) [SR] record(s) had unparseable timestamps and were excluded from the SFC evidence window." "#808080"
                }
            }
        } catch {
            $Global:Ctx.SFC_Status = [HealthStatus]::Failed
            HtmlAdd "SFC execution failed." "#f44747"
            LogError "SFC process exception." "SFC" $_.Exception
            Add-Recommendation -Priority 1 -Message "SFC execution failed: $($_.Exception.Message)" -Source "SFC"
        }
    }
    Set-RaseOperationStatus -Name "SFC" -Status $Global:Ctx.SFC_Status
    HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
}

# ----------------------------
# Adaptive Cleanup Engine
# ----------------------------
function Invoke-CleanupEngine {
    param([pscustomobject]$Plan)
    HtmlAddSection "Adaptive Cleanup Engine"

    if ($Plan.CleanupTasks -contains "Windows Update Cache Cleanup") {
        Console-Step "Windows Update Cache Cleanup"
        if (Test-RaseDryRun "Clear Windows Update Download cache") {
            Set-RaseOperationStatus -Name "Cleanup:WU" -Status ([HealthStatus]::Skipped)
        }
        else {
            $wuauservWasRunning = $false
            $bitsWasRunning = $false
            $wuStateCaptured = $false
            try {
                # Capture original service state before touching either service. A write operation
                # is allowed only after both services are confirmed stopped; otherwise the cache
                # is left untouched rather than guessing that Stop-Service succeeded.
                $wuauserv = Get-Service wuauserv -ErrorAction SilentlyContinue
                $bits = Get-Service bits -ErrorAction SilentlyContinue
                $wuauservWasRunning = $null -ne $wuauserv -and $wuauserv.Status -eq "Running"
                $bitsWasRunning = $null -ne $bits -and $bits.Status -eq "Running"
                $wuStateCaptured = $true

                if ($null -ne $wuauserv) { Stop-Service wuauserv -Force -ErrorAction Stop }
                if ($null -ne $bits) { Stop-Service bits -Force -ErrorAction Stop }

                $wuauservNow = Get-Service wuauserv -ErrorAction SilentlyContinue
                $bitsNow = Get-Service bits -ErrorAction SilentlyContinue
                if (($null -ne $wuauservNow -and $wuauservNow.Status -eq "Running") -or ($null -ne $bitsNow -and $bitsNow.Status -eq "Running")) {
                    throw "Windows Update/BITS could not be confirmed stopped; cache deletion was aborted for safety."
                }

                $wuPath = "$env:WINDIR\SoftwareDistribution\Download"
                $deleted = 0; $failed = 0; $freedBytes = 0
                if (Test-Path $wuPath) {
                    foreach ($item in @(Get-ChildItem -Path $wuPath -Force -ErrorAction SilentlyContinue)) {
                        try {
                            $size = if ($item.PSIsContainer) { (Get-ChildItem $item.FullName -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum } else { $item.Length }
                            Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction Stop
                            $deleted++; if ($size) { $freedBytes += $size }
                        } catch { $failed++ }
                    }
                }

                $freedMB = [math]::Round($freedBytes / 1MB, 1)
                if ($failed -eq 0) {
                    HtmlAdd "Windows Update Cache cleared. Removed $deleted item(s), freed ~$freedMB MB." "#4ec9b0"
                    Set-RaseOperationStatus -Name "Cleanup:WU" -Status ([HealthStatus]::OK)
                } elseif ($failed -gt 0) {
                    if ($deleted -gt 0) {
                        HtmlAdd "Windows Update Cache partially cleared. Removed $deleted item(s) (~$freedMB MB); $failed item(s) could not be removed (likely in use)." "#D7BA7D"
                    } else {
                        HtmlAdd "Windows Update Cache cleanup encountered $failed item(s) that could not be removed. No items were successfully deleted." "#D7BA7D"
                    }
                    Add-Recommendation -Priority 3 -Message "$failed Windows Update cache item(s) could not be removed - likely locked/in use. Retry after a reboot if space is needed." -Source "Cleanup:WU"
                    Set-RaseOperationStatus -Name "Cleanup:WU" -Status ([HealthStatus]::Warning)
                } else {
                    HtmlAdd "Windows Update Cache cleanup found nothing removable (0 items)." "#808080"
                    Set-RaseOperationStatus -Name "Cleanup:WU" -Status ([HealthStatus]::OK)
                }
            } catch {
                HtmlAdd "Windows Update cache cleanup failed: $($_.Exception.Message)" "#f44747"
                LogError "Windows Update cache cleanup failed." "Cleanup:WU" $_.Exception
                Set-RaseOperationStatus -Name "Cleanup:WU" -Status ([HealthStatus]::Failed)
                Add-Recommendation -Priority 1 -Message "Windows Update cache cleanup failed. Review the error details before rerunning maintenance." -Source "Cleanup:WU"
            } finally {
                if ($wuStateCaptured) {
                    try {
                        if ($wuauservWasRunning) { Start-Service wuauserv -ErrorAction Stop }
                        else { Stop-Service wuauserv -Force -ErrorAction SilentlyContinue }
                    } catch {
                        HtmlAdd "Could not restore Windows Update service state: $($_.Exception.Message)" "#f44747"
                        LogError "Failed to restore wuauserv state." "Cleanup:WU" $_.Exception
                        Set-RaseOperationStatus -Name "Cleanup:WU" -Status ([HealthStatus]::Failed)
                    }
                    try {
                        if ($bitsWasRunning) { Start-Service bits -ErrorAction Stop }
                        else { Stop-Service bits -Force -ErrorAction SilentlyContinue }
                    } catch {
                        HtmlAdd "Could not restore BITS service state: $($_.Exception.Message)" "#f44747"
                        LogError "Failed to restore BITS state." "Cleanup:WU" $_.Exception
                        Set-RaseOperationStatus -Name "Cleanup:WU" -Status ([HealthStatus]::Failed)
                    }
                }
            }
        }
    }

    if ($Plan.CleanupTasks -contains "Temp Cleanup") {
        Console-Step "Temp Cleanup (72-Hour Rule)"
        if (Test-RaseDryRun "Remove temporary files older than 72 hours") {
            Set-RaseOperationStatus -Name "Cleanup:Temp" -Status ([HealthStatus]::Skipped)
        }
        else {
            try {
                $tempPaths = @("$env:TEMP", "$env:WINDIR\Temp")
                $threshold = (Get-Date).AddDays(-3)
                $deleted = 0; $failed = 0; $freedBytes = 0
                foreach ($path in $tempPaths) {
                    if (Test-Path $path) {
                        $matched = @(Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { $_.LastWriteTime -lt $threshold })
                        foreach ($f in ($matched | Where-Object { -not $_.PSIsContainer })) {
                            try { Remove-Item -Path $f.FullName -Force -ErrorAction Stop; $deleted++; $freedBytes += $f.Length }
                            catch { $failed++ }
                        }
                        # Never recursively delete a directory just because the directory itself is
                        # older than 72 hours. It may contain a recently modified file that was not in
                        # $matched. Only remove directories that are empty after the individual-file pass.
                        foreach ($d in ($matched | Where-Object { $_.PSIsContainer } | Sort-Object { $_.FullName.Length } -Descending)) {
                            try {
                                $remaining = @(Get-ChildItem -LiteralPath $d.FullName -Force -ErrorAction SilentlyContinue)
                                if ($remaining.Count -eq 0) {
                                    Remove-Item -LiteralPath $d.FullName -Force -ErrorAction Stop
                                    $deleted++
                                }
                            } catch {}
                        }
                    }
                }
                $freedMB = [math]::Round($freedBytes / 1MB, 1)
                if ($failed -eq 0) {
                    HtmlAdd "Temporary files older than 72 hours cleared. Removed $deleted item(s), freed ~$freedMB MB." "#4ec9b0"
                    Set-RaseOperationStatus -Name "Cleanup:Temp" -Status ([HealthStatus]::OK)
                } elseif ($deleted -gt 0) {
                    HtmlAdd "Temp cleanup partially completed. Removed $deleted item(s) (~$freedMB MB); $failed file(s) could not be removed (likely in use)." "#D7BA7D"
                    Add-Recommendation -Priority 3 -Message "$failed temporary file(s) could not be removed - likely locked/in use." -Source "Cleanup:Temp"
                    Set-RaseOperationStatus -Name "Cleanup:Temp" -Status ([HealthStatus]::Warning)
                } else {
                    HtmlAdd "Temp cleanup found nothing removable, or all matched files were in use." "#808080"
                    Set-RaseOperationStatus -Name "Cleanup:Temp" -Status ([HealthStatus]::Warning)
                    Add-Recommendation -Priority 3 -Message "Temporary cleanup could not remove any matched files; verify whether files are locked if cleanup is required." -Source "Cleanup:Temp"
                }
            } catch {
                HtmlAdd "Temporary file cleanup encountered errors." "#f44747"
                LogError "Temporary cleanup failed." "Cleanup:Temp" $_.Exception
                Set-RaseOperationStatus -Name "Cleanup:Temp" -Status ([HealthStatus]::Failed)
            }
        }
    }
    
    if ($Plan.CleanupTasks -contains "Recycle Bin Cleanup") {
        Console-Step "Recycle Bin Cleanup"
        if (Test-RaseDryRun "Empty the Recycle Bin") {
            Set-RaseOperationStatus -Name "Cleanup:RecycleBin" -Status ([HealthStatus]::Skipped)
        }
        else {
            $recycleStatus = [HealthStatus]::OK
            try {
                Clear-RecycleBin -Force -ErrorAction Stop
                HtmlAdd "Recycle Bin cleared via Native Command." "#4ec9b0"
            }
            catch {
                try {
                    $shell = New-Object -ComObject Shell.Application
                    $recycle = $shell.NameSpace(0xA)
                    if ($recycle) {
                        $items = @($recycle.Items())
                        $deleted = 0; $failed = 0
                        foreach ($item in $items) {
                            try { Remove-Item -Path $item.Path -Recurse -Force -ErrorAction Stop; $deleted++ }
                            catch { $failed++ }
                        }
                        if ($items.Count -eq 0) {
                            HtmlAdd "Recycle Bin already empty." "#808080"
                        } elseif ($failed -eq 0) {
                            HtmlAdd "Recycle Bin cleared via COM fallback. Removed $deleted item(s)." "#4ec9b0"
                        } elseif ($deleted -gt 0) {
                            $recycleStatus = [HealthStatus]::Warning
                            HtmlAdd "Recycle Bin partially cleared via COM fallback. Removed $deleted item(s); $failed item(s) could not be removed." "#D7BA7D"
                            Add-Recommendation -Priority 3 -Message "$failed Recycle Bin item(s) could not be removed - likely locked/in use." -Source "Cleanup:RecycleBin"
                        } else {
                            $recycleStatus = [HealthStatus]::Failed
                            throw "Recycle Bin fallback could not remove any item."
                        }
                    } else { throw "Recycle Bin COM namespace unavailable." }
                } catch {
                    $recycleStatus = [HealthStatus]::Failed
                    HtmlAdd "Recycle Bin cleanup failed." "#f44747"
                    LogError "Recycle Bin cleanup failed." "Cleanup:RecycleBin" $_.Exception
                }
            }
            Set-RaseOperationStatus -Name "Cleanup:RecycleBin" -Status $recycleStatus
        }
    }
    HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
}
# ----------------------------
# Optimization & Tuning
# ----------------------------
function Invoke-Trim {
    param([pscustomobject]$diskTask)
    if (-not $Global:Ctx.OperationStatus.Contains("TRIM")) {
        Set-RaseOperationStatus -Name "TRIM" -Status ([HealthStatus]::OK)
    }
    # Definite SSD/NVMe always qualifies. "Unspecified" media only qualifies if SpindleSpeed
    # explicitly confirms non-rotational (0) - an adaptive engine should stay conservative
    # about ambiguous media rather than assuming "Unspecified" means SSD.
    $isDefiniteSsd = ($diskTask.MediaType -eq "SSD") -or ($diskTask.BusType -eq "NVMe")
    $isConfirmedNonRotational = ($diskTask.MediaType -eq "Unspecified") -and ($null -ne $diskTask.SpindleSpeed) -and ($diskTask.SpindleSpeed -eq 0)
    if (-not $isDefiniteSsd -and -not $isConfirmedNonRotational) {
        foreach ($row in $Global:Ctx.DiskTable) {
            if ($row.Name -eq $diskTask.DiskName) { $row.TrimStatus = "NotApplicable" }
        }
        return
    }
    if (-not $diskTask.DriveLetters) { return }
    
    foreach ($dl in $diskTask.DriveLetters) {
        # Per-volume safety: if CHKDSK/ReFS already found this specific volume Dirty/Errors/
        # TimedOut, don't run a write operation (TRIM) against it - a phase-level dependency
        # wouldn't catch this, since CHKDSK/DISM/SFC each catch their own errors and let
        # Restoration finish "successfully" at the phase level even when a disk has real issues.
        $volRow = $Global:Ctx.DiskTable | Where-Object { $_.Disk -eq "${dl}:" } | Select-Object -First 1
        if ($volRow -and $volRow.Status -in @("DIRTY", "Errors", "TimedOut")) {
            HtmlAdd ("Skipping TRIM for " + (ConvertTo-HtmlSafe $diskTask.DiskName) + " (" + $dl + ":) - volume status is '$($volRow.Status)'. Resolve the underlying issue first.") "#D7BA7D"
            continue
        }
        HtmlAdd ("TRIM Optimization for " + (ConvertTo-HtmlSafe $diskTask.DiskName) + " (" + $dl + ":)") "#569cd6"
        Console-Step ("Optimizing TRIM on " + $dl)
        $trimStatus = if ($Mode -eq "QuickScan") { "Skipped-QuickScan" } else { "Pending" }
        if (Test-RaseDryRun "Re-trim drive ${dl}:") {
            $trimStatus = "DryRun"
        } else {
            $trimStatus = "OK"
            try { Optimize-Volume -DriveLetter $dl -ReTrim -Verbose:$false -ErrorAction Stop | Out-Null; HtmlAdd "TRIM completed successfully." "#4ec9b0" }
            catch { $trimStatus = "Failed"; Set-RaseOperationStatus -Name "TRIM" -Status ([HealthStatus]::Failed); HtmlAdd "TRIM failed: $($_.Exception.Message)" "#f44747"; LogError "TRIM failed on $dl" "TRIM" $_.Exception; Add-Recommendation -Priority 2 -Message "TRIM failed on ${dl}: $($_.Exception.Message)" -Source "TRIM" }
        }
        foreach ($row in $Global:Ctx.DiskTable) { if ($row.Disk -eq "${dl}:") { $row.TrimStatus = $trimStatus } }
        HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
    }
}

function Invoke-Defrag {
    param([pscustomobject]$diskTask)
    if (-not $Global:Ctx.OperationStatus.Contains("Defrag")) {
        Set-RaseOperationStatus -Name "Defrag" -Status ([HealthStatus]::OK)
    }
    # Definite HDD always qualifies. "Unspecified" media only qualifies if SpindleSpeed
    # explicitly confirms rotational (>0) - mirrors the same conservative logic as TRIM's
    # media detection, using the same SpindleSpeed signal, rather than just excluding a
    # couple of known-SSD-like bus types.
    $isDefiniteHdd = ($diskTask.MediaType -eq "HDD")
    $isConfirmedRotational = ($diskTask.MediaType -eq "Unspecified") -and ($null -ne $diskTask.SpindleSpeed) -and ($diskTask.SpindleSpeed -gt 0)
    if (-not $isDefiniteHdd -and -not $isConfirmedRotational) {
        foreach ($row in $Global:Ctx.DiskTable) {
            if ($row.Name -eq $diskTask.DiskName) {
                $row.DefragStatus = "NotApplicable"
                $row.FragLevel = $null
            }
        }
        return
    }
    if (-not $diskTask.DriveLetters) { return }
    
    foreach ($dl in $diskTask.DriveLetters) {
        # Same per-volume safety gate as TRIM - see the comment there.
        $volRow = $Global:Ctx.DiskTable | Where-Object { $_.Disk -eq "${dl}:" } | Select-Object -First 1
        if ($volRow -and $volRow.Status -in @("DIRTY", "Errors", "TimedOut")) {
            HtmlAdd ("Skipping Defrag for " + (ConvertTo-HtmlSafe $diskTask.DiskName) + " (" + $dl + ":) - volume status is '$($volRow.Status)'. Resolve the underlying issue first.") "#D7BA7D"
            continue
        }
        HtmlAdd ("HDD Defragmentation for " + (ConvertTo-HtmlSafe $diskTask.DiskName) + " (" + $dl + ":)") "#569cd6"
        Console-Step ("Optimizing Defrag on " + $dl)
        $frag = $null; $defStatus = if ($Mode -eq "QuickScan") { "Skipped-QuickScan" } else { "Skipped" }

        if (-not (Test-RaseDryRun "Analyze fragmentation and, if needed, defragment drive ${dl}:")) {
            try {
                $analysis = Optimize-Volume -DriveLetter $dl -Analyze -ErrorAction Stop
                if ($analysis -and $analysis.PSObject.Properties.Match('PercentFragmentation').Count -gt 0 -and $null -ne $analysis.PercentFragmentation) {
                    $frag = [int]$analysis.PercentFragmentation
                    HtmlAdd "Fragmentation level: ${frag}%" $(if ($frag -ge $Global:Threshold_Frag) { "#D7BA7D" } else { "#4ec9b0" })

                    if ($frag -ge $Global:Threshold_Frag) {
                        HtmlAdd "Fragmentation exceeds threshold ($($Global:Threshold_Frag)%). Starting defragmentation..." "#D7BA7D"
                        Invoke-AnimatedTask -Activity "Defragging Drive ${dl}:" -Command "defrag.exe" -Arguments "${dl}: /U /V" -TimeoutSeconds $Global:Timeout_Defrag
                        if ($Global:RaseLastTaskTimedOut) {
                            $defStatus = "TimedOut"; Set-RaseOperationStatus -Name "Defrag" -Status ([HealthStatus]::Failed); HtmlAdd "Defrag exceeded the ${Global:Timeout_Defrag}s timeout and was terminated." "#f44747"
                            Add-Recommendation -Priority 2 -Message "Defrag on ${dl}: did not finish within the timeout. Consider running it outside RASE with more time." -Source "Defrag"
                        } elseif ($LASTEXITCODE -eq 0) {
                            $defStatus = "Completed"; HtmlAdd "Defrag completed successfully." "#4ec9b0"
                        } else {
                            $defStatus = "Failed"; Set-RaseOperationStatus -Name "Defrag" -Status ([HealthStatus]::Failed); HtmlAdd "Defrag returned exit code $LASTEXITCODE." "#f44747"
                            Add-Recommendation -Priority 2 -Message "Defrag on ${dl}: returned exit code $LASTEXITCODE." -Source "Defrag"
                        }
                    } else {
                        $defStatus = "Skipped"; HtmlAdd "Fragmentation is below threshold. Defrag skipped." "#4ec9b0"
                    }
                } else {
                    # Analysis genuinely failed to return usable data. Do NOT fall back to running
                    # defrag anyway - that inverted a failed check into an automatic write action.
                    $defStatus = "AnalysisFailed"
                    Set-RaseOperationStatus -Name "Defrag" -Status ([HealthStatus]::Warning)
                    HtmlAdd "Fragmentation analysis returned no usable data. Defrag was NOT started." "#D7BA7D"
                    Add-Recommendation -Priority 3 -Message "Fragmentation analysis for ${dl}: returned no usable data - defrag was not automatically started. Investigate manually if needed." -Source "Defrag"
                }
            } catch {
                $defStatus = "Failed"; Set-RaseOperationStatus -Name "Defrag" -Status ([HealthStatus]::Failed); HtmlAdd ("Defrag analysis/operation failed: " + $_.Exception.Message) "#f44747"
                LogError "Defrag failed on $dl" "Defrag" $_.Exception
            }
        }
        foreach ($row in $Global:Ctx.DiskTable) { if ($row.Disk -eq "${dl}:") { if ($null -ne $frag) { $row.FragLevel = $frag }; $row.DefragStatus = $defStatus } }
        HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
    }
}

function Invoke-VssPruning {
    HtmlAddSection "Shadow Copy (VSS) Assessment"
    Set-RaseOperationStatus -Name "VSS" -Status ([HealthStatus]::OK)
    Console-Step "VSS Assessment"
    try {
        $shadows = @(Get-CimInstance Win32_ShadowCopy -ErrorAction SilentlyContinue)
        if ($shadows.Count -eq 0) {
            HtmlAdd "No Volume Shadow Copies detected." "#808080"
            HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
            return
        }

        # Use per-volume shadow-storage usage for the destructive-action threshold. The old
        # implementation used system-wide UsedSpace, which could cause a volume with few/no
        # storage pressure of its own to qualify because another volume consumed the space.
        $storage = @(Get-CimInstance Win32_ShadowStorage -ErrorAction SilentlyContinue)
        $storageByVolume = @{}

        foreach ($st in $storage) {
            $volumeName = ConvertTo-RaseVolumeId $st.Volume
            if ($volumeName -and $null -ne $st.UsedSpace) {
                $storageByVolume[$volumeName] = [math]::Round(([double]$st.UsedSpace / 1GB), 2)
            }
        }

        $volumes = @(Get-CimInstance Win32_Volume -ErrorAction SilentlyContinue)
        $groups = $shadows | Where-Object { $_.VolumeName } | Group-Object VolumeName

        foreach ($group in $groups) {
            $volumeName = $group.Name
            $normalizedShadowVolume = ConvertTo-RaseVolumeId $volumeName
            $count = @($group.Group).Count
            $matchedVol = $volumes | Where-Object { (ConvertTo-RaseVolumeId $_.DeviceID) -eq $normalizedShadowVolume } | Select-Object -First 1
            $driveLetter = if ($matchedVol -and $matchedVol.DriveLetter) { $matchedVol.DriveLetter } else { $null }
            $label = if ($driveLetter) { $driveLetter } else { $volumeName }
            $usedGB = if ($normalizedShadowVolume -and $storageByVolume.ContainsKey($normalizedShadowVolume)) { $storageByVolume[$normalizedShadowVolume] } else { $null }
            $usageText = if ($null -ne $usedGB) { "${usedGB}GB" } else { "Unknown" }

            HtmlAdd "$label - Shadow Copies: $count | Shadow Storage Used: $usageText" "#808080"

            # Never use a system-wide VSS figure to qualify a specific volume for deletion.
            # If per-volume storage usage cannot be resolved, assessment remains non-destructive.
            $thresholdExceeded = ($null -ne $usedGB) -and ($count -gt $Global:Threshold_VssMinCopies) -and ($usedGB -gt $Global:Threshold_VssMinUsedGB)
            if ($thresholdExceeded) {
                if (-not (Test-RaseWriteAllowed "Delete the oldest shadow copy on $label")) {
                    Set-RaseOperationStatus -Name "VSS" -Status ([HealthStatus]::Skipped)
                } elseif (-not $ApplyVssPruning) {
                    HtmlAdd "$label exceeds per-volume VSS thresholds. Pruning is disabled by default - pass -ApplyVssPruning to allow deletion." "#D7BA7D"
                    Add-Recommendation -Priority 3 -Message "$label has $count shadow copies and ${usedGB}GB of shadow storage, above configured per-volume thresholds. Review before enabling -ApplyVssPruning." -Source "VSS"
                    Set-RaseOperationStatus -Name "VSS" -Status ([HealthStatus]::Warning)
                } elseif (-not $driveLetter) {
                    HtmlAdd "$label exceeds VSS thresholds, but could not be resolved to a drive letter - skipping deletion for safety." "#D7BA7D"
                    Add-Recommendation -Priority 3 -Message "Shadow copies on volume $volumeName exceed thresholds but the volume has no drive letter - prune manually with vssadmin if needed." -Source "VSS"
                    Set-RaseOperationStatus -Name "VSS" -Status ([HealthStatus]::Warning)
                } elseif (Test-RaseDryRun "Delete the oldest shadow copy on ${driveLetter}:") {
                    Set-RaseOperationStatus -Name "VSS" -Status ([HealthStatus]::Skipped)
                } elseif (-not (Test-RaseOptimizationSafetyGate -OperationName "VSS")) {
                    # Gate reported and status set inside the helper.
                } else {
                    # Shadow copies and System Restore checkpoints share the same storage, so
                    # deleting the oldest shadow copy on the system volume can remove an older
                    # restore point. The newest checkpoint - the one this run relies on - is
                    # never the /oldest target, but the operator should know the trade-off.
                    HtmlAdd "${driveLetter}: - deleting the oldest shadow copy. On a system volume this may also remove the oldest System Restore checkpoint." "#808080"
                    & vssadmin.exe delete shadows "/for=${driveLetter}:" /oldest /quiet
                    if ($LASTEXITCODE -eq 0) {
                        HtmlAdd "${driveLetter}: - oldest shadow copy deleted successfully." "#4ec9b0"
                    } else {
                        HtmlAdd "${driveLetter}: - VSS deletion failed (exit code $LASTEXITCODE)." "#f44747"
                        Set-RaseOperationStatus -Name "VSS" -Status ([HealthStatus]::Failed)
                        Add-Recommendation -Priority 2 -Message "VSS pruning failed for ${driveLetter}: with exit code $LASTEXITCODE." -Source "VSS"
                    }
                }
            } elseif ($null -eq $usedGB) {
                HtmlAdd "$label - per-volume shadow storage usage could not be resolved. No pruning performed." "#D7BA7D"
                Add-Recommendation -Priority 3 -Message "RASE could not resolve per-volume VSS storage usage for $label; pruning was skipped for safety." -Source "VSS"
                Set-RaseOperationStatus -Name "VSS" -Status ([HealthStatus]::Warning)
            } else {
                HtmlAdd "$label - per-volume VSS thresholds not exceeded. No pruning needed." "#4ec9b0"
            }
        }
    } catch {
        HtmlAdd "VSS assessment failed: $($_.Exception.Message)" "#f44747"
        LogError "VSS assessment failed." "VSS" $_.Exception
        Set-RaseOperationStatus -Name "VSS" -Status ([HealthStatus]::Failed)
    }
    HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
}
# Maps an fsutil behavior name to the registry value fsutil itself reads and writes.
# The registry is the primary source of truth for detection because it is completely
# locale-independent, whereas "fsutil behavior query" wraps the number in prose whose
# wording changes between Windows builds AND between display languages: the English text
# reads "The registry state of ... is 2", while other locales translate the sentence and
# reorder it around the number. Parsing that prose was the single most locale-fragile part
# of the NTFS module.
$Global:RaseFsBehaviorRegistry = @{
    "disable8dot3"      = "NtfsDisable8dot3NameCreation"
    "disablelastaccess" = "NtfsDisableLastAccessUpdate"
}
$Global:RaseFileSystemRegKey = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"

function Get-RaseFsutilNumericValue {
    param(
        [Parameter(Mandatory)][string]$Behavior,
        [int[]]$ValidValues = @(0,1)
    )

    # 1) Registry (authoritative, locale-independent).
    $regName = $Global:RaseFsBehaviorRegistry[$Behavior]
    if ($regName) {
        try {
            $key = Get-ItemProperty -Path $Global:RaseFileSystemRegKey -Name $regName -ErrorAction Stop
            $regValue = [int]$key.$regName
            if ($ValidValues -contains $regValue) { return $regValue }
        }
        catch {
            # Value genuinely absent (setting never written) or key unreadable - fall through
            # to fsutil rather than reporting a wrong answer.
        }
    }

    # 2) fsutil text fallback, anchored on the registry value name. That token stays in
    #    English inside localized fsutil output, so anchoring on it is far more reliable
    #    than anchoring on '=' or ':' - which some builds do not emit at all.
    try {
        $output = @(& fsutil.exe behavior query $Behavior 2>&1) -join "`n"
        $exitCode = $LASTEXITCODE
        if ($exitCode -ne 0 -or [string]::IsNullOrWhiteSpace($output)) { return $null }

        if ($regName) {
            $anchored = [regex]::Match($output, ('(?is)' + [regex]::Escape($regName) + '\D{0,60}?(\d+)'))
            if ($anchored.Success) {
                $value = [int]$anchored.Groups[1].Value
                if ($ValidValues -contains $value) { return $value }
            }
        }

        # No generic prose parsing: localized separators and words are not a reliable contract.
        return $null
    }
    catch {
        LogError -Message "fsutil behavior query failed for '$Behavior'." -Source "NTFS" -Ex $_.Exception
        return $null
    }
}

# Backward-compatible wrapper for callers that only accept binary settings.
function Get-RaseFsutilBinaryValue {
    param([Parameter(Mandatory)][string]$Behavior)
    return Get-RaseFsutilNumericValue -Behavior $Behavior -ValidValues @(0,1)
}

# Ranks how strictly 8.3 short-name creation is disabled, so tuning can never loosen an
# existing setting. 0 (enabled everywhere) and 2 (per-volume policy) are both "not disabled
# globally"; 3 disables everything except the system volume; 1 disables everything.
function Get-Rase8Dot3Strictness {
    param([AllowNull()][Nullable[int]]$Value)
    if ($null -eq $Value) { return -1 }
    switch ($Value) {
        1 { return 2 }
        3 { return 1 }
        default { return 0 }
    }
}

function Get-RaseNtfs8Dot3State {
    # [Nullable[int]], not [int]: a plain [int] parameter silently coerces $null to 0, so the
    # "Unknown" guard below could never fire and an unreadable setting would have been
    # reported as "8.3 names enabled for all volumes".
    param([AllowNull()][Nullable[int]]$Value)
    if ($null -eq $Value) { return "Unknown" }
    switch ($Value) {
        0 { return "Enabled-AllVolumes" }
        1 { return "Disabled-AllVolumes" }
        2 { return "PerVolume" }
        3 { return "Disabled-ExceptSystemVolume" }
        default { return "Unknown" }
    }
}

function Get-RaseNtfsLastAccessState {
    param([AllowNull()][Nullable[int]]$Value)
    if ($null -eq $Value) { return "Unknown" }
    # Since Windows 10 1803 this is a two-bit policy:
    # bit 0 = disable LastAccessTime updates; bit 1 = system-managed policy.
    switch ($Value -band 0x3) {
        0 { return "Enabled" }
        1 { return "Disabled" }
        2 { return "SystemManaged-Enabled" }
        3 { return "SystemManaged-Disabled" }
        default { return "Unknown" }
    }
}
function Invoke-NtfsTuning {
    HtmlAddSection "NTFS File System Tuning"
    Set-RaseOperationStatus -Name "NTFS" -Status ([HealthStatus]::OK)

    if (-not $ApplyNtfsTuning) {
        HtmlAdd "Detect-only mode (default) - reporting current settings, not changing them. Pass -ApplyNtfsTuning to let RASE apply changes." "#808080"
    }

    try {
        $disable8dot3 = Get-RaseFsutilNumericValue -Behavior "disable8dot3" -ValidValues @(0,1,2,3)
        $disableLastAccess = Get-RaseFsutilNumericValue -Behavior "disablelastaccess" -ValidValues @(0,1,2,3)
        $detectionIssue = $false

        if ($null -eq $disable8dot3) {
            $detectionIssue = $true
            HtmlAdd "8.3 filename behavior could not be determined reliably." "#D7BA7D"
            Add-Recommendation -Priority 3 -Message "RASE could not reliably determine the current NTFS 8.3 short-name behavior." -Source "NTFS"
        }
        else {
            $state8 = Get-RaseNtfs8Dot3State $disable8dot3
            switch ($state8) {
                "Disabled-AllVolumes" { HtmlAdd "8.3 names: disabled for all volumes." "#4ec9b0" }
                "Disabled-ExceptSystemVolume" {
                    HtmlAdd "8.3 names: disabled for all volumes except the system volume." "#808080"
                }
                "PerVolume" {
                    HtmlAdd "8.3 names: per-volume policy (global default = per-volume)." "#D7BA7D"
                    if (-not $ApplyNtfsTuning) {
                        Add-Recommendation -Priority 3 -Message "8.3 filename generation uses per-volume policy. RASE will not silently convert this to a global setting in detect-only mode." -Source "NTFS"
                    }
                }
                "Enabled-AllVolumes" {
                    HtmlAdd "8.3 names: enabled for all volumes." "#D7BA7D"
                    if (-not $ApplyNtfsTuning) {
                        Add-Recommendation -Priority 3 -Message "8.3 filename generation is enabled for all volumes. Consider disabling it only after verifying legacy application compatibility." -Source "NTFS"
                    }
                }
                default {
                    $detectionIssue = $true
                    HtmlAdd "8.3 filename behavior returned an unsupported value: $disable8dot3." "#D7BA7D"
                }
            }
        }

        if ($null -eq $disableLastAccess) {
            $detectionIssue = $true
            HtmlAdd "Last Access Time behavior could not be determined reliably." "#D7BA7D"
            Add-Recommendation -Priority 3 -Message "RASE could not reliably determine the current NTFS Last Access Time behavior." -Source "NTFS"
        }
        else {
            $lastAccessState = Get-RaseNtfsLastAccessState $disableLastAccess
            switch ($lastAccessState) {
                "Disabled" { HtmlAdd "Last Access Time: disabled." "#808080" }
                "Enabled" {
                    HtmlAdd "Last Access Time: enabled." "#D7BA7D"
                    if (-not $ApplyNtfsTuning) {
                        Add-Recommendation -Priority 3 -Message "Last Access Time tracking is enabled. Consider disabling it only if the workload does not require it." -Source "NTFS"
                    }
                }
                "SystemManaged-Enabled" {
                    HtmlAdd "Last Access Time: system-managed policy (value 2; effective updates are controlled by NTFS policy)." "#808080"
                }
                "SystemManaged-Disabled" {
                    HtmlAdd "Last Access Time: system-managed policy with updates disabled (value 3)." "#808080"
                }
                default {
                    $detectionIssue = $true
                    HtmlAdd "Last Access Time returned an unsupported value: $disableLastAccess." "#D7BA7D"
                }
            }
        }

        if (-not $ApplyNtfsTuning) {
            Set-RaseOperationStatus -Name "NTFS" -Status ([HealthStatus]::Skipped)
            Add-RaseHtmlDivider
            return
        }

        if (-not (Test-RaseWriteAllowed "Apply NTFS behavior tuning")) {
            Set-RaseOperationStatus -Name "NTFS" -Status ([HealthStatus]::Skipped)
            Add-RaseHtmlDivider
            return
        }

        if (Test-RaseDryRun "Apply NTFS behavior tuning") {
            Set-RaseOperationStatus -Name "NTFS" -Status ([HealthStatus]::Skipped)
            Add-RaseHtmlDivider
            return
        }

        # Everything above this point was read-only reporting and has already been written to
        # the report. Only the registry writes below need rollback protection.
        if (-not (Test-RaseOptimizationSafetyGate -OperationName "NTFS")) {
            Add-RaseHtmlDivider
            return
        }

        $changeFailures = 0
        $changeAttempts = 0

        # Target comes from config (default 3 = every volume except the system volume). The
        # change is applied only when it is strictly stricter than what is already in place, so
        # a machine already at 1 is never loosened to 3 by a default-valued config.
        $target8 = $Global:Ntfs8Dot3Target
        $current8Strictness = Get-Rase8Dot3Strictness $disable8dot3
        $target8Strictness = Get-Rase8Dot3Strictness $target8
        if ($null -ne $disable8dot3 -and $target8Strictness -gt $current8Strictness) {
            $changeAttempts++
            & fsutil.exe behavior set disable8dot3 $target8 2>&1 | Out-Null
            $exit8 = $LASTEXITCODE
            if ($exit8 -eq 0) {
                $scopeText = if ($target8 -eq 1) { "all volumes" } else { "all volumes except the system volume" }
                HtmlAdd "8.3 names: disabled for $scopeText (value $disable8dot3 -> $target8)." "#4ec9b0"
            }
            else {
                $changeFailures++
                HtmlAdd "8.3 names: fsutil returned exit code $exit8 - change may not have applied." "#f44747"
                Add-Recommendation -Priority 2 -Message "fsutil could not set NTFS 8.3 filename generation to $target8 (exit code $exit8)." -Source "NTFS"
            }
        }
        elseif ($null -ne $disable8dot3 -and $target8Strictness -lt $current8Strictness) {
            HtmlAdd "8.3 names: already stricter than the configured target ($disable8dot3 vs $target8) - left unchanged." "#808080"
        }

        # Bit 1 (system-managed vs user-managed) is preserved deliberately: value 2 is the
        # Windows 10+ default, and forcing 1 would take the volume out of system management as
        # a side effect of a request that was only ever about turning updates off. Setting
        # value -bor 1 turns off Last Access updates while leaving the management mode alone
        # (2 -> 3 stays system-managed, 0 -> 1 stays user-managed).
        if ($null -ne $disableLastAccess -and ($disableLastAccess -band 0x1) -eq 0) {
            $targetLast = $disableLastAccess -bor 0x1
            $changeAttempts++
            & fsutil.exe behavior set disablelastaccess $targetLast 2>&1 | Out-Null
            $exitLast = $LASTEXITCODE
            if ($exitLast -eq 0) {
                $modeText = if (($targetLast -band 0x2) -ne 0) { "system-managed mode preserved" } else { "user-managed mode preserved" }
                HtmlAdd "Last Access Time: updates disabled ($modeText; value $disableLastAccess -> $targetLast)." "#4ec9b0"
            }
            else {
                $changeFailures++
                HtmlAdd "Last Access Time: fsutil returned exit code $exitLast - change may not have applied." "#f44747"
                Add-Recommendation -Priority 2 -Message "fsutil could not set NTFS Last Access Time behavior to $targetLast (exit code $exitLast)." -Source "NTFS"
            }
        }

        $post8 = Get-RaseFsutilNumericValue -Behavior "disable8dot3" -ValidValues @(0,1,2,3)
        $postLast = Get-RaseFsutilNumericValue -Behavior "disablelastaccess" -ValidValues @(0,1,2,3)
        $post8Ok = (Get-Rase8Dot3Strictness $post8) -ge $target8Strictness -and (Get-Rase8Dot3Strictness $post8) -gt 0
        $postLastOk = ($null -ne $postLast) -and (($postLast -band 0x1) -ne 0)
        HtmlAdd "Post-check: 8.3 names = $(if($post8Ok){'Disabled'}else{'Not confirmed disabled'}); Last Access Time = $(if($postLastOk){'Disabled'}else{'Not confirmed disabled'})." "#808080"
        HtmlAdd "NTFS behavior changes are filesystem-wide; verify legacy application compatibility before keeping them permanently. Set Ntfs.EightDotThreeTarget = 1 in RASE.config.psd1 to also disable 8.3 names on the system volume." "#808080"

        $postFailures = @()
        if (-not $post8Ok) { $postFailures += '8.3 names' }
        if (-not $postLastOk) { $postFailures += 'Last Access Time' }

        if ($postFailures.Count -gt 0) {
            $msg = "NTFS post-check could not confirm: " + ($postFailures -join ', ') + "."
            HtmlAdd $msg "#f44747"
            Add-Recommendation -Priority 2 -Message $msg -Source "NTFS"
            # "Could not confirm" is only a hard failure when RASE actually attempted a change.
            # If detection itself was unavailable, nothing was broken - that is a Warning, and
            # marking it Failed would push the whole run to exit code 2 over a read problem.
            if ($changeAttempts -gt 0) {
                Set-RaseOperationStatus -Name "NTFS" -Status ([HealthStatus]::Failed)
            } else {
                Set-RaseOperationStatus -Name "NTFS" -Status ([HealthStatus]::Warning)
            }
        } elseif ($changeFailures -gt 0) {
            Set-RaseOperationStatus -Name "NTFS" -Status ([HealthStatus]::Warning)
        } elseif ($changeAttempts -gt 0 -or ($post8Ok -and $postLastOk)) {
            Set-RaseOperationStatus -Name "NTFS" -Status ([HealthStatus]::OK)
        } else {
            Set-RaseOperationStatus -Name "NTFS" -Status ([HealthStatus]::Warning)
        }
    }
    catch {
        HtmlAdd "NTFS Tuning check/application failed: $($_.Exception.Message)" "#f44747"
        LogError -Message "NTFS Tuning failed." -Source "NTFS" -Ex $_.Exception
        Set-RaseOperationStatus -Name "NTFS" -Status ([HealthStatus]::Failed)
    }

    Add-RaseHtmlDivider
}
# ----------------------------
# HealthScore Enterprise Engine
# ----------------------------
function Compute-HealthScore {
    param([string]$Phase="Final")
    if ($Phase -eq "Final") { HtmlAddSection "Final HealthScore Analysis" }

    foreach ($row in $Global:Ctx.DiskTable) {
        $score = 100
        $worstSeverity = $null   # $null=OK, "Warning", "Critical" - whichever fired rule is worst
        
        # Enterprise Rule Matrix Application (single shared rule set - see $Global:DiskRules).
        # FinalStatus is derived from the same pass that computes the score, so the "Status"
        # column in the report and the score it's next to can never disagree about severity -
        # unlike the old Status field, which only tracked CHKDSK/Dirty and could show "OK"
        # even when SMART/TRIM/Defrag/FreeSpace had real problems.
        foreach ($rule in $Global:DiskRules) {
            if (& $rule.Condition $row) {
                $score -= $rule.Penalty
                if ($rule.Severity -eq "Critical") { $worstSeverity = "Critical" }
                elseif ($rule.Severity -eq "Warning" -and $worstSeverity -ne "Critical") { $worstSeverity = "Warning" }
            }
        }
        if ($score -lt 0) { $score = 0 }
        $row.FinalStatus = if ($worstSeverity) { $worstSeverity } else { "OK" }
        
        $tier = Get-Tier $score
        $row.RiskLevel = if ($tier.Level -ge 2) { "Low" } elseif ($tier.Level -eq 1) { "Medium" } else { "High" }

        if ($Phase -eq "Initial") { $row.InitialHealthScore = $score } 
        else {
            $row.FinalHealthScore = $score
            HtmlAdd ("Disk " + $row.Disk + " - Initial Score: " + $row.InitialHealthScore + " | Final Score: " + $row.FinalHealthScore) $tier.Color
        }
    }
}

# ---------------------------------------------------------
# Executive Summary & Report Finalization
# ---------------------------------------------------------
function Finalize-PhaseStatusSection {
    HtmlAddSection "Execution Overview"
    if ($Mode -eq "QuickScan") {
        HtmlAdd ("Pipeline: " + $Global:Ctx.PhaseStatus.Count + " Phases (Mode: QuickScan) / Read-only diagnostic pipeline.") "#808080"
    }
    else {
        HtmlAdd ("Pipeline: " + $Global:Ctx.PhaseStatus.Count + " Phases (Mode: Full) / ~28 individual operations across those phases.") "#808080"
    }

    # PhaseStatus only reflects whether a phase completed without an unhandled exception -
    # many operations inside a phase catch their own errors and continue (SMART, TRIM,
    # Defrag, Cleanup, DISM, SFC...), so a phase can show OK while real issues happened
    # inside it. Rather than building a full per-operation status model, this cross-references
    # the existing Recommendations list (which already knows what went wrong and where) against
    # a static Source -> Phase map, so "OK" phases with real findings aren't silently flattened.
    $sourceToPhase = $Global:RaseSourcePhaseMap
    $issueCounts = @{}
    foreach ($rec in $Global:Ctx.Recommendations) {
        $source = if ($null -ne $rec.Source) { ([string]$rec.Source).Trim() } else { "System" }
        $phase = $sourceToPhase[$source]
        if ($phase) {
            if (-not $issueCounts.ContainsKey($phase)) { $issueCounts[$phase] = 0 }
            $issueCounts[$phase] += 1
        }
    }

    # Also surface tracked operation warnings/failures/skips even when an operation did not
    # generate a recommendation. QuickScan skips are expected and therefore are not counted
    # as issues; only Warning/Failed states are counted here.
    $operationToPhase = $Global:RaseSourcePhaseMap
    foreach ($entry in $Global:Ctx.OperationStatus.GetEnumerator()) {
        if ($entry.Value -in @([HealthStatus]::Warning, [HealthStatus]::Failed)) {
            $phase = $operationToPhase[$entry.Key]
            if ($phase) {
                if (-not $issueCounts.ContainsKey($phase)) { $issueCounts[$phase] = 0 }
                # Recommendations already represent the same finding in most paths.
                # Count the operation only when it has no matching source recommendation.
                $hasMatchingRecommendation = @($Global:Ctx.Recommendations | Where-Object {
                    $src = if ($null -ne $_.Source) { ([string]$_.Source).Trim() } else { "" }
                    $src -eq $entry.Key
                }).Count -gt 0
                if (-not $hasMatchingRecommendation) { $issueCounts[$phase] += 1 }
            }
        }
    }

    $tableHtml = "<table border='1' cellspacing='0' cellpadding='5' style='border-collapse: collapse; border: 1px solid #444; width: 100%; text-align: left;'>"
    $tableHtml += "<tr style='background-color: #333; color: #fff;'><th>Phase</th><th>Status</th><th>Issues Logged</th></tr>"
    foreach ($phase in $Global:Ctx.PhaseStatus.Keys) {
        $status = $Global:Ctx.PhaseStatus[$phase]
        $color = switch ($status) {
            ([HealthStatus]::OK)      { "#4ec9b0" }
            ([HealthStatus]::Failed)  { "#f44747" }
            ([HealthStatus]::Skipped) { "#D7BA7D" }
            default                   { "#808080" }
        }
        $issueCount = if ($issueCounts.ContainsKey($phase)) { $issueCounts[$phase] } else { 0 }
        $issueText = if ($issueCount -gt 0) { "$issueCount" } else { "-" }
        $issueColor = if ($issueCount -gt 0) { "#D7BA7D" } else { "#808080" }
        $tableHtml += "<tr><td style='border: 1px solid #444;'>$phase</td><td style='border: 1px solid #444; color:$color;'>$status</td><td style='border: 1px solid #444; color:$issueColor;'>$issueText</td></tr>"
    }
    $tableHtml += "</table>"
    $Global:HtmlBuilder.AppendLine($tableHtml) | Out-Null
    if ($Global:Ctx.PhaseStatus.Values -contains [HealthStatus]::Failed) {
        HtmlAdd "One or more phases failed. Results below may be partial - see Execution Overview above." "#f44747"
    } elseif ($Global:Ctx.PhaseStatus.Values -contains [HealthStatus]::Skipped) {
        HtmlAdd "One or more phases were skipped because a prerequisite was incomplete. Results may be partial - see Execution Overview above." "#D7BA7D"
    }
    $totalLoggedIssues = if ($issueCounts.Count -gt 0) { [int](($issueCounts.Values | Measure-Object -Sum).Sum) } else { 0 }
    if ($totalLoggedIssues -gt 0) {
        HtmlAdd "One or more operations logged findings inside otherwise completed phases - see the Issues Logged column and Recommended Actions below for details." "#D7BA7D"
    }
    HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
}

function Finalize-ExecutionSummary {
    Finalize-PhaseStatusSection
    HtmlAddSection "Executive Summary"
    
    $totalScore = 0; $penalties = @{}; $diskCount = $Global:Ctx.DiskTable.Count
    if ($diskCount -gt 0) {
        foreach ($row in $Global:Ctx.DiskTable) {
            $totalScore += $row.FinalHealthScore
            foreach ($rule in $Global:DiskRules) {
                if (& $rule.Condition $row) { Add-Penalty $penalties $rule.Name $rule.Penalty }
            }
        }
        $avgStorageScore = [math]::Round($totalScore / $diskCount)
    } else {
        # No volumes in the table means Profiling/Baseline never produced data - usually
        # because an upstream phase failed. Reporting 100% here would be the exact kind of
        # dishonest green that the rest of this engine is built to avoid.
        $avgStorageScore = $null
    }
    $storageEvaluated = ($diskCount -gt 0)

    # QuickScan is intentionally read-only and does not execute CHKDSK, DISM, or SFC.
    # Therefore System Integrity is not numerically scored in QuickScan: a 100% value
    # would falsely imply that those integrity checks actually ran. Full mode keeps
    # the existing numeric scoring model.
    $systemIntegrityEvaluated = ($Mode -ne "QuickScan")
    if ($systemIntegrityEvaluated) {
        $sysIntegrity = 100
        if ($Global:Ctx.Summary_CHKDSK -gt 0) { $sysIntegrity -= 10 }
        if ($Global:Ctx.DISM_Status -eq [HealthStatus]::Failed) { $sysIntegrity -= 20 } elseif ($Global:Ctx.DISM_Status -eq [HealthStatus]::Repaired) { $sysIntegrity -= 5 }
        if ($Global:Ctx.SFC_Status -eq [HealthStatus]::Failed) { $sysIntegrity -= 20 } elseif ($Global:Ctx.SFC_Status -in @([HealthStatus]::Repaired, [HealthStatus]::Warning)) { $sysIntegrity -= 5 }
    } else {
        $sysIntegrity = $null
    }

    $maintReadiness = 100
    if ($Global:Ctx.PendingReboot) { $maintReadiness -= 15 }
    if ($Global:Ctx.WinREState -eq "Disabled") { $maintReadiness -= 8 }
    # Both states are penalised. v72 renamed the unsuccessful case from "Failed" to "Warning"
    # (correctly - an existing restore point from the last 24h is normal Windows behaviour),
    # but left this check on "Failed" only, which made it unreachable and silently removed the
    # restore point from Maintenance Readiness entirely. For readiness the question is binary:
    # is there a rollback point or not.
    if ($Global:Ctx.RestorePointStatus -in @("Warning", "Failed")) { $maintReadiness -= 10 }

    $shTier = if ($storageEvaluated) { Get-Tier $avgStorageScore } else { $null }
    $siTier = if ($systemIntegrityEvaluated) { Get-Tier $sysIntegrity } else { $null }
    $mrTier = Get-Tier $maintReadiness
    
    # Do not let an unexecuted QuickScan integrity subsystem influence the overall tier.
    # QuickScan assessment is based on the checks that actually ran.
    $overallTier = Get-Tier 100
    if (($storageEvaluated -and $shTier.Level -eq 0) -or ($systemIntegrityEvaluated -and $siTier.Level -eq 0)) { $overallTier = Get-Tier 0 }
    elseif (($storageEvaluated -and $shTier.Level -eq 1) -or ($systemIntegrityEvaluated -and $siTier.Level -eq 1)) { $overallTier = Get-Tier 70 }
    elseif ($mrTier.Level -le 1) { $overallTier = Get-Tier 85 }

    if (-not $storageEvaluated) {
        $overallTier = Get-Tier 70
        Add-Recommendation -Priority 1 -Message "No volumes were profiled, so storage health could not be assessed. Re-run RASE after resolving the phase failure reported in the Execution Overview." -Source "Storage"
    }

    if ($storageEvaluated -and $shTier.Level -le 1) { Add-Recommendation -Priority 1 -Message "Inspect physical drives immediately." -Source "Storage" }

    $Global:Ctx.Summary = @{
        StorageHealthPercent         = $avgStorageScore
        StorageHealthEvaluated       = $storageEvaluated
        SystemIntegrityPercent       = $sysIntegrity
        SystemIntegrityEvaluated     = $systemIntegrityEvaluated
        MaintenanceReadinessPercent  = $maintReadiness
        OverallAssessment             = $overallTier.Text
        PenaltyBreakdown              = $penalties
    }

    HtmlAdd ("<b>OVERALL ASSESSMENT: <span style='color:$($overallTier.Color)'>$($overallTier.Text)</span></b>") "#d4d4d4"
    HtmlAdd "" "#808080"

    if ($storageEvaluated) {
        HtmlAdd ("<b>Storage Health: " + $avgStorageScore + "%</b>") $shTier.Color
    } else {
        HtmlAdd "<b>Storage Health: N/A</b>" "#808080"
        HtmlAdd "No volumes were profiled - storage health could not be calculated. See the Execution Overview above for the phase that did not complete." "#D7BA7D"
    }
    if ($penalties.Count -gt 0) {
        HtmlAdd "<i>Penalty Breakdown:</i>" "#808080"
        foreach ($key in $penalties.Keys) { HtmlAdd ("  -" + $penalties[$key] + " " + $key) "#808080" }
    }
    HtmlAdd "" "#808080"

    if ($systemIntegrityEvaluated) {
        HtmlAdd ("<b>System Integrity: " + $sysIntegrity + "%</b>") $siTier.Color
        HtmlAdd ("CHKDSK Errors: " + $Global:Ctx.Summary_CHKDSK) $(if($Global:Ctx.Summary_CHKDSK -gt 0){"#D7BA7D"}else{"#808080"})
        HtmlAdd ("DISM Status: " + $Global:Ctx.DISM_Status) $(if($Global:Ctx.DISM_Status -eq [HealthStatus]::Failed){"#F44747"}elseif($Global:Ctx.DISM_Status -eq [HealthStatus]::Repaired){"#D7BA7D"}else{"#808080"})
        HtmlAdd ("SFC Status: " + $Global:Ctx.SFC_Status) $(if($Global:Ctx.SFC_Status -eq [HealthStatus]::Failed){"#F44747"}elseif($Global:Ctx.SFC_Status -eq [HealthStatus]::Repaired){"#D7BA7D"}else{"#808080"})
    } else {
        HtmlAdd "<b>System Integrity: N/A</b>" "#808080"
        HtmlAdd "QuickScan: System integrity score not evaluated - CHKDSK, DISM and SFC were intentionally not executed in read-only mode." "#808080"
        HtmlAdd "CHKDSK Status: Skipped (QuickScan)" "#808080"
        HtmlAdd ("DISM Status: " + $Global:Ctx.DISM_Status) "#808080"
        HtmlAdd ("SFC Status: " + $Global:Ctx.SFC_Status) "#808080"
    }
    HtmlAdd "" "#808080"

    HtmlAdd ("<b>Maintenance Readiness: " + $maintReadiness + "%</b>") $mrTier.Color
    HtmlAdd $(if($Global:Ctx.PendingReboot){"[!] Pending Reboot (Action Required)"}else{"[OK] No Pending Reboot"}) $(if($Global:Ctx.PendingReboot){"#D7BA7D"}else{"#808080"})
    $winreLine = switch ($Global:Ctx.WinREState) {
        "Enabled"  { @{ Text = "[OK] WinRE Active"; Color = "#808080" } }
        "Disabled" { @{ Text = "[!] WinRE Disabled"; Color = "#D7BA7D" } }
        default    { @{ Text = "[?] WinRE status Unknown"; Color = "#D7BA7D" } }
    }
    HtmlAdd $winreLine.Text $winreLine.Color
    $rpSummary = switch ($Global:Ctx.RestorePointStatus) {
        "Created"            { @{ Text = "[OK] Restore Point Created"; Color = "#808080" } }
        "Skipped-DryRun"     { @{ Text = "[!] Restore Point Skipped (DryRun)"; Color = "#D7BA7D" } }
        "Skipped-QuickScan"  { @{ Text = "[!] Restore Point Skipped (QuickScan is read-only)"; Color = "#D7BA7D" } }
        "Warning"            { @{ Text = "[!] Restore Point not created - System Protection may be disabled, or one already exists in the last 24h"; Color = "#D7BA7D" } }
        "Failed"             { @{ Text = "[!] Restore Point FAILED - review the error log"; Color = "#f44747" } }
        default              { @{ Text = "[?] Restore Point status unknown"; Color = "#D7BA7D" } }
    }
    HtmlAdd $rpSummary.Text $rpSummary.Color
    HtmlAdd "" "#808080"

    HtmlAdd "<b>Recommended Actions:</b>" "#d4d4d4"
    if ($Global:Ctx.Recommendations.Count -eq 0 -and -not (Test-RaseAnyOperationFailed)) {
        HtmlAdd "- No critical action required." "#6A9955"
    } elseif ($Global:Ctx.Recommendations.Count -eq 0) {
        HtmlAdd "- One or more operations reported a failure status without a specific recommendation - review the sections above and the error log." "#D7BA7D"
    } else {
        $sortedRecs = $Global:Ctx.Recommendations | Sort-Object Priority
        foreach ($rec in $sortedRecs) {
            $rColor = if ($rec.Priority -eq 1) { "#F44747" } elseif ($rec.Priority -eq 2) { "#D7BA7D" } else { "#6A9955" }
            HtmlAdd ("- [" + (ConvertTo-HtmlSafe $rec.Source) + "] " + (ConvertTo-HtmlSafe $rec.Message)) $rColor
        }
    }
    HtmlAdd "<hr style='border:1px dashed #444;'>" "#808080"
}

function Export-RaseStructuredReports {
    # JSON: full machine-readable snapshot for monitoring/SIEM ingestion.
    try {
        $phaseStatusStr = [ordered]@{}
        foreach ($k in $Global:Ctx.PhaseStatus.Keys) { $phaseStatusStr[$k] = $Global:Ctx.PhaseStatus[$k].ToString() }

        # Mirrors the process Exit Code Engine's logic for the non-fatal cases (a true fatal
        # error means this export never runs at all, so ExitCode 3 isn't representable here).
        $exportExitCode = if ((Test-RaseAnyOperationFailed) -or ($Global:Ctx.PhaseStatus.Values -contains [HealthStatus]::Failed)) { 2 }
                          elseif ((Test-RaseAnyPhaseSkipped) -or (Test-RaseAnyOperationWarning) -or @($Global:Ctx.Recommendations | Where-Object { $_.Priority -le 2 }).Count -gt 0) { 1 }
                          else { 0 }

        $diskTableForExport = @($Global:Ctx.DiskTable | ForEach-Object {
            $clone = @{}
            $_.PSObject.Properties | ForEach-Object { $clone[$_.Name] = $_.Value }
            $clone
        })

        $reportObject = [ordered]@{
            Timestamp        = $timestamp
            ScriptVersion    = $Global:RaseVersion
            ExitCode         = $exportExitCode
            IsAdmin          = $Global:Ctx.IsAdmin
            DryRun           = [bool]$DryRun
            # Recorded so the artifact states what produced it. Without these the mode had to be
            # inferred from how many phases appear in PhaseStatus, which is fragile and silently
            # wrong the moment the pipeline definition changes.
            Mode             = [string]$Mode
            ApplyNtfsTuning  = [bool]$ApplyNtfsTuning
            ApplyVssPruning  = [bool]$ApplyVssPruning
            PhaseStatus      = $phaseStatusStr
            Summary          = $Global:Ctx.Summary
            DISM_Status      = $Global:Ctx.DISM_Status.ToString()
            SFC_Status       = $Global:Ctx.SFC_Status.ToString()
            Summary_CHKDSK   = $Global:Ctx.Summary_CHKDSK
            PendingReboot    = $Global:Ctx.PendingReboot
            RestorePointStatus = $Global:Ctx.RestorePointStatus
            WinRE_Enabled    = $Global:Ctx.WinRE_Enabled
            WinREState       = $Global:Ctx.WinREState
            OperationStatus  = @{}
            DiskTable        = $diskTableForExport
            Recommendations  = @($Global:Ctx.Recommendations)
        }
        foreach ($opName in $Global:Ctx.OperationStatus.Keys) {
            $reportObject.OperationStatus[$opName] = $Global:Ctx.OperationStatus[$opName].ToString()
        }
        $reportObject | ConvertTo-Json -Depth 6 | Out-File -FilePath $Global:JsonLogPath -Encoding UTF8
    } catch {
        Console-Warn "JSON export failed: $($_.Exception.Message)"
        LogError -Message $_.Exception.Message -Source "Export:JSON" -Ex $_.Exception
    }

    # CSV: flat per-disk table, easy to open in Excel or pull into other tooling.
    try {
        if (@($Global:Ctx.DiskTable).Count -gt 0) {
            $Global:Ctx.DiskTable | Export-Csv -Path $Global:CsvLogPath -NoTypeInformation -Encoding UTF8
        }
    } catch {
        Console-Warn "CSV export failed: $($_.Exception.Message)"
        LogError -Message $_.Exception.Message -Source "Export:CSV" -Ex $_.Exception
    }
}

function Finalize-DiskSummaryTable {
    HtmlAddSection "Final Disk Summary"
    $tableHtml = "<table border='1' cellspacing='0' cellpadding='5' style='border-collapse: collapse; border: 1px solid #444; width: 100%; text-align: left;'>"
    $tableHtml += "<tr style='background-color: #333; color: #fff;'><th>Disk</th><th>Name</th><th>Type</th><th>Initial Score</th><th>Final Score</th><th>Risk</th><th>Final Status</th></tr>"
    foreach ($row in $Global:Ctx.DiskTable) {
        $riskColor = if ($row.RiskLevel -eq "High") { "#f44747" } elseif ($row.RiskLevel -eq "Medium") { "#D7BA7D" } else { "#4ec9b0" }
        # FinalStatus is derived from the same DiskRules pass that computes the score - it can
        # never disagree with the score/risk next to it the way the old raw CHKDSK-only
        # Status field could (e.g. showing "OK" while SMART/TRIM/Defrag had real problems).
        $statusColor = switch ($row.FinalStatus) { "Critical" { "#f44747" }; "Warning" { "#D7BA7D" }; "OK" { "#4ec9b0" }; default { "#808080" } }
        $tableHtml += "<tr>
        <td style='border: 1px solid #444;'>$(ConvertTo-HtmlSafe $row.Disk)</td>
        <td style='border: 1px solid #444;'>$(ConvertTo-HtmlSafe $row.Name)</td>
        <td style='border: 1px solid #444;'>$(ConvertTo-HtmlSafe $row.Type)</td>
        <td style='border: 1px solid #444; color:#a0a0a0;'>$(ConvertTo-HtmlSafe $row.InitialHealthScore)</td>
        <td style='border: 1px solid #444; color:#4ec9b0; font-weight:bold;'>$(ConvertTo-HtmlSafe $row.FinalHealthScore)</td>
        <td style='border: 1px solid #444; color:$riskColor;'>$(ConvertTo-HtmlSafe $row.RiskLevel)</td>
        <td style='border: 1px solid #444; color:$statusColor;'>$(ConvertTo-HtmlSafe $row.FinalStatus)</td>
        </tr>"
    }
    $tableHtml += "</table>"
    $Global:HtmlBuilder.AppendLine($tableHtml) | Out-Null
    $Global:HtmlBuilder.AppendLine("</body></html>") | Out-Null
    $Global:HtmlBuilder.ToString() | Out-File -FilePath $Global:HtmlLogPath -Encoding UTF8
    Export-RaseStructuredReports
}

# ============================================================
# MODULAR MAIN EXECUTION ENGINE
# ============================================================
function Invoke-RaseInitialization {
    Section "RASE v$($Global:RaseVersion) - Initialization"
    Initialize-HtmlReport -Title "ROMAN ADAPTIVE STORAGE ENGINE v$($Global:RaseVersion)" -Timestamp $timestamp

    # QuickScan must remain system-state read-only. Checkpoint-Computer is a write operation
    # (it can enable System Protection and creates a real restore point), so it belongs to
    # Full mode only - never silently run it under a mode that promises "read-only".
    if ($Mode -eq "Full") {
        Invoke-SystemRestorePoint
    } else {
        HtmlAddSection "System Protection"
        HtmlAdd "QuickScan: Restore Point creation skipped - QuickScan is system-state read-only." "#808080"
        Console-Step "QuickScan: skipping Restore Point (read-only mode)."
        $Global:Ctx.RestorePointStatus = "Skipped-QuickScan"
        Set-RaseOperationStatus -Name "SystemRestorePoint" -Status ([HealthStatus]::Skipped)
    }

    Section "Pre-Flight Checks"
    Invoke-PreFlightChecks
}

function Invoke-RaseProfiling {
    Section "System Detection & Profiling"
    $Global:SystemProfile = Get-HardwareProfile
    Generate-SystemProfileSummary -SystemProfile $Global:SystemProfile
    Initialize-GlobalDiskTable -SystemProfile $Global:SystemProfile
    $Global:Plan = Get-OptimizationPlan -SystemProfile $Global:SystemProfile
}

function Invoke-RaseDiagnostics {
    Section "Storage Diagnostics (Read-Only)"
    Invoke-SystemExtendedDiagnostics
    Invoke-DiskDiagnostics -SystemProfile $Global:SystemProfile
    Invoke-EventViewerDiagnostics
    Compute-HealthScore -Phase "Initial"
}

function Invoke-RaseRestoration {
    Section "System Restoration & Integrity"
    foreach ($diskTask in $Global:Plan.DiskTasks) { if ($diskTask.Actions -contains "CHKDSK Integrity Check") { Invoke-ChkDsk -diskTask $diskTask } }
    if ($Global:Plan.SystemTasks -contains "ReFS Integrity Check") { Invoke-ReFSIntegrity }
    if ($Global:Plan.SystemTasks -contains "DISM Component Health Check") { Invoke-Dism }
    if ($Global:Plan.SystemTasks -contains "SFC System File Check") { Invoke-Sfc }
}

function Invoke-RaseOptimization {
    Section "Cleanup Engine"
    Invoke-CleanupEngine -Plan $Global:Plan
    Section "Storage Optimization"
    foreach ($diskTask in $Global:Plan.DiskTasks) {
        # No restore-point gate here on purpose: TRIM and Defrag are not rolled back by a
        # System Restore point, and each already refuses to run against a volume whose status
        # is DIRTY/Errors/TimedOut - the precondition that actually protects the data.
        if ($diskTask.Actions -contains "TRIM Optimization") { Invoke-Trim -diskTask $diskTask }
        if ($diskTask.Actions -contains "HDD Defragmentation") { Invoke-Defrag -diskTask $diskTask }
    }
}

function Invoke-RaseAssessment {
    Section "Final Tuning & Assessment"

    if (-not $Global:Plan) {
        HtmlAddSection "Final Tuning"
        HtmlAdd "Plan-dependent tasks (DNS Flush, Dirty Bit, VSS Pruning, NTFS Tuning) skipped - Profiling phase did not complete." "#D7BA7D"
    }
    else {
        # DNS is a local cache operation. It does not require external Internet connectivity.
        if ($Global:Plan.SystemTasks -contains "DNS Cache Flush") {
            HtmlAddSection "DNS Cache Flush"
            if (Test-RaseWriteAllowed "Flush DNS cache") {
                if (Test-RaseDryRun "Flush Windows DNS resolver cache") {
                    # DryRun message already emitted by the helper.
                    Set-RaseOperationStatus -Name "DNS" -Status ([HealthStatus]::Skipped)
                }
                else {
                    try {
                        & ipconfig.exe /flushdns 2>&1 | Out-Null
                        if ($LASTEXITCODE -eq 0) {
                            HtmlAdd "Windows DNS resolver cache flushed successfully." "#4ec9b0"
                            Set-RaseOperationStatus -Name "DNS" -Status ([HealthStatus]::OK)
                        }
                        else {
                            HtmlAdd "DNS cache flush failed (exit code $LASTEXITCODE)." "#D7BA7D"
                            Set-RaseOperationStatus -Name "DNS" -Status ([HealthStatus]::Warning)
                            Add-Recommendation -Priority 3 -Message "Windows DNS resolver cache could not be flushed automatically." -Source "DNS"
                        }
                    }
                    catch {
                        HtmlAdd "DNS cache flush failed: $($_.Exception.Message)" "#f44747"
                        LogError -Message "DNS resolver cache flush failed." -Source "DNS" -Ex $_.Exception
                        Set-RaseOperationStatus -Name "DNS" -Status ([HealthStatus]::Failed)
                    }
                }
            }
            else {
                Set-RaseOperationStatus -Name "DNS" -Status ([HealthStatus]::Skipped)
            }
            Add-RaseHtmlDivider
        }

        if ($Global:Plan.SystemTasks -contains "Dirty Bit Check") {
            Invoke-DirtyBitCheck
        }

        # Both are called unconditionally: each one is an assessment first and a write second,
        # and the Safety Gate now sits immediately in front of the write inside the function.
        # Gating the call itself (v73.3) also threw away the read-only shadow-copy inventory
        # and the detect-only NTFS settings report, which are exactly what an operator needs
        # when System Protection is off.
        if ($Global:Plan.SystemTasks -contains "VSS Pruning (Oldest Shadow Copy)") {
            Invoke-VssPruning
        }

        if ($Global:Plan.SystemTasks -contains "NTFS File System Tuning") {
            Invoke-NtfsTuning
        }
    }

    Compute-HealthScore -Phase "Final"

    # Assessment owns report finalization. Register it before exporting so the final
    # HTML/JSON contains all six Full phases. If finalization throws, Invoke-RasePhase
    # catches the exception and overwrites this provisional OK with Failed.
    $Global:Ctx.PhaseStatus["Assessment"] = [HealthStatus]::OK

    Finalize-ExecutionSummary
    Finalize-DiskSummaryTable
}

# ----------------------------
# Pipeline Definitions (pipeline-as-data)
# Each step is Name / Action (scriptblock) / DependsOn - the engine (Invoke-RasePhase)
# doesn't know what any step does, it only sees names and dependencies. Adding a new
# profile (e.g. a future "SmartOnly") means adding an array entry here, not touching
# the execution engine or "main" below.
# ----------------------------
$Global:Pipelines = @{
    Full = @(
        @{ Name = "Initialization"; Action = { Invoke-RaseInitialization }; DependsOn = @() }
        @{ Name = "Profiling";      Action = { Invoke-RaseProfiling };      DependsOn = @("Initialization") }
        @{ Name = "Diagnostics";    Action = { Invoke-RaseDiagnostics };    DependsOn = @("Profiling") }
        @{ Name = "Restoration";    Action = { Invoke-RaseRestoration };    DependsOn = @("Profiling") }
        @{ Name = "Optimization";   Action = { Invoke-RaseOptimization };   DependsOn = @("Restoration") }
        # Assessment depends ONLY on Initialization, and that is deliberate. Assessment is
        # where the HTML/JSON report is actually written - making it depend on the other
        # phases means one failed phase produces NO report at all, which is the worst
        # possible outcome for a diagnostic tool. Partial results are reported honestly by
        # Finalize-PhaseStatusSection instead.
        @{ Name = "Assessment";     Action = { Invoke-RaseAssessment };     DependsOn = @("Initialization") }
    )
    # System-state read-only: no CHKDSK/DISM/SFC repair, no Cleanup/TRIM/Defrag writes, and - as of
    # this hardening pass - Invoke-RaseInitialization and Invoke-RaseAssessment themselves also
    # check $Mode internally to skip Restore Point creation, VSS pruning, and DNS flush.
    QuickScan = @(
        @{ Name = "Initialization"; Action = { Invoke-RaseInitialization }; DependsOn = @() }
        @{ Name = "Profiling";      Action = { Invoke-RaseProfiling };      DependsOn = @("Initialization") }
        @{ Name = "Diagnostics";    Action = { Invoke-RaseDiagnostics };    DependsOn = @("Profiling") }
        @{ Name = "Assessment";     Action = { Invoke-RaseAssessment };     DependsOn = @("Initialization") }
    )
}

# ============================================================
# START
# ============================================================
$Global:RaseFatalError = $false
try {
    Clear-Host
    Show-ConsoleBanner
    
    if ($Global:IsHeadless) {
        Console-Step "Headless mode detected (Silent or non-interactive session) - skipping start confirmation. [Mode: $Mode]"
    } else {
        $guiMsg = if ($Mode -eq "QuickScan") {
            "ROMAN ADAPTIVE STORAGE ENGINE v$($Global:RaseVersion) - Quick Scan`n`nRead-only diagnostics only: no repairs, no cleanup, no defrag.`nTypically finishes in a few minutes.`n`nStart Quick Scan?"
        } else {
            "ROMAN ADAPTIVE STORAGE ENGINE v$($Global:RaseVersion)`n`nDepending on your system configuration, the full cycle (6 phases,`n~28 individual operations) may take between 1 to 6 hours.`n`nStart full diagnostic and optimization cycle?"
        }
        if ((Show-DarkMessageBox -Message $guiMsg -Title "RASE v$($Global:RaseVersion)" -BtnYesText "START" -BtnNoText "CANCEL" -IsStartDialog $true) -ne "Yes") {
            if ($Global:TranscriptStarted) { try { Stop-Transcript | Out-Null } catch {} }
            exit 1
        }
    }
    
    foreach ($step in $Global:Pipelines[$Mode]) {
        Invoke-RasePhase -Name $step.Name -Action $step.Action -DependsOn $step.DependsOn
    }

    $pipelineHasFailure = ($Global:Ctx.PhaseStatus.Values -contains [HealthStatus]::Failed) -or
                          (Test-RaseAnyOperationFailed)
    $pipelineHasIncomplete = (Test-RaseAnyPhaseSkipped)
    $pipelineHasWarning = $pipelineHasIncomplete -or
                          (Test-RaseAnyOperationWarning) -or
                          @($Global:Ctx.Recommendations | Where-Object { $_.Priority -le 2 }).Count -gt 0

    if ($pipelineHasFailure) {
        Console-Warn "RASE v$($Global:RaseVersion) completed with failures. Review the report: $($Global:HtmlLogPath)"
    } elseif ($pipelineHasWarning) {
        Console-Warn "RASE v$($Global:RaseVersion) completed with warnings. Review the report: $($Global:HtmlLogPath)"
    } else {
        Console-OK "RASE v$($Global:RaseVersion) completed successfully. Report saved to: $($Global:HtmlLogPath)"
    }
    if ($FullReport -and -not $Global:IsHeadless) { try { Invoke-Item $Global:HtmlLogPath } catch { } }

    $rebootWasOffered = $false
    $rebootWasDeferred = $false

    if (-not $NoReboot -and -not $DryRun -and $Mode -ne "QuickScan") {
        # -AutoReboot is intentionally conservative: never force a reboot after a failed or
        # incomplete pipeline. -NoReboot remains the absolute veto. Warnings may still reboot;
        # actual failures/critical findings require the operator to review the report first.
        if ($AutoReboot -and -not $pipelineHasFailure -and -not $pipelineHasIncomplete) {
            Console-Warn "-AutoReboot requested and RASE completed without failures or incomplete phases - restarting now."
            Restart-Computer -Force
        } elseif ($AutoReboot -and ($pipelineHasFailure -or $pipelineHasIncomplete)) {
            Console-Warn "-AutoReboot was requested, but reboot is blocked because RASE reported a failure or incomplete phase. Review the report first."
        } elseif ($Global:IsHeadless) {
            Console-Warn "Reboot may be required, but headless mode without -AutoReboot will not restart automatically."
        } else {
            $rebootWasOffered = $true
            $rebootMsg = if ($pipelineHasFailure -or $pipelineHasIncomplete) {
                "RASE completed with warnings/errors or incomplete work.`n`nReview the report before rebooting.`n`nReboot the system now?"
            } else {
                "RASE completed successfully.`n`nReboot the system now?"
            }
            if ((Show-DarkMessageBox -Message $rebootMsg -Title "Reboot Required" -BtnYesText "RESTART" -BtnNoText "LATER") -eq "Yes") {
                Restart-Computer -Force
            } else {
                $rebootWasDeferred = $true
            }
        }
    }

    if (-not $Global:IsHeadless) {
        Console-OK "RASE v$($Global:RaseVersion) session finished."
        if ($rebootWasDeferred) {
            Write-Host "Reboot: deferred by operator. Use Restart Windows later when convenient." -ForegroundColor Yellow
        } elseif ($NoReboot) {
            Write-Host "Reboot: disabled by -NoReboot." -ForegroundColor Yellow
        } elseif ($Mode -eq "QuickScan" -or $DryRun) {
            Write-Host "Reboot: not offered for this mode." -ForegroundColor Gray
        } elseif ($rebootWasOffered) {
            Write-Host "Reboot: handled by the reboot dialog." -ForegroundColor Gray
        }
        Write-Host "Report: $($Global:HtmlLogPath)" -ForegroundColor Gray
        Write-Host "`nThe RASE console will remain open until you press Enter." -ForegroundColor Cyan
        try { Read-Host "Press Enter to close" | Out-Null } catch {}
    }
} catch {
    Console-Err "Fatal error: $($_.Exception.Message)"
    LogError -Message $_.Exception.Message -Source "Main" -Ex $_.Exception
    $Global:RaseFatalError = $true
} finally { 
    try { [Console]::CursorVisible = $true } catch {}
    try { [Console]::Title = "ROMAN ADAPTIVE STORAGE ENGINE v$($Global:RaseVersion)" } catch {}
    if ($Global:TranscriptStarted) { try { Stop-Transcript | Out-Null } catch {} }
    if ($Global:RaseFatalError -and -not $Global:IsHeadless) {
        Write-Host "`nRASE stopped because of a fatal error. The console will remain open." -ForegroundColor Red
        try { Read-Host "Press Enter to close" | Out-Null } catch {}
    }
}

# ----------------------------
# Exit Code Engine - gives Task Scheduler / CI / monitoring a real signal instead of the
# default 0 that PowerShell returns just for reaching the end of the script. Checks
# PhaseStatus AND Test-RaseAnyOperationFailed (individual operation statuses) - the latter
# closes the gap where an operation catches its own error and continues, so the phase itself
# still reports OK even though something real failed inside it.
#   0 = Success - every required phase completed, no warnings, no operation failed
#   1 = Completed with warnings/incomplete - warnings, expected skips, or a skipped phase
#   2 = Failed - a phase or tracked operation actually failed
#   3 = Fatal - an unhandled error escaped the entire pipeline
# ----------------------------
if ($Global:RaseFatalError) {
    exit 3
} elseif ((Test-RaseAnyOperationFailed) -or ($Global:Ctx.PhaseStatus.Values -contains [HealthStatus]::Failed)) {
    exit 2
} elseif ((Test-RaseAnyPhaseSkipped) -or (Test-RaseAnyOperationWarning) -or @($Global:Ctx.Recommendations | Where-Object { $_.Priority -le 2 }).Count -gt 0) {
    exit 1
} else {
    exit 0
}
