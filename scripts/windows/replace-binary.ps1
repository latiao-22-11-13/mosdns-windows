param(
    [string]$InstallDir = "$env:ProgramData\mosdns",
    [string]$NewBinary = ""
)

$ErrorActionPreference = "Stop"

function Assert-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Run this script from an elevated PowerShell window."
    }
}

Assert-Administrator

$binary = Join-Path $InstallDir "mosdns.exe"
if (-not $NewBinary) {
    $NewBinary = "$binary.new"
}

if (-not (Test-Path -LiteralPath $binary)) {
    throw "Current binary not found: $binary"
}
if (-not (Test-Path -LiteralPath $NewBinary)) {
    throw "New binary not found: $NewBinary"
}

$stamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backup = Join-Path $InstallDir "mosdns.exe.$stamp.bak"

Write-Host "Stopping mosdns service..."
& $binary service stop

Write-Host "Backing up current binary to $backup"
Move-Item -LiteralPath $binary -Destination $backup -Force

try {
    Move-Item -LiteralPath $NewBinary -Destination $binary -Force
    Write-Host "Starting mosdns service..."
    & $binary service start
    Write-Host "mosdns binary replaced successfully."
}
catch {
    if ((-not (Test-Path -LiteralPath $binary)) -and (Test-Path -LiteralPath $backup)) {
        Move-Item -LiteralPath $backup -Destination $binary -Force
    }
    throw
}
