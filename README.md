# RASE — Roman Adaptive Storage Engine

A single-file PowerShell tool that runs a full Windows storage and system-integrity
maintenance cycle, then writes an HTML, JSON and CSV report of what it found, what it
changed, and — deliberately — what it could **not** determine.

RASE is built around one idea: a diagnostic tool that cannot tell the difference between
"healthy", "there is a problem" and "I was unable to check" is worse than no tool at all.
Every status in the report is one of those three, never a comforting default.

**Current release: v73.6.9**

```
SHA-256  44c1b9d9635fa8914b449bcdbedbfd3279667bf29aefe3cb3e428d47efab3e2d
```

Verify what you downloaded before running it:

```powershell
Get-FileHash .\RASE_v73.6.9.ps1 -Algorithm SHA256
```

This build differs from the one used in the acceptance run of 2026-08-09 by a single
line: the indentation of the console banner. There is no functional difference between
them. The acceptance build hashes to `1296ca6ec8d192f2fd0b82766e8bfc24b1d52f30bf2d7cd1c94f91cce139fca1`.

---

## What it does

| Area | Operations |
|---|---|
| Diagnostics (read-only) | Storage reliability counters (SMART-proxy), volume health, dirty-bit state, Event Viewer history (Disk / NTFS / WHEA / bugchecks), boot duration |
| Integrity | CHKDSK per volume, DISM component-store scan, SFC verification, ReFS integrity scan |
| Optimization | TRIM on SSD/NVMe, defragmentation on rotational media (only above a fragmentation threshold) |
| Cleanup | Windows Update download cache, temporary files older than 72 hours, Recycle Bin |
| Assessment | DNS cache flush, shadow-copy (VSS) accounting per volume, NTFS behaviour reporting, health scoring |
| Reporting | HTML report, JSON export, CSV disk table, PowerShell transcript |

Before any of that, in `Full` mode, RASE creates a System Restore point and refuses to
apply registry-level NTFS changes or delete shadow copies if no rollback point exists.

---

## Requirements

- Windows 10 or Windows 11 (developed and verified on Windows 10 Enterprise LTSC 2019, build 17763)
- Windows PowerShell 5.1
- **An already-elevated console.** RASE does not self-elevate: it will not open a second
  PowerShell window behind your back. Start PowerShell as Administrator, then run it.

---

## Quick start

The repository includes `Start_RASE.bat`. Double-click it: it requests Administrator
rights once, then offers a menu of run modes in the same console window.

```
[1]  Quick scan            - read-only, a few seconds
[2]  Full - dry run        - read-only, full pipeline
[3]  Full maintenance      - no reboot
[4]  Full maintenance      - with reboot dialog
```

On an unfamiliar machine, start with `[2]`. Every phase runs and a complete report is
produced, but nothing is written to disk.

The launcher expects the script to sit in the same folder and to be named
`RASE_v73.6.9.ps1`. If you rename it, change the `RASE_SCRIPT` line at the top of the
batch file to match.

---

## Running it manually

Download the script, then unblock it — Windows marks files downloaded from the internet,
and PowerShell refuses to run them until that mark is cleared:

```powershell
Unblock-File .\RASE_v73.6.9.ps1
```

Start with a dry run. Nothing is written to disk, but the whole pipeline is exercised and
you get a full report:

```powershell
.\RASE_v73.6.9.ps1 -Mode QuickScan -DryRun
```

Then a real read-only pass, and only afterwards a full maintenance cycle:

```powershell
.\RASE_v73.6.9.ps1 -Mode QuickScan
.\RASE_v73.6.9.ps1 -Mode Full -NoReboot
```

If your execution policy blocks scripts, launch it like this instead:

```powershell
powershell -ExecutionPolicy Bypass -File .\RASE_v73.6.9.ps1 -Mode Full -NoReboot
```

### Parameters

| Parameter | Effect |
|---|---|
| `-Mode Full` | Full six-phase cycle. This is the default. |
| `-Mode QuickScan` | Read-only. Diagnostics and reporting only; no writes of any kind. |
| `-DryRun` | Every write action is reported as skipped instead of performed. |
| `-NoReboot` | Absolute veto on rebooting, whatever else is requested. |
| `-AutoReboot` | Reboot without asking — only if the run completed without failures. |
| `-ApplyNtfsTuning` | Opt in to changing NTFS 8.3 and Last Access registry settings. Off by default; without it RASE only *reports* those settings. |
| `-ApplyVssPruning` | Opt in to deleting the oldest shadow copy on volumes over threshold. Off by default. |
| `-Silent` | Non-interactive: no dialogs, no prompts. For Task Scheduler and remote execution. |
| `-FullReport` | Extra detail in the report. |
| `-NoElevate` | Retained for command-line compatibility. Has no effect in this build. |

