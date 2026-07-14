param(
    [string]$InstallDir = "$env:ProgramData\mosdns",
    [string]$BinaryPath = "",
    [string]$ConfigUrl = "https://raw.githubusercontent.com/jasonxtt/file/main/mosdns/config/config_all.zip",
    [switch]$Start,
    [switch]$Force
)

$ErrorActionPreference = "Stop"

function Assert-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw "Run this script from an elevated PowerShell window."
    }
}

function Resolve-SourceBinary {
    param([string]$PathFromUser)

    if ($PathFromUser) {
        return (Resolve-Path -LiteralPath $PathFromUser).Path
    }

    $scriptRoot = Split-Path -Parent $PSScriptRoot
    $packageRoot = Split-Path -Parent $scriptRoot
    $candidate = Join-Path $packageRoot "mosdns.exe"
    if (Test-Path -LiteralPath $candidate) {
        return (Resolve-Path -LiteralPath $candidate).Path
    }

    $cwdCandidate = Join-Path (Get-Location) "mosdns.exe"
    if (Test-Path -LiteralPath $cwdCandidate) {
        return (Resolve-Path -LiteralPath $cwdCandidate).Path
    }

    throw "Cannot find mosdns.exe. Pass -BinaryPath explicitly."
}

function Expand-ConfigPackage {
    param(
        [string]$Url,
        [string]$Destination
    )

    $configPath = Join-Path $Destination "config_custom.yaml"
    if ((Test-Path -LiteralPath $configPath) -and -not $Force) {
        Write-Host "Existing config_custom.yaml found; config package download skipped."
        return
    }

    $tempRoot = Join-Path ([IO.Path]::GetTempPath()) ("mosdns-config-" + [Guid]::NewGuid().ToString("N"))
    $zipPath = Join-Path $tempRoot "config_all.zip"
    New-Item -ItemType Directory -Force -Path $tempRoot | Out-Null
    try {
        Write-Host "Downloading config package..."
        Invoke-WebRequest -Uri $Url -OutFile $zipPath
        Expand-Archive -Path $zipPath -DestinationPath $tempRoot -Force

        $sourceRoot = $tempRoot
        $nested = Join-Path $tempRoot "config_all"
        if (Test-Path -LiteralPath $nested) {
            $sourceRoot = $nested
        }

        Copy-Item -Path (Join-Path $sourceRoot "*") -Destination $Destination -Recurse -Force
    }
    finally {
        Remove-Item -LiteralPath $tempRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Assert-Administrator

$sourceBinary = Resolve-SourceBinary -PathFromUser $BinaryPath
New-Item -ItemType Directory -Force -Path $InstallDir | Out-Null

$targetBinary = Join-Path $InstallDir "mosdns.exe"
Copy-Item -LiteralPath $sourceBinary -Destination $targetBinary -Force
Expand-ConfigPackage -Url $ConfigUrl -Destination $InstallDir

$configFile = Join-Path $InstallDir "config_custom.yaml"
if (-not (Test-Path -LiteralPath $configFile)) {
    throw "config_custom.yaml was not found in $InstallDir after setup."
}

Write-Host "Installing mosdns Windows service..."
& $targetBinary service install -d $InstallDir -c $configFile

if ($Start) {
    Write-Host "Starting mosdns service..."
    & $targetBinary service start
}

Write-Host "mosdns installed in $InstallDir"
Write-Host "WebUI is usually available at http://127.0.0.1:9099"
