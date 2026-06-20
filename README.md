# ModernSyntax Functional Programming Toolkit for Delphi

[![Delphi XE+](https://img.shields.io/badge/Delphi-XE%20or%20superior-blue.svg)]()
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![CRA-ready](https://img.shields.io/badge/CRA--ready-SBOM%20%2B%20Security%20policy-success)](https://www.pubpascal.dev/packages/modernsyntax)

> 🔒 **Supply-chain transparency (CRA-ready):** a machine-readable **SBOM** (CycloneDX) is published on the package portal — [pubpascal.dev/packages/modernsyntax](https://www.pubpascal.dev/packages/modernsyntax) · security disclosure policy in **[SECURITY.md](SECURITY.md)**.

*   [🇬🇧 English](#-english)
*   [🇧🇷 Português](#-português)

---

## 🇬🇧 English

**ModernSyntax** is a high-performance, lightweight functional programming and modern syntax extension toolkit for Delphi. It modernizes Delphi coding paradigms, bringing them on par with advanced features found in contemporary languages like **Rust**, **Kotlin**, **C#**, and **Haskell**. Designed to bridge native Pascal syntax limitations, ModernSyntax introduces safe optional types to prevent null-reference errors, functional error flows, advanced pattern matching, asynchronous task scheduling, and currying.

### 🚀 Key Features

*   **Null Safety (`TOption<T>`):** Enforces strict compile-time or runtime handling of optional values, preventing common Access Violations (null pointer exceptions) in the style of Rust or Haskell.
*   **Functional Error Handling (`TResultPair<S, F>`):** Replaces untracked exceptions with a clean, functional success/failure return type.
*   **Pattern Matching (`TMatch<T>`):** Expressive, type-safe matching structures to completely replace nested `if-else` or convoluted `case` statements.
*   **Simplified Asynchrony (`TScheduler`):** Easily schedule background tasks with an *async/await* style wrapper, without manual thread synchronization.
*   **Tuples & Destructuring (`TTuple<T>`):** Create lightweight, anonymous data structures (e.g., `(1, 'a', True)`) with direct value extraction.
*   **Currying (`TCurrying`):** Introduces functional partial applications, bringing Scala and Haskell functional programming paradigms directly to Delphi.

### 🏛 Compatibility Matrix

| Environment / IDE | Platform / Compiler | Null Safety | Pattern Matching |
| :--- | :--- | :---: | :---: |
| **Delphi XE or superior** | VCL, FMX, Console (Win/Linux/macOS/iOS/Android) | ✅ Yes | ✅ Yes |

### 🐧 Cross-Platform Build — Win32 / Win64 / Linux64 (verified)

> **✅ Verified 2026-06-20** in a real production backend: ModernSyntax compiles as a dependency on **Win32, Win64 and Linux64** (`dcclinux64`). macOS/iOS/Android follow from the Delphi RTL but are **not build-verified** here yet.

Windows-only APIs are guarded for non-Windows targets: `TDotEnv` uses a POSIX `setenv`/`unsetenv` shim (`Posix.Stdlib`) instead of `SetEnvironmentVariable`; `OutputDebugString` falls back to `stderr`; `InterlockedIncrement64` is replaced by the cross-platform `AtomicIncrement` intrinsic; bare `uses Windows` clauses are `{$IFDEF MSWINDOWS}`-guarded. Windows behaviour is unchanged.

**Building a consumer app for Linux64:** install the Linux 64-bit platform (RAD Studio GetIt / `GetItCmd -if=delphi_linux -ae`), provide a Linux SDK (RAD Studio SDK Manager + PAServer, **or** a sysroot assembled from a WSL/Linux toolchain passed to `dcclinux64` via `--syslibroot` / `--libpath`), then compile with `dcclinux64`.

### ⚙️ Installation

To install using the package manager [**Boss**](https://github.com/HashLoad/boss):

```sh
boss install ModernSyntax
```

---

### ⚡️ Quick Start

#### 1. Null Safety (`TOption<T>`)
```delphi
uses
  ModernSyntax.Option;

var
  LName: TOption<string>;
begin
  // Create an optional value
  LName := TOption<string>.Some('Isaque');
  
  if LName.HasValue then
    WriteLn('Value: ' + LName.Value)
  else
    WriteLn('No value found.');
    
  // Safe default fallback
  WriteLn(LName.ValueOrElse('Default Name'));
end;
```

#### 2. Pattern Matching (`TMatch<T>`)
```delphi
uses
  ModernSyntax.Match;

var
  LInput: Integer;
  LMessage: string;
begin
  LInput := 2;
  
  LMessage := TMatch<Integer>.Create(LInput)
    .CaseOf(1, 'First place!')
    .CaseOf(2, 'Second place!')
    .CaseOf(3, 'Third place!')
    .ElseOf('Runner up.')
    .MatchValue;
    
  // LMessage = 'Second place!'
end;
```

#### 3. Functional Results (`TResultPair<S, F>`)
```delphi
uses
  ModernSyntax.ResultPair;

function Divide(const A, B: Double): TResultPair<Double, string>;
begin
  if B = 0 then
    Result := TResultPair<Double, string>.Failure('Division by zero!')
  else
    Result := TResultPair<Double, string>.Success(A / B);
end;
```

---

## 🇧🇷 Português

**ModernSyntax** é um kit de ferramentas leve e de alta performance para programação funcional e extensão de sintaxe moderna em Delphi. Ele moderniza os paradigmas de codificação do Delphi, trazendo-os para o mesmo nível de recursos encontrados em linguagens contemporâneas avançadas como **Rust**, **Kotlin**, **C#** e **Haskell**. Desenvolvido para superar limitações da sintaxe nativa do Pascal, o ModernSyntax introduz tipos opcionais seguros para evitar erros de referência nula, fluxo de erros funcional, pattern matching avançado, agendamento assíncrono e currying.

### 🚀 Recursos Principais

*   **Null Safety (`TOption<T>`):** Impõe a manipulação estrita e segura de valores opcionais, prevenindo exceções clássicas de Access Violation (ponteiro nulo) ao estilo de Rust ou Haskell.
*   **Tratamento de Erros Funcional (`TResultPair<S, F>`):** Substitui exceções desorganizadas por um tipo limpo e funcional de sucesso/falha no retorno de métodos.
*   **Pattern Matching (`TMatch<T>`):** Estruturas condicionais expressivas e fortemente tipadas para substituir cadeias complexas de `if-else` ou blocos `case` limitados.
*   **Assincronia Simplificada (`TScheduler`):** Agende e gerencie tarefas assíncronas ao estilo *async/await* sem a complexidade de sincronização manual de threads.
*   **Tuplas & Desestruturação (`TTuple<T>`):** Cria estruturas leves de dados anônimos (ex: `(1, 'a', True)`) com extração direta de valores.
*   **Currying (`TCurrying`):** Introduz a aplicação parcial de funções, trazendo paradigmas de linguagens como Scala ou Haskell diretamente ao Delphi.

### 🏛 Matriz de Compatibilidade

| Ambiente / IDE | Plataforma / Compilador | Null Safety | Pattern Matching |
| :--- | :--- | :---: | :---: |
| **Delphi XE ou superior** | VCL, FMX, Console (Win/Linux/macOS/iOS/Android) | ✅ Sim | ✅ Sim |

### 🐧 Build Multiplataforma — Win32 / Win64 / Linux64 (verificado)

> **✅ Verificado em 2026-06-20** num backend real em produção: o ModernSyntax compila como dependência em **Win32, Win64 e Linux64** (`dcclinux64`). macOS/iOS/Android seguem da RTL Delphi, mas **ainda não foram verificados** em build aqui.

APIs Windows-only ficam guardadas para alvos não-Windows: o `TDotEnv` usa um shim POSIX `setenv`/`unsetenv` (`Posix.Stdlib`) no lugar de `SetEnvironmentVariable`; `OutputDebugString` cai para `stderr`; `InterlockedIncrement64` vira o intrínseco multiplataforma `AtomicIncrement`; cláusulas `uses Windows` ficam sob `{$IFDEF MSWINDOWS}`. O comportamento no Windows não muda.

**Para buildar um app consumidor no Linux64:** instale a plataforma Linux 64-bit (RAD Studio GetIt / `GetItCmd -if=delphi_linux -ae`), forneça um SDK Linux (SDK Manager do RAD Studio + PAServer, **ou** um sysroot montado de um toolchain WSL/Linux passado ao `dcclinux64` via `--syslibroot` / `--libpath`), e compile com `dcclinux64`.

### ⚙️ Instalação

Para instalar usando o gerenciador de pacotes [**Boss**](https://github.com/HashLoad/boss):

```sh
boss install ModernSyntax
```

---

### ⚡️ Início Rápido

#### 1. Null Safety (`TOption<T>`)
```delphi
uses
  ModernSyntax.Option;

var
  LName: TOption<string>;
begin
  // Cria um valor opcional
  LName := TOption<string>.Some('Isaque');
  
  if LName.HasValue then
    WriteLn('Valor: ' + LName.Value)
  else
    WriteLn('Nenhum valor encontrado.');
    
  // Valor padrão de fallback caso seja nulo
  WriteLn(LName.ValueOrElse('Nome Padrão'));
end;
```

#### 2. Pattern Matching (`TMatch<T>`)
```delphi
uses
  ModernSyntax.Match;

var
  LInput: Integer;
  LMessage: string;
begin
  LInput := 2;
  
  LMessage := TMatch<Integer>.Create(LInput)
    .CaseOf(1, 'Primeiro lugar!')
    .CaseOf(2, 'Segundo lugar!')
    .CaseOf(3, 'Terceiro lugar!')
    .ElseOf('Participante.')
    .MatchValue;
    
  // LMessage = 'Segundo lugar!'
end;
```

#### 3. Resultados Funcionais (`TResultPair<S, F>`)
```delphi
uses
  ModernSyntax.ResultPair;

function Dividir(const A, B: Double): TResultPair<Double, string>;
begin
  if B = 0 then
    Result := TResultPair<Double, string>.Failure('Divisão por zero!')
  else
    Result := TResultPair<Double, string>.Success(A / B);
end;
```

---
*Copyright © 2025-2026 Isaque Pinheiro. Licensed under MIT License.*
