# Changelog

All notable changes to RASE. Version numbers are the value of `$Global:RaseVersion`
inside the script; the same history is kept in the `.NOTES` block of the source file.

This log is written from the perspective of *why* each change was made, because most
of them exist to correct a specific wrong behaviour rather than to add a feature.

## v73.6.9

Transcript hygiene in the cleanup engine. No functional change.

- Recycle Bin COM fallback item removal uses the same verify-after-delete pattern as Windows Update and Temp cleanup, preventing expected locked-item failures from creating terminating-error transcript noise while preserving deleted/failed accounting.
- Windows Update cache and temp-file removals use -ErrorAction SilentlyContinue and then verify with Test-Path, instead of -ErrorAction Stop inside a try/catch. A file held open by Windows Update or by a running process is an expected outcome of these operations, but under $ErrorActionPreference = "Stop" each one became a terminating error, and Start-Transcript recorded "PS>TerminatingError(Remove-Item)" in the protocol even though the catch handled it. A correctly accounted condition read like a crash to anyone opening the transcript.
- Accounting is unchanged in intent and slightly stronger in fact: a removal now counts as successful only when the item is verifiably gone, rather than when no exception was raised. A partially deleted directory still exists and is still counted as failed.
- The temp-file loop had the same pattern and was fixed with it. It never fired on the acceptance machine only because every matched file happened to be unlocked; on a busier system it could have produced dozens of those lines.
- Temp directory removals keep their previous accounting exactly, including the fact that a directory which cannot be removed is not counted as a failure.
- Nothing else touched: Defrag, NTFS, VSS, WU status logic, scoring, disk detection, Restore Point, single-console elevation, reboot handling and the phase pipeline are all unchanged.

## v73.6.8

Corrections driven by a direct probe of the target machine rather than by inference. The observed output contradicted two assumptions carried since v73.6.5.

- "fsutil behavior query disable8dot3" prints a fully localized sentence with NO English token on a localized build - not the registry value name, not "disable8dot3". The English-anchor tiers can never resolve 8.3 there, so a separator-anchored parse is restored as a third tier. It matches only a number immediately following '=' or ':' (punctuation is not translated) and takes the first such number, because a scan for "any digit" would return the 8 or the 3 out of the word "8dot3".
- NtfsDisableLastAccessUpdate does not use the documented 0-3 encoding. The probe read 0x80000001 on a volume fsutil describes as system-managed with updates disabled, which is state 3. Bit 31 is the system-managed flag and bit 0 is the disable bit, so the previous "-band 0x3" returned 1 and silently reported the volume as user-managed. Decoding is now per-behavior: disable8dot3 keeps the plain 0-3 encoding, where the same transform would have turned "per volume policy" (2) into 0.
- Changelog rebuilt into a linear sequence; the invented "v73.6.6-a" label is gone and the Single-Console work is described inside the v73.6.6 entry it actually shipped with.

## v73.6.7

Re-merge plus two findings from the first Full acceptance runs.

- Re-applies v73.6.5, which was lost: v73.6.6 was branched from v73.6.4, so the per- behavior fsutil anchor list, the system-managed high-bit handling and the fsutil diagnostic echo were silently reverted. Nothing in v73.6.6 replaced them.
- fsutil is now called with $ErrorActionPreference temporarily set to Continue. In Windows PowerShell 5.1, "2>&1" on a native command while the preference is Stop turns any stderr output into a terminating NativeCommandError, which aborts the function before the output can be parsed or even recorded - the most likely reason the v73.6.5 diagnostic line never appeared in the report.
- Fragmentation analysis moved to Win32_Volume.DefragAnalysis. Optimize-Volume -Analyze writes its report to the verbose stream and returns nothing on the output stream, so $analysis.PercentFragmentation was always $null and the defrag path took the "no usable data" branch on every disk on every machine. RASE refused to defragment safely rather than wrongly, but the feature had never actually run. Optimize-Volume is kept as a secondary attempt.
- Stop-Transcript now runs before the "press Enter to close" wait. Until it does, the transcript has no footer; both Full acceptance transcripts arrived truncated because of it, and a console closed with the X button would leave the file incomplete for good.
- Changelog corrected: v73.6.6 was used twice as a heading (the WU accounting fix and the Single-Console edition), and v73.6.5 had no entry at all.

## v73.6.6

Windows Update cleanup accounting fix and Single-Console Safety Edition.

