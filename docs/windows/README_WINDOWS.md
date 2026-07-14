# mosdns Windows deployment

This repository is a Windows-focused import of `jasonxtt/mosdns`.

The DNS core and WebUI behavior are kept aligned with the upstream fork. The Windows layer provides native release zips, service installation scripts, a ProgramData runtime directory, and a safe manual binary replacement flow.

## Runtime layout

Default runtime directory:

```text
C:\ProgramData\mosdns
```

Expected files after installation:

```text
C:\ProgramData\mosdns\mosdns.exe
C:\ProgramData\mosdns\config_custom.yaml
C:\ProgramData\mosdns\sub_config\...
C:\ProgramData\mosdns\webinfo\...
C:\ProgramData\mosdns\state\...
```

The WebUI listens on the port defined by the config package. Fresh jasonxtt config packages normally use:

```text
http://127.0.0.1:9099
```

## Fresh install

1. Download a Windows zip release:

```text
mosdns-<version>-windows-amd64.zip
mosdns-<version>-windows-amd64-v3.zip
mosdns-<version>-windows-arm64.zip
```

2. Extract the zip to any temporary folder.

3. Open PowerShell as Administrator in the extracted folder.

4. Install and start the Windows service:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\windows\install-service.ps1 -Start
```

The script copies `mosdns.exe` to `C:\ProgramData\mosdns`, downloads the maintained `config_all.zip` package when no config exists, installs the Windows service, and starts it when `-Start` is passed.

## Custom install directory

```powershell
.\scripts\windows\install-service.ps1 -InstallDir "D:\Services\mosdns" -Start
```

The install directory must be writable by the service account and should not be a synced cloud folder.

## Service commands

From an elevated PowerShell:

```powershell
& "C:\ProgramData\mosdns\mosdns.exe" service status
& "C:\ProgramData\mosdns\mosdns.exe" service stop
& "C:\ProgramData\mosdns\mosdns.exe" service start
& "C:\ProgramData\mosdns\mosdns.exe" service restart
```

## Uninstall

Stop and remove the Windows service while keeping config and state:

```powershell
.\scripts\windows\uninstall-service.ps1
```

Remove service and data:

```powershell
.\scripts\windows\uninstall-service.ps1 -RemoveData
```

## Updating on Windows

Windows locks a running executable. The built-in updater stages the downloaded binary beside the current executable as:

```text
mosdns.exe.new
```

Apply the staged binary:

```powershell
.\scripts\windows\replace-binary.ps1
```

The script stops the service, backs up the current `mosdns.exe`, moves `mosdns.exe.new` into place, and starts the service again.

## Config packages

Fresh installs use:

```text
https://raw.githubusercontent.com/jasonxtt/file/main/mosdns/config/config_all.zip
```

Incremental config updates use:

```text
https://raw.githubusercontent.com/jasonxtt/file/main/mosdns/config/config_up.zip
```

For Windows v1, structural config migrations are intentionally conservative. If the WebUI says a release requires config migration, download and apply the matching config package deliberately instead of relying on automatic replacement.

## Linux-only features

This Windows fork does not support Linux-only nftables or eBPF flows. Those features are not part of the jasonxtt fork direction and are not required for native Windows deployment.

## Firewall and DNS takeover

The install script does not automatically change Windows DNS adapter settings or firewall policy. Configure the client or router to use the Windows host as DNS only after confirming the WebUI and service are healthy.
