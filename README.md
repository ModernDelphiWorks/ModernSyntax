# ModernSyntax: Functional Programming Toolkit for Delphi

[![Delphi Supported Versions](https://img.shields.io/badge/Delphi%20Supported%20Versions-XE%2B-blue.svg)]()
[![License](https://img.shields.io/badge/License-LGPL--3.0-blue.svg)](LICENSE)

*   [🇬🇧 English](#-english)
*   [🇧🇷 Português](#-português)

---

## 🇬🇧 English

**ModernSyntax** is a high-performance, lightweight functional programming and modern syntax extension toolkit for Delphi. 

It modernizes Delphi coding paradigms, bringing them on par with features found in advanced contemporary languages like **Rust**, **Kotlin**, **C#**, and **Haskell**. Designed to bridge native Pascal syntax limitations, ModernSyntax introduces safe optional types, functional error flows, advanced pattern matching, asynchronous task scheduling, and currying.

---

### 🚀 Key Features & Architectural Paradigms

*   **Null Safety (`TOption<T>`):** Prevents common null pointer exceptions. Enforces strict and safe handling of optional values, in the style of Rust or Haskell.
*   **Functional Error Handling (`TResultPair<S, F>`):** Replaces messy or unpredicted exceptions with a clean, functional success/failure type.
*   **Pattern Matching (`TMatch<T>`):** Write expressive, type-safe conditional structures. Completely replaces long `if-else` or `case` statements.
*   **Simplified Asynchrony (`TScheduler`):** Introduces easy *async/await* task scheduling without the overhead of manual thread or task synchronization.
*   **Tuples & Destructuring (`TTuple<T>`):** Creates lightweight, anonymous data structures (e.g., `(1, 'a', True)`) with direct value extraction.
*   **Currying (`TCurrying`):** Introduces functional partial application (e.g., `f(x)(y)`), bringing Scala or Haskell paradigms to Delphi.

---

### ⚡️ Quick Start

#### 1. Null Safety (`TOption<T>`)
```delphi
uses ModernSyntax.Option;

var
  LName: TOption<string>;
begin
  // Create an optional value that may or may not exist
  LName := TOption<string>.Some('Isaque');
  
  if LName.HasValue then
    WriteLn('Value: ' + LName.Value)
  else
    WriteLn('No value found.');
    
  // Default fallback value
  WriteLn(LName.ValueOrElse('Default Name'));
end;
```

#### 2. Pattern Matching (`TMatch<T>`)
```delphi
uses ModernSyntax.Match;

var
  LInput: Integer;
  LMessage: string;
begin
  LInput := 2;
  
  // Clean, expressive matching
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
uses ModernSyntax.ResultPair;

function Divide(const A, B: Double): TResultPair<Double, string>;
begin
  if B = 0 then
    Result := TResultPair<Double, string>.Failure('Division by zero!')
  else
    Result := TResultPair<Double, string>.Success(A / B);
end;
```

---

### ⛏️ Contributing
We love contributions! Feel free to open issues or submit pull requests.

### 📬 Contact & Support
*   **Telegram**: [HashLoad Channel](https://t.me/hashload)
*   **Website**: [isaquepinheiro.com.br](https://www.isaquepinheiro.com.br)

---

## 🇧🇷 Português

**ModernSyntax** é um kit de ferramentas de alta performance e peso-pena para programação funcional e extensão de sintaxe moderna para Delphi.

Ele moderniza os paradigmas de codificação do Delphi, trazendo-o para o mesmo nível de recursos encontrados em linguagens contemporâneas avançadas como **Rust**, **Kotlin**, **C#** e **Haskell**. Desenvolvido para superar limitações da sintaxe nativa do Pascal, o ModernSyntax introduz tipos opcionais seguros, fluxo de erros funcional, pattern matching avançado, agendamento assíncrono e currying.

---

### 🚀 Recursos Principais & Paradigmas de Arquitetura

*   **Null Safety (`TOption<T>`):** Previne exceções clássicas de ponteiro nulo (Access Violation). Impõe a manipulação estrita e segura de valores opcionais, ao estilo de Rust ou Haskell.
*   **Tratamento de Erro Funcional (`TResultPair<S, F>`):** Substitui exceções desorganizadas por um tipo limpo e funcional de sucesso/falha.
*   **Pattern Matching (`TMatch<T>`):** Escreva estruturas condicionais expressivas e fortemente tipadas. Substitui cadeias complexas de `if-else` ou `case` de forma elegante.
*   **Assincronia Simplificada (`TScheduler`):** Introduz o agendamento de tarefas ao estilo *async/await* sem a complexidade de sincronização manual de threads.
*   **Tuplas & Desestruturação (`TTuple<T>`):** Cria estruturas leves de dados anônimos (ex: `(1, 'a', True)`) com extração direta de valores.
*   **Currying (`TCurrying`):** Introduz a aplicação parcial de funções (ex: `f(x)(y)`), trazendo paradigmas do Scala ou Haskell para o Delphi.

---

### ⚡️ Início Rápido

#### 1. Null Safety (`TOption<T>`)
```delphi
uses ModernSyntax.Option;

var
  LName: TOption<string>;
begin
  // Cria um valor opcional que pode ou não existir
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
uses ModernSyntax.Match;

var
  LInput: Integer;
  LMessage: string;
begin
  LInput := 2;
  
  // Casamento de padrões expressivo e limpo
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
uses ModernSyntax.ResultPair;

function Dividir(const A, B: Double): TResultPair<Double, string>;
begin
  if B = 0 then
    Result := TResultPair<Double, string>.Failure('Divisão por zero!')
  else
    Result := TResultPair<Double, string>.Success(A / B);
end;
```

---

### ⛏️ Contribuição
Adoramos contribuições! Sinta-se à vontade para abrir issues ou enviar pull requests.

### 📬 Contato & Suporte
*   **Telegram**: [Canal HashLoad](https://t.me/hashload)
*   **Website**: [isaquepinheiro.com.br](https://www.isaquepinheiro.com.br)

---
*Copyright © 2025-2026 Isaque Pinheiro. Licensed under LGPL-3.0 License.*