- A Windows Update cache cleanup run with failed removals and zero successful deletions is now reported as Warning instead of incorrectly being reported as OK/"nothing removable".
- Cleanup:WU operation status, HTML reporting, recommendations and exit-code aggregation now remain consistent with the actual removal failures.
- Interactive runs no longer self-elevate into a second PowerShell window. RASE now requires the current console to already be elevated and stops cleanly with an actionable message when Administrator privileges are missing.
- The legacy -NoElevate switch is retained for command-line compatibility but no longer launches a second process; it has no effect in the elevated path.
- After the reboot dialog, choosing LATER leaves the same console open and shows a final completion block; the operator must press Enter to close the session.
- Headless/Silent execution remains non-blocking and does not wait for input.
- No maintenance engine, phase pipeline, scoring, report schema or exit-code changes.

## v73.6.5

Fsutil detection fix. Lost when v73.6.6 branched from v73.6.4; re-applied in v73.6.7 and corrected against real output in v73.6.8.

- Each fsutil behavior carries an ordered list of English anchor tokens.
- ConvertTo-RaseFsBehaviorValue handles the system-managed bit that a plain [int] comparison could never match.
- The report echoes the raw fsutil output when Last Access detection fails.

## v73.6.4

Correction to the v73.6.3 micro-fix.

- Enable-ComputerRestore is best-effort again. v73.6.3 gave it -ErrorAction Stop, which made a failed preparation step abort the checkpoint it was preparing for: where System Protection is already on but the enable call errors anyway, Checkpoint-Computer was never attempted even though it could have succeeded. The enable failure is now recorded and reported as context only if the checkpoint also fails.
- $systemDrive and $enableError declared before the try, so the catch block can read them under Set-StrictMode -Version Latest regardless of where the failure occurred.
- Changelog corrected: v73.6.3 was applied twice as a heading, which renamed the v73.6.2 entry and left the file with two v73.6.3 sections and no v73.6.2. Its own heading also read "after v73.6.3 audit" rather than v73.6.2.

## v73.6.3

Micro-fix after the v73.6.2 audit.

- Restore Point creation now targets the actual Windows system volume from $env:SystemDrive instead of assuming C:, with strict validation before Enable-ComputerRestore.
- Physical-disk UniqueId matching now uses an explicit non-empty string check instead of PowerShell truthiness, avoiding ambiguous empty identifiers.
- No changes to the maintenance engine, phase pipeline, scoring, Safety Gate scope, diagnostics, optimization actions or exit-code architecture.

## v73.6.2

Correction to the v73.6.1 SFC precedence.

- SFC reports Repaired again when the exit code is 0 AND CBS.log shows repair activity in the run window. v73.6.1 collapsed that case into OK, which made [HealthStatus]::Repaired unreachable for SFC: a machine whose system files had to be repaired scored identically to one where nothing was ever wrong, and the 5-point System Integrity penalty that Repaired carries was never applied. The v73.6.1 ordering is otherwise kept - the exit code is still evaluated before CBS evidence in every ambiguous case.
- CBS timestamps are whitespace-normalised before TryParseExact, so a line padded with more than one space between date and time is not counted as an unparseable record.
- Changelog restructured: v73.6.1 replaced the v73.6 heading in place, which left the v73.6 entry with no heading of its own and its opening sentence merged into v73.6.1's.

## v73.6.1

Safety & Evidence Pass. Hardens the v73.6 Event Viewer, SFC evidence handling and Safety Gate messaging.

- Event Viewer readability probe now uses Get-WinEvent -ListLog System instead of requiring at least one event. An empty-but-readable System log is no longer misclassified as unreadable. A disabled System log is reported explicitly and does not manufacture zero-event health data.
- CBS.log timestamp filtering now parses timestamps into DateTime values with invariant formats instead of comparing timestamp strings. Unparseable CBS records are ignored rather than used to make a time-window decision.
- SFC evidence precedence is hardened: an explicit unrepairable CBS finding is fatal; otherwise the SFC process exit code is evaluated before a generic repaired-file token can promote the run. A repaired-file token can only produce Repaired when the process did not report an unresolved execution result.
- Safety Gate guidance no longer assumes Windows is installed on C:. It identifies the actual Windows system volume dynamically in the recommendation text.

## v73.6

Final pass before publication. Closes every open item from the v73.5.x reviews and the first runtime QuickScan; no change to the maintenance engine, the phase pipeline, the scoring rules or the exit-code logic.

