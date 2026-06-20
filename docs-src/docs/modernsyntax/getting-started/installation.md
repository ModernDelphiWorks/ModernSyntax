---
displayed_sidebar: modernsyntaxSidebar
title: Installation
sidebar_position: 0
---

# Installation

## Via Boss (recommended)

[Boss](https://github.com/HashLoad/boss) is the community package manager for Delphi and Lazarus projects.

```sh
boss install ModernSyntax
```

Boss will download the package from [pubpascal.dev/packages/modernsyntax](https://www.pubpascal.dev/packages/modernsyntax) and add the source path to your project automatically.

## Via pubpascal

ModernSyntax is published on [pubpascal.dev](https://www.pubpascal.dev/packages/modernsyntax) with a machine-readable SBOM (CycloneDX) for supply-chain transparency. You can browse versions, review the security policy, and download tarballs directly.

## Manual installation

1. Clone or download the repository:

```sh
git clone https://github.com/ModernDelphiWorks/ModernSyntax.git
```

2. In RAD Studio / Delphi IDE, open **Project → Options → Delphi Compiler → Search path** and add the `Source\` directory.

3. Add the desired units to your `uses` clause:

```delphi
uses
  ModernSyntax.Option,
  ModernSyntax.ResultPair,
  ModernSyntax.Match;
```

## Minimum requirements

| Requirement | Value |
|---|---|
| Delphi version | XE or later |
| Target platforms | Win32, Win64, Linux64 (verified), macOS/iOS/Android (RTL-supported) |
| Dependencies | None (RTL only) |

## Cross-platform notes

Windows-only APIs are guarded for non-Windows targets:

- `TDotEnv` uses a POSIX `setenv`/`unsetenv` shim (`Posix.Stdlib`) instead of `SetEnvironmentVariable`.
- `OutputDebugString` falls back to `stderr`.
- `InterlockedIncrement64` is replaced by the cross-platform `AtomicIncrement` intrinsic.
- Bare `uses Windows` clauses are `{$IFDEF MSWINDOWS}`-guarded.

To build for **Linux64**, install the Linux 64-bit platform (RAD Studio GetIt / `GetItCmd -if=delphi_linux -ae`), provide a Linux SDK (SDK Manager + PAServer, or a sysroot assembled from a WSL/Linux toolchain passed to `dcclinux64` via `--syslibroot` / `--libpath`), then compile with `dcclinux64`.
