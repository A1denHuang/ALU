$ErrorActionPreference = 'Stop'
$simDir = $PSScriptRoot
$runDo = Join-Path $simDir 'run.do'
$logPath = Join-Path $simDir 'regression.log'

$seedMatch = [regex]::Match((Get-Content $runDo -Raw), 'foreach seed \{([^}]+)\}')
if (-not $seedMatch.Success) {
    throw 'No seed list found in run.do.'
}
$seeds = @($seedMatch.Groups[1].Value.Trim() -split '\s+')

$command = Get-Command vsim -ErrorAction SilentlyContinue
if (Test-Path 'D:\Questasim\win64\vsim.exe') {
    $vsimExe = 'D:\Questasim\win64\vsim.exe'
} elseif ($command) {
    $vsimExe = $command.Source
} else {
    throw 'vsim.exe was not found. Add QuestaSim to PATH or update regress.ps1.'
}

Push-Location $simDir
try {
    $output = (& $vsimExe -c -do run.do 2>&1 | Out-String)
    $simExitCode = $LASTEXITCODE
    Set-Content -Path $logPath -Value $output -Encoding UTF8
} finally {
    Pop-Location
}

$results = @{}
foreach ($seed in $seeds) {
    $results[$seed] = [pscustomobject]@{
        Seed = $seed
        Pass = '-'
        Fail = '-'
        Coverage = '-'
        Completed = $false
    }
}

$currentSeed = $null
foreach ($line in ($output -split '\r?\n')) {
    if ($line -match '^# ===== SEED: (\d+) =====') {
        $currentSeed = $Matches[1]
    } elseif ($currentSeed -and $line -match '^# TEST SUMMARY: PASS=(\d+) FAIL=(\d+)') {
        $results[$currentSeed].Pass = $Matches[1]
        $results[$currentSeed].Fail = $Matches[2]
    } elseif ($currentSeed -and $line -match '^# OP COVERAGE: ([\d.]+)%') {
        $results[$currentSeed].Coverage = "$($Matches[1])%"
    } elseif ($currentSeed -and $line -match '^# TEST PASSED') {
        $results[$currentSeed].Completed = $true
    }
}

$failed = ($simExitCode -ne 0) -or ($output -match '(?m)^# \*\* (Error|Fatal):')
Write-Output 'ALU regression summary'
Write-Output 'Seed    PASS  FAIL  OP coverage  Status'
foreach ($seed in $seeds) {
    $row = $results[$seed]
    $ok = $row.Completed -and $row.Fail -eq '0' -and $row.Coverage -ne '-'
    if (-not $ok) { $failed = $true }
    $status = if ($ok) { 'PASS' } else { 'FAIL' }
    Write-Output ('{0,-7} {1,-5} {2,-5} {3,-12} {4}' -f $row.Seed, $row.Pass, $row.Fail, $row.Coverage, $status)
}
Write-Output "Full log: $logPath"
if ($failed) {
    throw 'Regression failed; inspect regression.log for the first error.'
}