- WinRE now raises a recommendation. Previously a disabled recovery environment cost 8 points of Maintenance Readiness and one summary line but never reached Recommended Actions, and an undetermined state reached neither.
- Dirty-bit volumes whose state could not be resolved are reported in a single recommendation instead of one per volume, and the unreachable per-row catch (the CIM query moved out of the loop in v73.5.1) no longer claims a Failed status it can never set.
- Event Viewer probes the System log once before reporting. Get-WinEvent raises a non-terminating error when nothing matches and -ErrorAction SilentlyContinue swallows it, so a clean 30-day history and an unreadable log were both arriving as zero.
- ReFS timeout moved from a hardcoded 900 into Timeouts.REFS, so it is overridable in RASE.config.psd1 and range-validated like every other timeout.
- JSON export records Mode, ApplyNtfsTuning and ApplyVssPruning. The artifact previously could not state which mode produced it; the mode had to be inferred from the number of phases in PhaseStatus.
- Version string unified across .SYNOPSIS, .DESCRIPTION, the MONOLITH banner and $Global:RaseVersion.

## v73.5.1

Final locale-neutral safety pass: the source file is pure ASCII and contains no Russian or other localized detection strings. Locale-sensitive command text is never used as the primary decision source.

- WinRE state is read from System32\Recovery\ReAgent.xml (fixed element and attribute names on every locale) instead of matching translated "reagentc /info" prose. The reagentc probe remains as a fallback, matched on the locale-invariant \\?\GLOBALROOT device path. Localized status words are never parsed.
- The dism.exe fallback path no longer carries one translation of "no corruption detected" per language. It recognises the English verdicts, and on any other locale reports Warning with an explanation instead of assuming corruption and launching a full RestoreHealth on no evidence.
- Dirty Bit detection now uses Win32_Volume.DirtyBitSet as the structured primary source; fsutil dirty output and undocumented exit-code semantics are no longer used for state.
- NTFS fsutil fallback no longer parses generic English prose; an unresolved value is reported as Unknown rather than inferred from localized text.
- WinRE reagentc fallback no longer parses English status words; only the invariant GLOBALROOT device path is accepted when the XML source is unavailable.
- Degree sign written as the HTML entity &deg;; all em dashes replaced with hyphens. The file no longer contains a single byte above 0x7F, which means a missing UTF-8 BOM can no longer corrupt it.
- No change to the maintenance engine, the phase pipeline, the scoring rules or the exit-code logic.

## v73.4.2

Hardening after the first runtime QuickScan.

- PendingFileRenameOperations read through a property-existence check, so a provider read failure cannot manufacture a pending reboot.
- Separate $Global:Timeout_REFS instead of borrowing the DISM timeout.
- ReFS scan failure and Windows Update cache cleanup failure each raise a Priority 1 recommendation, using Sources that match their operation names.
- "Last Boot Time" relabelled "Boot Duration" - the value is how long the last boot took, not when it happened.

## v73.4

Corrections to the v73.3 Safety Pass. Production candidate hardening:

- AutoReboot now checks both real failures and incomplete phases explicitly, matching the safety comment and preventing future phase-level skip paths from being overlooked.
- Interactive reboot wording distinguishes failure/incomplete runs from clean completion.
- Restore point timestamps are converted from WMI DMTF format before comparison. Get-ComputerRestorePoint returns CreationTime as a string like "20260808153000.000000-000"; casting that with [datetime] throws, so under $ErrorActionPreference = "Stop" the "existing recent restore point" lookup always came back empty and the Safety Gate blocked far more than intended.
- Safety Gate narrowed to the operations a System Restore point can actually roll back: NTFS behaviour tuning (registry) and VSS shadow-copy deletion (irreversible). Cleanup, TRIM and Defrag are no longer gated - restore points do not cover user files or volume layout, and both already refuse to run on a volume marked DIRTY/Errors/TimedOut.
- Gate moved inside those two functions, after their read-only assessment, so the detect-only NTFS report and the VSS shadow-copy inventory still reach the report when no rollback point exists.
- Gate recommendation is emitted once per operation instead of once per disk task.
- "SafetyGate" added to the Source-to-Phase map; its findings were invisible in the Issues Logged column.
- "SMART Data Unavailable" rule restored with a default penalty of 0. v73.3 deleted the rule and zeroed the weight, which left Weights.SMARTUnavailable as a config key that silently does nothing and made an unverifiable disk report FinalStatus "OK".

## v73.3

Hardened Safety Pass on v73.2.

