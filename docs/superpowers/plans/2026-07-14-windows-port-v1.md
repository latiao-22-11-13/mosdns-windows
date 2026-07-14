# Windows Port V1 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a usable Windows-focused mosdns package from the jasonxtt/mosdns codebase without changing DNS routing behavior.

**Architecture:** Keep the Go runtime and WebUI behavior intact. Add Windows packaging, service scripts, and documentation around the existing `mosdns service` commands and current Windows updater behavior.

**Tech Stack:** Go, Vue/Vite, GitHub Actions, PowerShell 5.1+, Windows Service via `github.com/kardianos/service`.

## Global Constraints

- Do not reintroduce nft or eBPF support.
- Do not change `requiredConfigSchema` or `requiredConfigPackageID`.
- Use `C:\ProgramData\mosdns` as the default Windows runtime directory.
- First Windows release may stage binary updates as `mosdns.exe.new`; automatic replacement of a running executable is out of scope.

---

### Task 1: Windows Package Outputs

**Files:**
- Modify: `.github/workflows/release.yml`
- Modify: `.github/workflows/release-main.yml`

**Interfaces:**
- Consumes: existing UI build and Go build steps.
- Produces: release assets named `mosdns-<version>-windows-amd64.zip`, `mosdns-<version>-windows-amd64-v3.zip`, and `mosdns-<version>-windows-arm64.zip`.

- [x] Add Windows matrix entries with `ext: .exe` and `archive_ext: zip`.
- [x] Package Windows assets as zip files containing `mosdns.exe`, `README.md`, `LICENSE`, `docs/windows/README_WINDOWS.md`, and `scripts/windows/*.ps1`.
- [x] Publish both `*.tar.gz` and `*.zip` assets.

### Task 2: Windows Service Scripts

**Files:**
- Create: `scripts/windows/install-service.ps1`
- Create: `scripts/windows/uninstall-service.ps1`
- Create: `scripts/windows/replace-binary.ps1`

**Interfaces:**
- Consumes: `mosdns.exe service install|start|stop|uninstall`.
- Produces: repeatable Windows install, uninstall, and staged-update replacement flows.

- [x] Install script creates `C:\ProgramData\mosdns`, copies `mosdns.exe`, downloads `config_all.zip` on fresh installs, installs the service, and optionally starts it.
- [x] Uninstall script stops and removes the service, with optional data deletion.
- [x] Replacement script stops the service, replaces `mosdns.exe` from `mosdns.exe.new`, and restarts the service.

### Task 3: Windows Operator Docs

**Files:**
- Create: `docs/windows/README_WINDOWS.md`
- Modify: `README.md`

**Interfaces:**
- Consumes: release zip contents from Task 1 and scripts from Task 2.
- Produces: a Windows-first installation and update path.

- [x] Document admin PowerShell install, service management, WebUI URL, config path, updater behavior, and excluded Linux-only features.
- [x] Add a short Windows fork notice at the top of README.

### Task 4: Verification

**Files:**
- Validate: `.github/workflows/*.yml`
- Validate: `scripts/windows/*.ps1`

**Interfaces:**
- Consumes: edited scripts/workflows.
- Produces: local syntax validation results.

- [ ] Run PowerShell parser checks against scripts.
- [ ] Run text checks for release asset names and publish globs.
- [ ] Report unavailable Go/Node build checks if local toolchain is missing.