---

## What it changes on your system

In `Full` mode without extra switches, RASE will:

- create a System Restore point;
- delete the contents of `%WINDIR%\SoftwareDistribution\Download` (the Windows Update cache — Windows re-downloads what it needs);
- delete files in `%TEMP%` and `%WINDIR%\Temp` older than 72 hours, and directories left empty afterwards;
- empty the Recycle Bin;
- run TRIM on solid-state volumes;
- defragment rotational volumes **only** if measured fragmentation is at or above the threshold (15% by default);
- flush the DNS resolver cache;
- run CHKDSK in scan mode (read-only; it does not repair without a reboot), DISM and SFC.

It will **not**, unless you explicitly ask:

- change any NTFS behaviour setting (`-ApplyNtfsTuning`);
- delete shadow copies or restore points (`-ApplyVssPruning`);
- reboot the machine (`-AutoReboot`).

RASE skips TRIM and defragmentation on any volume whose status is `DIRTY`, `Errors` or
`TimedOut` — an unhealthy volume is not a good place to start moving data around.

---

## Reports

Reports are written to `D:\RASE_Reports\<year>\<month>\` when a fixed NTFS/ReFS volume `D:`
exists, otherwise to `%ProgramData%\RASE\Reports\`, with `%TEMP%` as a last resort. Each run
produces four files sharing one timestamp:

```
RASE_v7369_Report_2026-08-09_12-14.html      full report
RASE_v7369_Report_2026-08-09_12-14.json      machine-readable results
RASE_v7369_DiskTable_2026-08-09_12-14.csv    per-volume table
RASE_v7369_Transcript_2026-08-09_12-14.txt   console transcript
```

An errors file appears only when something actually logged an error — its absence is a
signal in itself.

### Exit codes

| Code | Meaning |
|---|---|
| `0` | Everything completed, nothing to report |
| `1` | Completed, but something warrants attention (warnings, skipped work, findings) |
| `2` | A phase or a tracked operation genuinely failed |
| `3` | An unhandled error escaped the pipeline, or no report directory could be created |

Exit code `1` is common and normal — for example when Windows Update is holding a file that
could not be deleted. It means the run finished and found something worth reading, not that
it broke.

---

## Configuration

Drop a `RASE.config.psd1` next to the script to override any threshold, weight or timeout.
Anything you leave out keeps its built-in default, and invalid values are rejected with an
explanation rather than silently accepted:

```powershell
@{
    Thresholds = @{
        FragmentationPercent = 10
        FreeSpaceWarningPercent = 15
    }
    Timeouts = @{
        CHKDSK = 10800
    }
    Ntfs = @{
        EightDotThreeTarget = 3
    }
}
```

Available groups: `Weights`, `Timeouts` (`CHKDSK`, `DISM`, `SFC`, `Defrag`, `REFS`, in
seconds), `Thresholds`, and `Ntfs`.

---

## Design notes

A few decisions that are easy to mistake for bugs:

- **No self-elevation.** Relaunching with `-Verb RunAs` creates a second console and makes
  the original process vanish mid-run. RASE refuses to run unelevated instead.
- **Detection is registry-first, text-parsing last.** Tool output is translated into the
  Windows display language; registry values and CIM properties are not. Where text must be
  parsed, RASE anchors on tokens that stay in English.
- **"Unknown" is a real answer.** A drive whose telemetry cannot be read is reported as
  unverified, not as healthy, and it does not lose points for it either.
- **Missing evidence never triggers an action.** If fragmentation cannot be measured,
  nothing is defragmented.

---

## Status and scope

v73.6.9 is a frozen baseline, accepted after a full acceptance run on real hardware. Known
open items are tracked for the next major revision:

- physical-device health and per-volume health share one table, so a physical disk holding
  two volumes is counted twice in the aggregate storage score;
- the Recycle Bin COM fallback path is reviewed by reading but has never been exercised at
  runtime, because the primary path has always succeeded.

---

## Disclaimer

RASE orchestrates Windows' own maintenance utilities. It deletes cached and temporary files
and can modify system settings when you explicitly ask it to. Use it on your own
responsibility, and use `-DryRun` first on any machine you care about.

The script is not code-signed.

---

## Licence

MIT — see [LICENSE](LICENSE).
