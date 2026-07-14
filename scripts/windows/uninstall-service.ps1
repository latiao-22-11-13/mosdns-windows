param(
    [string]$InstallDir = "$env:ProgramData\mosdns",
    [switch]$RemoveData
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
if (Test-Path -LiteralPath $binary) {
    & $binary service stop
    & $binary service uninstall
} else {
    $service = Get-Service -Name "mosdns" -ErrorAction SilentlyContinue
    if ($service) {
        Stop-Service -Name "mosdns" -ErrorAction SilentlyContinue
        sc.exe delete mosdns | Out-Null
    }
}

if ($RemoveData) {
    Remove-Item -LiteralPath $InstallDir -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "mosdns service removed and data deleted from $InstallDir"
} else {
    Write-Host "mosdns service removed. Data kept in $InstallDir"
}