- CHKDSK non-zero scan results are now tracked as Failed consistently with the operation registry, disk row status, and exit-code engine.
- Physical-disk matching no longer treats two null UniqueIds as a match; UniqueId comparison is used only when both identifiers are present, otherwise Disk Number is authoritative.
- Storage Reliability / SMART-proxy unavailability no longer reduces physical health score; telemetry availability remains a separate Priority-3 recommendation.
- Restore Point protection is now a real safety gate for higher-risk Full-mode writes. A recent existing restore point within 24h counts as usable protection.
- If Full mode has no usable recent restore point, cleanup, TRIM, Defrag, VSS pruning, and NTFS tuning are skipped rather than making higher-risk writes without rollback.
- DryRun/QuickScan behavior remains non-blocking and read-only.

## v73.2

Audit follow-up on v73.1.

- Invoke-AnimatedTask captures the child exit code before cleanup and disposes the Process object; a full run started ~28 processes and released none of their handles
- DiskRules now penalises DefragStatus "TimedOut", not only "Failed". A timed-out defrag already forced exit code 2 but left the disk score and FinalStatus untouched
- Volume rows are matched with -eq "<letter>:" instead of the regex -match <letter>
- Invoke-RaseBackgroundJob clamps a missing/zero timeout instead of treating it as an instant timeout (Wait-Job -Timeout 0 returns immediately)
- Banner credit line matched to the header block (the two had drifted apart)
- v73.1 changelog corrected - see below

## v73.1

Validation pass on v73.0.

- Phase-level Skipped separated from Failed in the exit-code engine and in the report wording. NOTE: a phase is only ever marked Skipped by Invoke-RasePhase when one of its dependencies failed, so in practice a Skipped phase is always accompanied by a Failed one and the run still exits 2. The separation is defensive, not a behaviour change, and there is currently no "intentional skip" path at phase level - QuickScan simply builds a shorter pipeline instead of skipping phases.
- Cascaded "phase skipped because X failed" recommendations dropped to Priority 2 so the root-cause Priority 1 entry from the failing phase stays at the top of the list.
- ReFS integrity moved onto the shared Invoke-RaseBackgroundJob wrapper (which gained -ArgumentList), so it inherits the same timeout and cleanup handling as DISM.
- Background-job cleanup guaranteed through try/finally.
- Obsolete "Ultimate" branding removed from UI/title strings.

## v73.0

Audit follow-up on v72.0. Changes owned by this revision:

- Set-RaseOperationStatus now escalates only (OK < Skipped < Repaired < Warning < Failed), so a later volume in the same loop can no longer downgrade an earlier Failed
- Restore Point "Warning" state re-connected to the Maintenance Readiness penalty (the v72 rename left that branch unreachable)
- Restore Point recommendation Source renamed to "SystemRestorePoint" so the phase issue table stops counting one finding twice
- Event Viewer Disk/NTFS counts split into Error (Level 2) and Warning (Level 3); only errors raise a recommendation. BSOD/bugcheck events now raise one too
- NTFS Last Access tuning preserves the management mode (sets value -bor 1, so system-managed stays system-managed) instead of forcing user-managed 1
- NTFS 8.3 target is configurable (Ntfs.EightDotThreeTarget, default 3 = disabled on all volumes except the system volume) and never loosens a stricter existing setting
- $profile renamed to $hwProfile (it shadowed a PowerShell automatic variable)

## v72.0

Hardening pass on v71.0:

- SMART terminology corrected to "Storage Reliability / SMART-proxy"
- Initialize-HtmlReport and Get-HardwareProfile survive unavailable WMI/CIM classes
- DISM result-shape guards; unusable result reported as Warning instead of throwing
- Temp cleanup only removes directories left empty by the file pass
- Event Viewer Disk/NTFS findings surfaced as recommendations
- WHEA re-sourced to a new "Hardware" phase-map key
- Last Access state expanded to the documented four values
- VSS deletion failure raised from Warning to Failed

## v71.0

Consolidation of the v70.5 (Claude) and v70.8/70.9 (Lira) branches. Kept from the 70.8/70.9 branch:

- Unified operation-status registry (Set-RaseOperationStatus) + Warning-level exit code
- Per-volume VSS storage accounting instead of a system-wide figure
- Capability-aware optimization plan (NTFS/ReFS filtering, media-aware actions)
- Honest QuickScan scoring (System Integrity reported as N/A, not 100%)
- Windows Update cache cleanup with guaranteed service-state restoration (finally)
- AutoReboot blocked after a failed/incomplete pipeline
- NTFS 8dot3 / LastAccess treated as multi-valued settings with a post-change verify Corrected in v71.0:
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
