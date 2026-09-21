$ErrorActionPreference = "Stop"
Push-Location $PSScriptRoot
try {
    & vsim -c -do run.do
    if ($LASTEXITCODE -ne 0) {
        throw "Simulation failed with exit code $LASTEXITCODE"
    }
}
finally {
    Pop-Location
}
