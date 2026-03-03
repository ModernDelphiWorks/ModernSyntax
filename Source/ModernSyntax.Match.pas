{
  ------------------------------------------------------------------------------
  ModernSyntax
  Bringing modern language syntax and paradigms to Delphi through classes and methods.

  SPDX-License-Identifier: Apache-2.0
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the Apache License, Version 2.0.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

unit ModernSyntax.Match;

interface

uses
  Rtti,
  SysUtils,
  TypInfo,
  Variants,
  Classes,
  Generics.Collections,
  Generics.Defaults,
  ModernSyntax.Std,
  ModernSyntax.RegExpression,
  ModernSyntax.ResultPair,
  ModernSyntax;

type
  TCaseType = (
    ctCaseIfProc,    // 0
    ctCaseIfFunc,    // 1
    ctCaseEqProc,    // 2
    ctCaseEqFunc,    // 3
    ctCaseGtProc,    // 4
    ctCaseGtFunc,    // 5
    ctCaseLtProc,    // 6
    ctCaseLtFunc,    // 7
    ctCaseInProc,    // 8
    ctCaseInFunc,    // 9
    ctCaseIsProc,    // 10
    ctCaseIsFunc,    // 11
    ctCaseRangeProc, // 12
    ctCaseRangeFunc, // 13
    ctDefaultProc,   // 14
    ctDefaultFunc,   // 15
    ctTryExcept      // 16
  );

  PTuple = ^Tuple;
  Tuple = ModernSyntax.Tuple;

  // Enumeration to represent different states of the match session
  {$SCOPEDENUMS ON}
  TMatchSession = (sMatch, sGuard, sCase, sDefault, sTryExcept);
  {$SCOPEDENUMS OFF}

  TCaseGroup = TDictionary<TValue, TValue>;

  // Class implementing the pattern matching
  TMatch<T> = record
  private
    FValue: TValue;           // Value to be matched
  strict private
    // Class variables to store relevant matching information
    FResult: TValue;          // Result to be matched
    FSession: TMatchSession;  // Current state of the matching session
    FUseGuard: Boolean;       // Indicates if guard is being used
    FUseRegex: Boolean;       // Indicates if regex is being used
    FGuardCount: Integer;     // Counter for guard
    FRegexCount: Integer;     // Counter for regex
    FCases: array[TCaseType] of TCaseGroup;
    FCombines: TList<TValue>;
  strict private
    // Private Guards
    function _MatchingProcCaseIf: Boolean; inline;
    function _MatchingFuncCaseIf: Boolean; inline;
    // Private methods for different types of matching
    function _MatchingProcCaseEq: Boolean; inline;
    function _MatchingFuncCaseEq: Boolean; inline;
    function _MatchingProcCaseGt: Boolean; inline;
    function _MatchingFuncCaseGt: Boolean; inline;
    function _MatchingProcCaseLt: Boolean; inline;
    function _MatchingFuncCaseLt: Boolean; inline;
    function _MatchingProcCaseIn: Boolean; inline;
    function _MatchingFuncCaseIn: Boolean;  inline;
    function _MatchingProcCaseIs: Boolean; inline;
    function _MatchingFuncCaseIs: Boolean; inline;
    function _MatchingProcCaseRange: Boolean; inline;
    function _MatchingFuncCaseRange: Boolean; inline;
    function _MatchingProcDefault: Boolean; inline;
    function _MatchingFuncDefault: Boolean; inline;
    function _MatchingTryExcept: Boolean; inline;
    // Private methods for array comparison
    function _ArraysAreEqual(const Arr1: TValue; const Arr2: TValue): Boolean; inline;
    function _ArraysAreEqualInteger(const Arr1: TValue; const Arr2: TValue): Boolean; inline;
    function _ArraysAreEqualChar(const Arr1: TValue; const Arr2: TValue): Boolean; inline;
    function _ArraysAreEqualString(const Arr1: TValue; const Arr2: TValue): Boolean; inline;
    function _ArraysAreEqualTuple(const Arr1: TValue; const Arr2: TValue): Boolean; inline;
    function _ArraysAreNotEqualCaseIf(const APair: TPair<TValue, TValue>): Boolean; inline;
    // Private methods for checking array types
    function _IsArrayInteger(const AValue: TValue): Boolean; inline;
    function _IsArrayChar(const AValue: TValue): Boolean; inline;
    function _IsArrayString(const AValue: TValue): Boolean; inline;
    function _IsArrayTuplePair(const AValue: TValue): Boolean; inline;
    // Private methods for executing anonymous methods
    function _ExecuteFuncMatchingCaseIf(const ProcValue: TValue): Boolean; inline;
    procedure _ExecuteProcMatchingCaseIf(const ProcValue: TValue); inline;
    procedure _ExecuteProcMatchingEq(const ProcPair: TPair<TValue, TValue>); inline;
    procedure _ExecuteFuncMatchingEq(const FuncValue: TValue); inline;
    procedure _ExecuteProcMatchingGt(const ProcValue: TValue); inline;
    procedure _ExecuteFuncMatchingGt(const FuncValue: TValue); inline;
    procedure _ExecuteProcMatchingLt(const ProcValue: TValue); inline;
    procedure _ExecuteFuncMatchingLt(const FuncValue: TValue); inline;
    procedure _ExecuteProcMatchingIn(const ProcPair: TPair<TValue, TValue>); inline;
    procedure _ExecuteFuncMatchingIn(const FuncValue: TValue); inline;
    procedure _ExecuteProcMatchingIs(const ProcValue: TValue); inline;
    procedure _ExecuteFuncMatchingIs(const FuncValue: TValue); inline;
    procedure _ExecuteProcMatchingRange(const ProcPair: TPair<TValue, TValue>); inline;
    procedure _ExecuteFuncMatchingRange(const FuncValue: TValue); inline;
    // Guards
    function _ExecuteProcCaseIf: Boolean; inline;
    function _ExecuteFuncCaseIf: Boolean; inline;
    // Private methods for managing the toxicity of the Execute() method
    function _ExecuteProcSession: Boolean; inline;
    function _ExecuteProcGuard: Boolean; inline;
    function _ExecuteProcRegex: Boolean; inline;
    function _ExecuteProcCaseEq: Boolean; inline;
    function _ExecuteFuncCaseEq: Boolean; inline;
    function _ExecuteProcCaseGt: Boolean; inline;
    function _ExecuteFuncCaseGt: Boolean; inline;
    function _ExecuteProcCaseLt: Boolean; inline;
    function _ExecuteFuncCaseLt: Boolean; inline;
    function _ExecuteProcCaseIn: Boolean; inline;
    function _ExecuteFuncCaseIn: Boolean; inline;
    function _ExecuteProcCaseIs: Boolean; inline;
    function _ExecuteFuncCaseIs: Boolean; inline;
    function _ExecuteProcCaseRange: Boolean; inline;
    function _ExecuteFuncCaseRange: Boolean; inline;
    function _ExecuteProcCaseDefault: Boolean; inline;
    function _ExecuteFuncCaseDefault: Boolean; inline;
    function _ExecuteProcCombine: Boolean; inline;
    function _ExecuteProcCasesValidation: TResultPair<Boolean, String>; inline;
    function _ExecuteFuncCasesValidation<R>: TResultPair<R, String>; inline;
    //
    function _IsEquals<I>(const ALeft: I; ARight: I): Boolean; inline;
    // Private method for resetting variables
    procedure _StartVariables; inline;
    // Private method for releasing variables
    procedure _Dispose; inline;
    procedure _CheckTupleWildcard(LTuple1: PTuple; var LTuple2: Tuple); inline;
    constructor Create(const AValue: T);
  public
    class function Value(const AValue: T): TMatch<T>; static; inline;
    function CaseIf(const ACondition: Boolean): TMatch<T>; overload; inline;
    function CaseIf(const ACondition: Boolean; const AProc: TProc): TMatch<T>; overload; inline;
    function CaseIf(const ACondition: Boolean; const AProc: TProc<T>): TMatch<T>; overload; inline;
    function CaseIf(const ACondition: Boolean; const AFunc: TFunc<Boolean>): TMatch<T>; overload; inline;
    function CaseIf(const ACondition: Boolean; const AFunc: TFunc<T, Boolean>): TMatch<T>; overload; inline;
    function CaseEq(const AValue: T; const AProc: TProc): TMatch<T>; overload; inline;
    function CaseEq(const AValue: T; const AProc: TProc<T>): TMatch<T>; overload; inline;
    function CaseEq(const AValue: T; const AProc: TProc<TValue>): TMatch<T>; overload; inline;
    function CaseEq(const AValue: T; const AFunc: TFunc<TValue>): TMatch<T>; overload; inline;
    function CaseEq(const AValue: T; const AFunc: TFunc<T, TValue>): TMatch<T>; overload; inline;
    function CaseEq(const AValue: Tuple; const AFunc: TFunc<Tuple, TValue>): TMatch<T>; overload; inline;
    function CaseGt(const AValue: T; const AProc: TProc): TMatch<T>; overload; inline;
    function CaseGt(const AValue: T; const AFunc: TFunc<TValue>): TMatch<T>; overload; inline;
    function CaseGt(const AValue: T; const AProc: TProc<T>): TMatch<T>; overload; inline;
    function CaseGt(const AValue: T; const AFunc: TFunc<T, TValue>): TMatch<T>; overload; inline;
    function CaseLt(const AValue: T; const AProc: TProc): TMatch<T>; overload; inline;
    function CaseLt(const AValue: T; const AFunc: TFunc<TValue>): TMatch<T>; overload; inline;
    function CaseLt(const AValue: T; const AProc: TProc<T>): TMatch<T>; overload; inline;
    function CaseLt(const AValue: T; const AFunc: TFunc<T, TValue>): TMatch<T>; overload;
    function CaseIn(const ARange: TArray<T>; const AProc: TProc): TMatch<T>; overload; inline;
    function CaseIn(const ARange: TArray<T>; const AProc: TProc<TValue>): TMatch<T>; overload; inline;
    function CaseIn(const ARange: TArray<T>; const AFunc: TFunc<TValue>): TMatch<T>; overload; inline;
    function CaseIn(const ARange: TArray<T>; const AProc: TProc<T>): TMatch<T>; overload; inline;
    function CaseIn(const ARange: TArray<T>; const AFunc: TFunc<T, TValue>): TMatch<T>; overload; inline;
    function CaseIn(const ASet: TSysCharSet; const AProc: TProc): TMatch<T>; overload; inline;
    function CaseIn(const ASet: TSysCharSet; const AProc: TProc<TValue>): TMatch<T>; overload; inline;
    function CaseIn(const ASet: TSysCharSet; const AFunc: TFunc<TValue>): TMatch<T>; overload; inline;
    function CaseIn(const ASet: TSysCharSet; const AProc: TProc<T>): TMatch<T>; overload; inline;
    function CaseIn(const ASet: TSysCharSet; const AFunc: TFunc<T, TValue>): TMatch<T>; overload; inline;
    function CaseIn(const ASet: TIntegerSet; const AProc: TProc): TMatch<T>; overload;
    function CaseIn(const ASet: TIntegerSet; const AProc: TProc<TValue>): TMatch<T>; overload; inline;
    function CaseIn(const ASet: TIntegerSet; const AFunc: TFunc<TValue>): TMatch<T>; overload; inline;
    function CaseIn(const ASet: TIntegerSet; const AProc: TProc<T>): TMatch<T>; overload; inline;
    function CaseIn(const ASet: TIntegerSet; const AFunc: TFunc<T, TValue>): TMatch<T>; overload; inline;
    function CaseIs<Typ>(const AProc: TProc): TMatch<T>; overload; //inline;
    function CaseIs<Typ>(const AFunc: TFunc<TValue>): TMatch<T>; overload; //inline;
    function CaseIs<Typ>(const AProc: TProc<Typ>): TMatch<T>; overload; //inline;
    function CaseIs<Typ>(const AFunc: TFunc<Typ, TValue>): TMatch<T>; overload; //inline;
    function CaseRange(const AStart, AEnd: T; const AProc: TProc): TMatch<T>; overload; inline;
    function CaseRange(const AStart, AEnd: T; const AFunc: TFunc<TValue>): TMatch<T>; overload; inline;
    function CaseRange(const AStart, AEnd: T; const AProc: TProc<T>): TMatch<T>; overload; inline;
    function CaseRange(const AStart, AEnd: T; const AFunc: TFunc<T, TValue>): TMatch<T>; overload; inline;
    function CaseRegex(const AInput: String; const APattern: String): TMatch<T>; inline;
    function Default(const AProc: TProc): TMatch<T>; overload; inline;
    function Default(const AProc: TProc<TValue>): TMatch<T>; overload; inline;
    function Default(const AFunc: TFunc<TValue>): TMatch<T>; overload; inline;
    function Default(const AFunc: TFunc<T, TValue>): TMatch<T>; overload; inline;
    function Default(const AValue: T; const AProc: TProc<T>): TMatch<T>; overload; inline;
    function Combine(const AMatch: TMatch<T>): TMatch<T>; inline;
    function TryExcept(AProc: TProc): TMatch<T>; inline;
    function Execute: TResultPair<Boolean, String>; overload; inline;
    function Execute<R>: TResultPair<R, String>; overload; inline;
  end;

  TMatch = class
  protected
    class var FMatch: TValue;
  public
    class function Value<T>: T;
  end;

implementation

const
  CASE_IF_PROC = ctCaseIfProc;
  CASE_IF_FUNC = ctCaseIfFunc;
  CASE_EQ_PROC = ctCaseEqProc;
  CASE_EQ_FUNC = ctCaseEqFunc;
  CASE_GT_PROC = ctCaseGtProc;
  CASE_GT_FUNC = ctCaseGtFunc;
  CASE_LT_PROC = ctCaseLtProc;
  CASE_LT_FUNC = ctCaseLtFunc;
  CASE_IN_PROC = ctCaseInProc;
  CASE_IN_FUNC = ctCaseInFunc;
  CASE_IS_PROC = ctCaseIsProc;
  CASE_IS_FUNC = ctCaseIsFunc;
  CASE_RANGE_PROC = ctCaseRangeProc;
  CASE_RANGE_FUNC = ctCaseRangeFunc;
  DEFAULT_PROC = ctDefaultProc;
  DEFAULT_FUNC = ctDefaultFunc;
  TRY_EXCEPT = ctTryExcept;

class function TMatch<T>.Value(const AValue: T): TMatch<T>;
begin
  Result := TMatch<T>.Create(AValue);
  TMatch.FMatch := TValue.From<TMatch<T>>(Result);
end;

constructor TMatch<T>.Create(const AValue: T);
var
  LCaseType: TCaseType;
begin
  FCombines := TList<TValue>.Create;
  FCombines.Capacity := 10;
  for LCaseType := Low(TCaseType) to High(TCaseType) do
  begin
    FCases[LCaseType] := TCaseGroup.Create;
    FCases[LCaseType].Capacity := 10;
  end;
  FValue := TValue.From<T>(AValue);
  // Private method for resetting variables.
  _StartVariables;
end;

function TMatch<T>.TryExcept(AProc: TProc): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sCase, TMatchSession.sDefault]) then
    Exit;
  FCases[TRY_EXCEPT].AddOrSetValue(TValue.From<Boolean>(True),
                                   TValue.From<TProc>(AProc));
  Result.FSession := TMatchSession.sTryExcept;
end;

function TMatch<T>.CaseRange(const AStart, AEnd: T; const AProc: TProc<T>): TMatch<T>;
var
  LRange: TPair<T, T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  LRange := TPair<T, T>.Create(AStart, AEnd);
  FCases[CASE_RANGE_PROC].AddOrSetValue(TValue.From<TPair<T, T>>(LRange),
                                        TValue.From<TProc<T>>(AProc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseRange(const AStart, AEnd: T; const AFunc: TFunc<TValue>): TMatch<T>;
var
  LRange: TPair<T, T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  LRange := TPair<T, T>.Create(AStart, AEnd);
  FCases[CASE_RANGE_FUNC].AddOrSetValue(TValue.From<TPair<T, T>>(LRange),
                                        TValue.From<TFunc<TValue>>(AFunc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseRange(const AStart, AEnd: T; const AFunc: TFunc<T, TValue>): TMatch<T>;
var
  LRange: TPair<T, T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  LRange := TPair<T, T>.Create(AStart, AEnd);
  FCases[CASE_RANGE_FUNC].AddOrSetValue(TValue.From<TPair<T, T>>(LRange),
                                        TValue.From<TFunc<T, TValue>>(AFunc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseRegex(const AInput: String; const APattern: String): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  if TEvolutionRegEx.IsMatch(AInput, APattern) then
    Result.FRegexCount := Result.FRegexCount + 1
  else
    Result.FRegexCount := Result.FRegexCount - 1;
  Result.FSession := TMatchSession.sCase;
  Result.FUseRegex := True;
end;

function TMatch<T>.CaseIs<Typ>(const AFunc: TFunc<Typ, TValue>): TMatch<T>;
var
  LTypeKind: TTypeKind;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  if TypeInfo(Typ) = TypeInfo(TDateTime) then
    FCases[CASE_IS_FUNC].AddOrSetValue(TValue.From<TTypeKind>(tkFloat),
                                       TValue.From<TFunc<Typ, TValue>>(AFunc))
  else
  begin
    LTypeKind := PTypeInfo(TypeInfo(Typ))^.Kind;
    FCases[CASE_IS_FUNC].AddOrSetValue(TValue.From<TTypeKind>(LTypeKind),
                                       TValue.From<TFunc<Typ, TValue>>(AFunc));
  end;
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseIs<Typ>(const AFunc: TFunc<TValue>): TMatch<T>;
var
  LTypeKind: TTypeKind;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  if TypeInfo(Typ) = TypeInfo(TDateTime) then
    FCases[CASE_IS_FUNC].AddOrSetValue(TValue.From<TTypeKind>(tkFloat),
                                       TValue.From<TFunc<TValue>>(AFunc))
  else
  begin
    LTypeKind := PTypeInfo(TypeInfo(Typ))^.Kind;
    FCases[CASE_IS_FUNC].AddOrSetValue(TValue.From<TTypeKind>(LTypeKind),
                                       TValue.From<TFunc<TValue>>(AFunc));
  end;
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseIs<Typ>(const AProc: TProc<Typ>): TMatch<T>;
var
  LTypeKind: TTypeKind;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  if TypeInfo(Typ) = TypeInfo(TDateTime) then
    FCases[CASE_IS_PROC].AddOrSetValue(TValue.From<TTypeKind>(tkFloat),
                                       TValue.From<TProc<Typ>>(AProc))
  else
  begin
    LTypeKind := PTypeInfo(TypeInfo(Typ))^.Kind;
    FCases[CASE_IS_PROC].AddOrSetValue(TValue.From<TTypeKind>(LTypeKind),
                                       TValue.From<TProc<Typ>>(AProc));
  end;
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseLt(const AValue: T; const AProc: TProc): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  FCases[CASE_LT_PROC].AddOrSetValue(TValue.From<T>(AValue),
                                     TValue.From<TProc>(AProc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseLt(const AValue: T; const AProc: TProc<T>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  FCases[CASE_LT_PROC].AddOrSetValue(TValue.From<T>(AValue),
                                     TValue.From<TProc<T>>(AProc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseLt(const AValue: T; const AFunc: TFunc<TValue>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  FCases[CASE_LT_FUNC].AddOrSetValue(TValue.From<T>(AValue),
                                     TValue.From<TFunc<TValue>>(AFunc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseLt(const AValue: T; const AFunc: TFunc<T, TValue>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  FCases[CASE_LT_FUNC].AddOrSetValue(TValue.From<T>(AValue),
                                     TValue.From<TFunc<T, TValue>>(AFunc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseRange(const AStart, AEnd: T; const AProc: TProc): TMatch<T>;
var
  LRange: TPair<T, T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  LRange := TPair<T, T>.Create(AStart, AEnd);
  FCases[CASE_RANGE_PROC].AddOrSetValue(TValue.From<TPair<T, T>>(LRange),
                                        TValue.From<TProc>(AProc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseEq(const AValue: T; const AProc: TProc): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  FCases[CASE_EQ_PROC].AddOrSetValue(TValue.From<T>(AValue),
                                     TValue.From<TProc>(AProc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseEq(const AValue: T; const AProc: TProc<T>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  FCases[CASE_EQ_PROC].AddOrSetValue(TValue.From<T>(AValue),
                                     TValue.From<TProc<T>>(AProc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseEq(const AValue: T; const AFunc: TFunc<TValue>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  FCases[CASE_EQ_FUNC].AddOrSetValue(TValue.From<T>(AValue),
                                     TValue.From<TFunc<TValue>>(AFunc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseEq(const AValue: T; const AFunc: TFunc<T, TValue>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  FCases[CASE_EQ_FUNC].AddOrSetValue(TValue.From<T>(AValue),
                                     TValue.From<TFunc<T, TValue>>(AFunc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseGt(const AValue: T; const AProc: TProc): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  FCases[CASE_GT_PROC].AddOrSetValue(TValue.From<T>(AValue),
                                     TValue.From<TProc>(AProc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseGt(const AValue: T; const AProc: TProc<T>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  FCases[CASE_GT_PROC].AddOrSetValue(TValue.From<T>(AValue),
                                     TValue.From<TProc<T>>(AProc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseGt(const AValue: T; const AFunc: TFunc<TValue>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  FCases[CASE_GT_FUNC].AddOrSetValue(TValue.From<T>(AValue),
                                     TValue.From<TFunc<TValue>>(AFunc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseGt(const AValue: T; const AFunc: TFunc<T, TValue>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  FCases[CASE_GT_FUNC].AddOrSetValue(TValue.From<T>(AValue),
                                     TValue.From<TFunc<T, TValue>>(AFunc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseIf(const ACondition: Boolean; const AProc: TProc<T>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard]) then
    Exit;
  if ACondition then
  begin
    FCases[CASE_IF_PROC].AddOrSetValue(TValue.From<Boolean>(ACondition),
                                       TValue.From<TProc<T>>(AProc));
    Result.FSession := TMatchSession.sGuard;
  end;
end;

function TMatch<T>.CaseIf(const ACondition: Boolean; const AProc: TProc): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard]) then
    Exit;
  if ACondition then
  begin
    FCases[CASE_IF_PROC].AddOrSetValue(TValue.From<Boolean>(ACondition),
                                       TValue.From<TProc>(AProc));
    Result.FSession := TMatchSession.sGuard;
  end;
end;

function TMatch<T>.CaseIf(const ACondition: Boolean; const AFunc: TFunc<T, Boolean>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard]) then
    Exit;
  if ACondition then
  begin
    FCases[CASE_IF_FUNC].AddOrSetValue(TValue.From<Boolean>(ACondition),
                                       TValue.From<TFunc<T, Boolean>>(AFunc));
    Result.FSession := TMatchSession.sGuard;
  end;
end;

function TMatch<T>.CaseIf(const ACondition: Boolean;
  const AFunc: TFunc<Boolean>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard]) then
    Exit;
  if ACondition then
  begin
    FCases[CASE_IF_FUNC].AddOrSetValue(TValue.From<Boolean>(ACondition),
                                       TValue.From<TFunc<Boolean>>(AFunc));
    Result.FSession := TMatchSession.sGuard;
  end;
end;

function TMatch<T>.CaseIn(const ARange: TArray<T>; const AProc: TProc<T>): TMatch<T>;
var
  LFor: Integer;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  for LFor := Low(ARange) to High(ARange) do
    FCases[CASE_IN_PROC].AddOrSetValue(TValue.From<T>(ARange[LFor]),
                                       TValue.From<TProc<T>>(AProc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseIn(const ARange: TArray<T>; const AFunc: TFunc<TValue>): TMatch<T>;
var
  LFor: Integer;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  for LFor := Low(ARange) to High(ARange) do
    FCases[CASE_IN_FUNC].AddOrSetValue(TValue.From<T>(ARange[LFor]),
                                       TValue.From<TFunc<TValue>>(AFunc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseIn(const ARange: TArray<T>; const AFunc: TFunc<T, TValue>): TMatch<T>;
var
  LFor: Integer;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  for LFor := Low(ARange) to High(ARange) do
    FCases[CASE_IN_FUNC].AddOrSetValue(TValue.From<T>(ARange[LFor]),
                                       TValue.From<TFunc<T, TValue>>(AFunc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseIn(const ARange: TArray<T>; const AProc: TProc<TValue>): TMatch<T>;
var
  LFor: Integer;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  for LFor := Low(ARange) to High(ARange) do
    FCases[CASE_IN_PROC].AddOrSetValue(TValue.From<T>(ARange[LFor]),
                                       TValue.From<TProc<TValue>>(AProc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseIs<Typ>(const AProc: TProc): TMatch<T>;
var
  LTypeKind: TTypeKind;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  if TypeInfo(Typ) = TypeInfo(TDateTime) then
    FCases[CASE_IS_PROC].AddOrSetValue(TValue.From<TTypeKind>(tkFloat),
                                       TValue.From<TProc>(AProc))
  else
  begin
    LTypeKind := PTypeInfo(TypeInfo(Typ))^.Kind;
    FCases[CASE_IS_PROC].AddOrSetValue(TValue.From<TTypeKind>(LTypeKind),
                                       TValue.From<TProc>(AProc));
  end;
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.Default(const AValue: T; const AProc: TProc<T>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sCase]) then
    Exit;
  FCases[DEFAULT_PROC].AddOrSetValue(TValue.From<T>(AValue),
                                     TValue.From<TProc<T>>(AProc));
  Result.FSession := TMatchSession.sDefault;
end;

function TMatch<T>.Default(const AFunc: TFunc<TValue>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sCase]) then
    Exit;
  FCases[DEFAULT_FUNC].AddOrSetValue(TValue.From<Boolean>(True),
                                     TValue.From<TFunc<TValue>>(AFunc));
  Result.FSession := TMatchSession.sDefault;
end;

function TMatch<T>.Default(const AFunc: TFunc<T, TValue>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sCase]) then
    Exit;
  FCases[DEFAULT_FUNC].AddOrSetValue(TValue.From<Boolean>(True),
                                     TValue.From<TFunc<T, TValue>>(AFunc));
  Result.FSession := TMatchSession.sDefault;
end;

function TMatch<T>.Default(const AProc: TProc<TValue>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sCase]) then
    Exit;
  FCases[DEFAULT_PROC].AddOrSetValue(TValue.From<Boolean>(True),
                                     TValue.From<TProc<TValue>>(AProc));
  Result.FSession := TMatchSession.sDefault;
end;

function TMatch<T>.Default(const AProc: TProc): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sCase]) then
    Exit;
  FCases[DEFAULT_PROC].AddOrSetValue(TValue.From<Boolean>(True),
                                     TValue.From<TProc>(AProc));
  Result.FSession := TMatchSession.sDefault;
end;

function TMatch<T>.CaseIn(const ARange: TArray<T>; const AProc: TProc): TMatch<T>;
var
  LFor: Integer;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  for LFor := Low(ARange) to High(ARange) do
    FCases[CASE_IN_PROC].AddOrSetValue(TValue.From<T>(ARange[LFor]),
                                       TValue.From<TProc>(AProc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.Execute: TResultPair<Boolean, String>;
begin
  try
    if not _ExecuteProcSession then
    begin
      Result := TResultPair<Boolean, String>.Failure('Use Execute after session [sCase, sDefault, sTryExcept]');
      Exit;
    end
    else
    if (not _ExecuteProcGuard) or (not _ExecuteProcRegex) then
    begin
      Result := TResultPair<Boolean, String>.Failure('No matching Guard/Regex.');
      Exit;
    end;
    try
      Result := _ExecuteProcCasesValidation;
    except
      on E: Exception do
      begin
        Result := TResultPair<Boolean, String>.Failure(E.Message);
        try
          if (FCases[TRY_EXCEPT].Count > 0) and (_MatchingTryExcept) then
            Exit;
        except
          on E: Exception do
            Result := TResultPair<Boolean, String>.Failure(Result.ValueFailure + sLineBreak + E.Message);
        end;
      end;
    end;
  finally
    _Dispose;
  end;
end;

function TMatch<T>.Execute<R>: TResultPair<R, String>;
begin
  try
    if not _ExecuteProcSession then
    begin
      Result := TResultPair<R, String>.Failure('Use Execute after session [sCase, sDefault, sTryExcept]');
      Exit;
    end
    else
    if (not _ExecuteProcGuard) or (not _ExecuteProcRegex) then
    begin
      Result := TResultPair<R, String>.Failure('No matching Guard/Regex.');
      Exit;
    end;
    try
      Result := _ExecuteFuncCasesValidation<R>;
    except
      on E: Exception do
      begin
        Result := TResultPair<R, String>.Failure(E.Message);
        try
          if (FCases[TRY_EXCEPT].Count > 0) and (_MatchingTryExcept) then
            Exit;
        except
          on E: Exception do
            Result := TResultPair<R, String>.Failure(Result.ValueFailure + sLineBreak + E.Message);
        end;
      end;
    end;
  finally
    _Dispose;
  end;
end;

function TMatch<T>._ExecuteProcCasesValidation: TResultPair<Boolean, String>;
begin
  if (not _ExecuteProcCaseIf) or (not _ExecuteFuncCaseIf) then
  begin
    Exit;
  end;
  if (_ExecuteProcCombine) or (_ExecuteProcCaseEq) or (_ExecuteProcCaseGt) or
     (_ExecuteProcCaseLt) or (_ExecuteProcCaseIn) or (_ExecuteProcCaseIs) or
     (_ExecuteProcCaseRange) or (_ExecuteProcCaseDefault) then
  begin
    Result := TResultPair<Boolean, String>.Success(True);
    Exit;
  end;
  Result := TResultPair<Boolean, String>.Failure('No matching case found.');
end;

function TMatch<T>._ExecuteProcCombine: Boolean;
var
  LMatch: TValue;
  LResult: TResultPair<Boolean, String>;
begin
  Result := False;
  if FCombines.Count = 0 then
    Exit;
  try
    for LMatch in FCombines do
    begin
      LResult := LMatch.AsType<TMatch<T>>.Execute;
      if LResult.isSuccess then
        Result := True;
    end;
  except
    on E: Exception do
      Result := False;
  end;
end;

function TMatch<T>._ExecuteProcSession: Boolean;
begin
  Result := True;
  if not (FSession in [TMatchSession.sCase, TMatchSession.sDefault, TMatchSession.sTryExcept]) then
    Result := False;
end;

function TMatch<T>._ExecuteProcGuard: Boolean;
begin
  Result := True;
  if not FUseGuard then
    FGuardCount := 1;
  if FGuardCount <= 0 then
    Result := False
end;

function TMatch<T>._ExecuteProcRegex: Boolean;
begin
  Result := True;
  if not FUseRegex then
    FRegexCount := 1;
  if FRegexCount <= 0 then
    Result := False;
end;

function TMatch<T>._ExecuteProcCaseIf: Boolean;
begin
  Result := True;
  if (FCases[CASE_IF_PROC].Count > 0) and (not _MatchingProcCaseIf) then
    Result := False;
end;

function TMatch<T>._ExecuteProcCaseEq: Boolean;
begin
  Result := False;
  if (FCases[CASE_EQ_PROC].Count > 0) and  (_MatchingProcCaseEq) then
    Result := True;
end;

function TMatch<T>._ExecuteProcCaseGt: Boolean;
begin
  Result := False;
  if (FCases[CASE_GT_PROC].Count > 0) and  (_MatchingProcCaseGt) then
    Result := True;
end;

function TMatch<T>._ExecuteProcCaseIn: Boolean;
begin
  Result := False;
  if (FCases[CASE_IN_PROC].Count > 0) and (_MatchingProcCaseIn) then
    Result := True;
end;

function TMatch<T>._ExecuteProcCaseLt: Boolean;
begin
  Result := False;
  if (FCases[CASE_LT_PROC].Count > 0) and  (_MatchingProcCaseLt) then
    Result := True;
end;

function TMatch<T>._ExecuteProcCaseRange: Boolean;
begin
  Result := False;
  if (FCases[CASE_RANGE_PROC].Count > 0) and (_MatchingProcCaseRange) then
    Result := True;
end;

function TMatch<T>._ExecuteProcCaseDefault: Boolean;
begin
  Result := False;
  if (FCases[DEFAULT_PROC].Count > 0) and (_MatchingProcDefault) then
    Result := True;
end;

function TMatch<T>._ExecuteProcCaseIs: Boolean;
begin
  Result := False;
  if (FCases[CASE_IS_PROC].Count > 0) and (_MatchingProcCaseIs) then
    Result := True;
end;

function TMatch<T>._ExecuteFuncCaseDefault: Boolean;
begin
  Result := False;
  if (FCases[DEFAULT_FUNC].Count > 0) and (_MatchingFuncDefault) then
    Result := True;
end;

function TMatch<T>._ExecuteFuncCaseEq: Boolean;
begin
  Result := False;
  if (FCases[CASE_EQ_FUNC].Count > 0) and  (_MatchingFuncCaseEq) then
    Result := True;
end;

function TMatch<T>._ExecuteFuncCaseGt: Boolean;
begin
  Result := False;
  if (FCases[CASE_GT_FUNC].Count > 0) and  (_MatchingFuncCaseGt) then
    Result := True;
end;

function TMatch<T>._ExecuteFuncCaseIf: Boolean;
begin
  Result := True;
  if (FCases[CASE_IF_FUNC].Count > 0) and (not _MatchingFuncCaseIf) then
    Result := False;
end;

function TMatch<T>._ExecuteFuncCaseIn: Boolean;
begin
  Result := False;
  if (FCases[CASE_IN_FUNC].Count > 0) and (_MatchingFuncCaseIn) then
    Result := True;
end;

function TMatch<T>._ExecuteFuncCaseIs: Boolean;
begin
  Result := False;
  if (FCases[CASE_IS_FUNC].Count > 0) and (_MatchingFuncCaseIs) then
    Result := True;
end;

function TMatch<T>._ExecuteFuncCaseLt: Boolean;
begin
  Result := False;
  if (FCases[CASE_LT_FUNC].Count > 0) and  (_MatchingFuncCaseLt) then
    Result := True;
end;

function TMatch<T>._ExecuteFuncCaseRange: Boolean;
begin
  Result := False;
  if (FCases[CASE_RANGE_FUNC].Count > 0) and (_MatchingFuncCaseRange) then
    Result := True;
end;

function TMatch<T>._ExecuteFuncCasesValidation<R>: TResultPair<R, String>;
begin
  if (not _ExecuteProcCaseIf) or (not _ExecuteFuncCaseIf) then
  begin
    Result := TResultPair<R, String>.Failure('No matching Guard.');
    Exit;
  end;
  if FCombines.Count > 0 then
  begin
    Result := TResultPair<R, String>.Failure('The Combine method should be called with Execute() instead of Execute<T>.');
    Exit;
  end;
  if (_ExecuteFuncCaseEq) or (_ExecuteFuncCaseGt) or (_ExecuteFuncCaseLt) or
     (_ExecuteFuncCaseIn) or (_ExecuteFuncCaseIs) or (_ExecuteFuncCaseRange) or
     (_ExecuteFuncCaseDefault) then
  begin
    Result := TResultPair<R, String>.Success(FResult.AsType<R>);
    Exit;
  end;
  Result := TResultPair<R, String>.Failure('No matching case found.');
end;

function TMatch<T>._ArraysAreNotEqualCaseIf(const APair: TPair<TValue, TValue>): Boolean;
begin
  Result := False;
  if not _ArraysAreEqual(FValue, APair.Key) then
    Result := True;
end;

function TMatch<T>._ArraysAreEqual(const Arr1, Arr2: TValue): Boolean;
begin
  Result := False;
  if _IsArrayInteger(Arr1) then
    Result := _ArraysAreEqualInteger(Arr1, Arr2)
  else
  if _IsArrayString(Arr1) then
    Result := _ArraysAreEqualString(Arr1, Arr2)
  else
  if _IsArrayChar(Arr1) then
    Result := _ArraysAreEqualChar(Arr1, Arr2)
  else
  if _IsArrayTuplePair(Arr1) then
    Result := _ArraysAreEqualTuple(Arr1, Arr2)
end;

function TMatch<T>._ArraysAreEqualChar(const Arr1, Arr2: TValue): Boolean;
var
  LArray1: TArray<Char>;
  LArray2: TArray<Char>;
  LFor: Integer;
begin
  Result := False;
  LArray1 := Arr1.AsType<TArray<Char>>;
  LArray2 := Arr2.AsType<TArray<Char>>;
  if Length(LArray1) <> Length(LArray2) then
    Exit;
  for LFor := Low(LArray1) to High(LArray1) do
  begin
    if LArray1[LFor] <> LArray2[LFor] then
      Exit;
  end;
  Result := True;
end;

function TMatch<T>._ArraysAreEqualInteger(const Arr1, Arr2: TValue): Boolean;
var
  LArray1: TArray<Integer>;
  LArray2: TArray<Integer>;
  LFor: Integer;
begin
  Result := False;
  LArray1 := Arr1.AsType<TArray<Integer>>;
  LArray2 := Arr2.AsType<TArray<Integer>>;
  if Length(LArray1) <> Length(LArray2) then
    Exit;
  for LFor := Low(LArray1) to High(LArray1) do
  begin
    if LArray1[LFor] <> LArray2[LFor] then
      Exit;
  end;
  Result := True;
end;

function TMatch<T>._ArraysAreEqualString(const Arr1, Arr2: TValue): Boolean;
var
  LArray1: TArray<String>;
  LArray2: TArray<String>;
  LFor: Integer;
begin
  Result := False;
  LArray1 := Arr1.AsType<TArray<String>>;
  LArray2 := Arr2.AsType<TArray<String>>;
  if Length(LArray1) <> Length(LArray2) then
    Exit;
  for LFor := Low(LArray1) to High(LArray1) do
  begin
    if LArray1[LFor] <> LArray2[LFor] then
      Exit;
  end;
  Result := True;
end;

function TMatch<T>._ArraysAreEqualTuple(const Arr1, Arr2: TValue): Boolean;
var
  LTuple1: Tuple;
  LTuple2: Tuple;
  LFor: Integer;
begin
  Result := False;
  LTuple1 := Arr1.AsType<Tuple>;
  LTuple2 := Arr2.AsType<Tuple>;
  //
  _CheckTupleWildcard(@LTuple1, LTuple2);
  //
  if Length(LTuple1) <> Length(LTuple2) then
    Exit;
  for LFor := Low(LTuple1) to High(LTuple1) do
  begin
    if LTuple2[LFor].ToString = '_' then
      Continue;
    if LTuple2[LFor].ToString = '_*' then
      Continue;
    if LTuple1[LFor].ToString <> LTuple2[LFor].ToString then
      Exit;
  end;
  Result := True;
end;

procedure TMatch<T>._CheckTupleWildcard(LTuple1: PTuple; var LTuple2: Tuple);
var
  LValue: TValue;
  LFor: Integer;
begin
  if (LTuple2[0].ToString = '_*') and (Length(LTuple2) < Length(LTuple1^)) then
  begin
    LValue := LTuple2[Length(LTuple2) - 1];
    SetLength(LTuple2, Length(LTuple1^));
    for LFor := Low(LTuple2) to High(LTuple2) do
      LTuple2[LFor] := '_';
    LTuple2[Length(LTuple2) - 1] := LValue;
  end;
end;

procedure TMatch<T>._Dispose;
var
  LCaseType: TCaseType;
begin
  if Assigned(FCombines) then
  begin
    FCombines.Clear;
    FCombines.Free;
  end;
  for LCaseType := Low(TCaseType) to High(TCaseType) do
    if Assigned(FCases[LCaseType]) then
      FCases[LCaseType].Free;
  // Private method for resetting variables.
  _StartVariables;
  // Release the record of the TMatch class.
  TMatch.FMatch := nil;
end;

function TMatch<T>._IsArrayChar(const AValue: TValue): Boolean;
begin
  Result := LowerCase(String(AValue.TypeInfo.Name)) = LowerCase('TArray<System.Char>');
end;

function TMatch<T>._IsArrayInteger(const AValue: TValue): Boolean;
begin
  Result := LowerCase(String(AValue.TypeInfo.Name)) = LowerCase('TArray<System.Integer>');
end;

function TMatch<T>._IsArrayString(const AValue: TValue): Boolean;
begin
  Result := LowerCase(String(AValue.TypeInfo.Name)) = LowerCase('TArray<System.String>');
end;

function TMatch<T>._IsArrayTuplePair(const AValue: TValue): Boolean;
begin
  Result := AValue.IsType<Tuple>;
end;

function TMatch<T>._IsEquals<I>(const ALeft: I; ARight: I): Boolean;
begin
  Result := TEqualityComparer<I>.Default.Equals(ALeft, ARight);
end;

function TMatch<T>._MatchingProcCaseEq: Boolean;
var
  LProcPair: TPair<TValue, TValue>;
begin
  Result := False;
  for LProcPair in FCases[CASE_EQ_PROC] do
  begin
    if LProcPair.Key.IsArray then
    begin
      if not _ArraysAreEqual(FValue, LProcPair.Key) then
        Continue;
    end
    else
    begin
      if not _IsEquals<T>(FValue.AsType<T>, LProcPair.Key.AsType<T>) then
        Continue;
    end;
    _ExecuteProcMatchingEq(LProcPair);
    Result := True;
  end;
end;

procedure TMatch<T>._ExecuteProcMatchingEq(const ProcPair: TPair<TValue, TValue>);
begin
  if ProcPair.Value.IsType<TProc> then
    ProcPair.Value.AsType<TProc>()()
  else
  if ProcPair.Value.IsType<TProc<TValue>> then
    ProcPair.Value.AsType<TProc<TValue>>()(ProcPair.Key)
  else
  if ProcPair.Value.IsType<TProc<T>> then
    ProcPair.Value.AsType<TProc<T>>()(FValue.AsType<T>)
end;

function TMatch<T>._MatchingProcCaseGt: Boolean;
var
  LProcPair: TPair<TValue, TValue>;
begin
  Result := False;
  for LProcPair in FCases[CASE_GT_PROC] do
  begin
    if TComparer<T>.Default.Compare(FValue.AsType<T>, LProcPair.Key.AsType<T>) <= 0 then
      Continue;

    _ExecuteProcMatchingGt(LProcPair.Value);
    Result := True;
  end;
end;

procedure TMatch<T>._ExecuteProcMatchingGt(const ProcValue: TValue);
begin
  if ProcValue.IsType<TProc> then
    ProcValue.AsType<TProc>()()
  else
  if ProcValue.IsType<TProc<T>> then
    ProcValue.AsType<TProc<T>>()(FValue.AsType<T>);
end;

function TMatch<T>._MatchingProcDefault: Boolean;
var
  LProcPair: TPair<TValue, TValue>;
begin
  Result := False;
  for LProcPair in FCases[DEFAULT_PROC] do
  begin
    if LProcPair.Value.IsType<TProc> then
      LProcPair.Value.AsType<TProc>()()
    else
    if LProcPair.Value.IsType<TProc<T>> then
      LProcPair.Value.AsType<TProc<T>>()(LProcPair.Key.AsType<T>);
    Result := True;
  end;
end;

function TMatch<T>._MatchingTryExcept: Boolean;
var
  LProcPair: TPair<TValue, TValue>;
begin
  Result := False;
  for LProcPair in FCases[TRY_EXCEPT] do
  begin
    if LProcPair.Value.AsType<TProc> <> nil then
    begin
      LProcPair.Value.AsType<TProc>()();
      Result := True;
    end;
  end;
end;

function TMatch<T>._MatchingProcCaseRange: Boolean;
var
  LProcPair: TPair<TValue, TValue>;
  LComparer: IComparer<T>;
begin
  Result := False;
  LComparer := TComparer<T>.Default;
  for LProcPair in FCases[CASE_RANGE_PROC] do
  begin
    if (LComparer.Compare(FValue.AsType<T>, LProcPair.Key.AsType<TPair<T, T>>.Key) < 0) or
       (LComparer.Compare(FValue.AsType<T>, LProcPair.Key.AsType<TPair<T, T>>.Value) > 0) then
      Continue;
    _ExecuteProcMatchingRange(LProcPair);
    Result := True;
  end;
end;

procedure TMatch<T>._ExecuteProcMatchingRange(const ProcPair: TPair<TValue, TValue>);
begin
  if ProcPair.Value.IsType<TProc> then
    ProcPair.Value.AsType<TProc>()()
  else
  if ProcPair.Value.IsType<TProc<TValue>> then
    ProcPair.Value.AsType<TProc<TValue>>()(ProcPair.Key)
  else
  if ProcPair.Value.IsType<TProc<T>> then
    ProcPair.Value.AsType<TProc<T>>()(FValue.AsType<T>);
end;

function TMatch<T>._MatchingProcCaseIn: Boolean;
var
  LProcPair: TPair<TValue, TValue>;
  LValueType, LKeyType: PTypeInfo;
  LValueChar: AnsiChar;
  LCharSet: TSysCharSet;
begin
  Result := False;
  LValueType := FValue.TypeInfo;
  for LProcPair in FCases[CASE_IN_PROC] do
  begin
    if (LProcPair.Key.IsType<TArray>) and
       (FValue.Kind in [tkArray, tkDynArray]) then
    begin
      if not _ArraysAreEqual(FValue, LProcPair.Key) then
        Continue;
    end
    else
    if (LProcPair.Key.IsType<TSysCharSet>) and
       (FValue.Kind in [tkWChar, tkChar, tkSet]) and
       (Length(FValue.AsString) = 1) then
    begin
      if not LProcPair.Key.TryAsType<TSysCharSet>(LCharSet) then
        Continue;
      LValueChar := AnsiChar(FValue.AsType<Char>);
      if not (LValueChar in LCharSet) then
        Continue;
      _ExecuteProcMatchingIn(LProcPair);
      Result := True;
      Break;
    end;
    // Check types FValue and Key
    LKeyType := LProcPair.Key.TypeInfo;
    if LValueType <> LKeyType then
      Continue;
    if FValue.AsType<T> <> LProcPair.Key.AsType<T> then
      Continue;
    _ExecuteProcMatchingIn(LProcPair);
    Result := True;
  end;
end;

procedure TMatch<T>._ExecuteProcMatchingIn(const ProcPair: TPair<TValue, TValue>);
begin
  if ProcPair.Value.IsType<TProc> then
    ProcPair.Value.AsType<TProc>()()
  else
  if ProcPair.Value.IsType<TProc<TValue>> then
    ProcPair.Value.AsType<TProc<TValue>>()(ProcPair.Key)
  else
  if ProcPair.Value.IsType<TProc<T>> then
    ProcPair.Value.AsType<TProc<T>>()(FValue.AsType<T>);
end;

function TMatch<T>._MatchingProcCaseIs: Boolean;
var
  LKey: TTypeKind;
  LProc: TValue;
begin
  Result := False;
  LKey := FValue.Kind;
  // TDateTime Check
  if FValue.TypeInfo = TypeInfo(TDateTime) then
    LKey := tkFloat;
  if FCases[CASE_IS_PROC].TryGetValue(TValue.From<TTypeKind>(LKey), LProc) then
  begin
    _ExecuteProcMatchingIs(LProc);
    Result := True;
  end;
end;

procedure TMatch<T>._ExecuteProcMatchingIs(const ProcValue: TValue);
begin
  if ProcValue.IsType<TProc> then
    ProcValue.AsType<TProc>()()
  else
  if ProcValue.IsType<TProc<T>> then
    ProcValue.AsType<TProc<T>>()(FValue.AsType<T>);
end;

function TMatch<T>._MatchingProcCaseLt: Boolean;
var
  LProcPair: TPair<TValue, TValue>;
begin
  Result := False;
  for LProcPair in FCases[CASE_LT_PROC] do
  begin
    if TComparer<T>.Default.Compare(FValue.AsType<T>, LProcPair.Key.AsType<T>) >= 0 then
      Continue;
    _ExecuteProcMatchingLt(LProcPair.Value);
    Result := True;
  end;
end;

procedure TMatch<T>._ExecuteProcMatchingLt(const ProcValue: TValue);
begin
  if ProcValue.IsType<TProc> then
    ProcValue.AsType<TProc>()()
  else
  if ProcValue.IsType<TProc<T>> then
    ProcValue.AsType<TProc<T>>()(FValue.AsType<T>);
end;

function TMatch<T>._MatchingFuncCaseEq: Boolean;
var
  LFuncPair: TPair<TValue, TValue>;
begin
  Result := False;
  for LFuncPair in FCases[CASE_EQ_FUNC] do
  begin
    if LFuncPair.Key.IsArray then
    begin
      if not _ArraysAreEqual(FValue, LFuncPair.Key) then
        Continue;
    end
    else
    begin
      if not _IsEquals<T>(FValue.AsType<T>, LFuncPair.Key.AsType<T>) then
        Continue;
    end;
    _ExecuteFuncMatchingEq(LFuncPair.Value);
    Result := True;
  end;
end;

function TMatch<T>._MatchingFuncCaseGt: Boolean;
var
  LFuncPair: TPair<TValue, TValue>;
begin
  Result := False;
  for LFuncPair in FCases[CASE_GT_PROC] do
  begin
    if TComparer<T>.Default.Compare(FValue.AsType<T>, LFuncPair.Key.AsType<T>) <= 0 then
      Continue;
    _ExecuteFuncMatchingGt(LFuncPair.Value);
    Result := True;
  end;
end;

function TMatch<T>._MatchingFuncCaseIf: Boolean;
var
  LProcPair: TPair<TValue, TValue>;
begin
  Result := False;
  for LProcPair in FCases[CASE_IF_FUNC] do
  begin
    if _ArraysAreNotEqualCaseIf(LProcPair) then
      Continue;
    if FValue.AsType<T> <> LProcPair.Key.AsType<T> then
      Continue;
    Result := _ExecuteFuncMatchingCaseIf(LProcPair.Value);
  end;
end;

function TMatch<T>._MatchingFuncCaseIn: Boolean;
var
  LFuncPair: TPair<TValue, TValue>;
  LValueType, LKeyType: PTypeInfo;
  LValueChar: AnsiChar;
  LCharSet: TSysCharSet;
begin
  Result := False;
  LValueType := FValue.TypeInfo;
  for LFuncPair in FCases[CASE_IN_FUNC] do
  begin
    if LFuncPair.Key.IsArray then
    begin
      if not _ArraysAreEqual(FValue, LFuncPair.Key) then
        Continue;
    end
    else
    if LFuncPair.Key.IsType<TSysCharSet> and (FValue.Kind in [tkWChar, tkChar, tkSet]) then
    begin
      if Length(FValue.AsString) > 1 then
        Continue;
      if not LFuncPair.Key.TryAsType<TSysCharSet>(LCharSet) then
        Continue;
      LValueChar := AnsiChar(FValue.AsString[1]);
      if LValueChar in LCharSet then
      begin
        _ExecuteFuncMatchingIn(LFuncPair.Value);
        Result := True;
        Break;
      end;
    end;
    // Check types FValue and Key
    LKeyType := LFuncPair.Key.TypeInfo;
    if LValueType <> LKeyType then
      Continue;
    if FValue.AsType<T> <> LFuncPair.Key.AsType<T> then
      Continue;
    _ExecuteFuncMatchingIn(LFuncPair.Value);
    Result := True;
  end;
end;

function TMatch<T>._MatchingFuncCaseIs: Boolean;
var
  LKey: TTypeKind;
  LProc: TValue;
begin
  Result := False;
  LKey := FValue.Kind;
  // TDateTime Check
  if FValue.TypeInfo = TypeInfo(TDateTime) then
    LKey := tkFloat;
  if FCases[CASE_IS_FUNC].TryGetValue(TValue.From<TTypeKind>(LKey), LProc) then
  begin
    _ExecuteFuncMatchingIs(LProc);
    Result := True;
  end;
end;

function TMatch<T>._MatchingFuncCaseLt: Boolean;
var
  LFuncPair: TPair<TValue, TValue>;
begin
  Result := False;
  for LFuncPair in FCases[CASE_LT_FUNC] do
  begin
    if TComparer<T>.Default.Compare(FValue.AsType<T>, LFuncPair.Key.AsType<T>) >= 0 then
      Continue;
    _ExecuteFuncMatchingLt(LFuncPair.Value);
    Result := True;
  end;
end;

function TMatch<T>._MatchingFuncCaseRange: Boolean;
var
  LFuncPair: TPair<TValue, TValue>;
  LComparer: IComparer<T>;
begin
  Result := False;
  LComparer := TComparer<T>.Default;
  for LFuncPair in FCases[CASE_RANGE_FUNC] do
  begin
    if (LComparer.Compare(FValue.AsType<T>, LFuncPair.Key.AsType<TPair<T, T>>.Key) < 0) or
       (LComparer.Compare(FValue.AsType<T>, LFuncPair.Key.AsType<TPair<T, T>>.Value) > 0) then
      Continue;
    _ExecuteFuncMatchingRange(LFuncPair.Value);
    Result := True;
  end;
end;

function TMatch<T>._MatchingFuncDefault: Boolean;
var
  LFuncPair: TPair<TValue, TValue>;
begin
  Result := False;
  for LFuncPair in FCases[DEFAULT_FUNC] do
  begin
    if LFuncPair.Value.IsType<TFunc<TValue>> then
      FResult := LFuncPair.Value.AsType<TFunc<TValue>>()()
    else
    if LFuncPair.Value.IsType<TFunc<T, TValue>> then
      FResult := LFuncPair.Value.AsType<TFunc<T, TValue>>()(LFuncPair.Key.AsType<T>);
    Result := True;
  end;
end;

function TMatch<T>._ExecuteFuncMatchingCaseIf(const ProcValue: TValue): Boolean;
begin
  Result := False;
  if ProcValue.IsType<TFunc<Boolean>> then
    Result := ProcValue.AsType<TFunc<Boolean>>()()
  else
  if ProcValue.IsType<TFunc<T, Boolean>> then
    Result := ProcValue.AsType<TFunc<T, Boolean>>()(FValue.AsType<T>);
end;

procedure TMatch<T>._ExecuteFuncMatchingEq(const FuncValue: TValue);
begin
  if FuncValue.IsType<TFunc<TValue>> then
    FResult := FuncValue.AsType<TFunc<TValue>>()()
  else
  if FuncValue.IsType<TFunc<T, TValue>> then
    FResult := FuncValue.AsType<TFunc<T, TValue>>()(FValue.AsType<T>);
end;

procedure TMatch<T>._ExecuteFuncMatchingGt(const FuncValue: TValue);
begin
  if FuncValue.IsType<TFunc<TValue>> then
    FResult := FuncValue.AsType<TFunc<TValue>>()()
  else
  if FuncValue.IsType<TFunc<T, TValue>> then
    FResult := FuncValue.AsType<TFunc<T, TValue>>()(FValue.AsType<T>);
end;

procedure TMatch<T>._ExecuteFuncMatchingIn(const FuncValue: TValue);
begin
  if FuncValue.IsType<TFunc<TValue>> then
    FResult := FuncValue.AsType<TFunc<TValue>>()()
  else
  if FuncValue.IsType<TFunc<T, TValue>> then
    FResult := FuncValue.AsType<TFunc<T, TValue>>()(FValue.AsType<T>);
end;

procedure TMatch<T>._ExecuteFuncMatchingIs(const FuncValue: TValue);
begin
  if FuncValue.IsType<TFunc<TValue>> then
    FResult := FuncValue.AsType<Tfunc<TValue>>()()
  else
  if FuncValue.IsType<TFunc<T, TValue>> then
    FResult := FuncValue.AsType<Tfunc<T, TValue>>()(FValue.AsType<T>);
end;

procedure TMatch<T>._ExecuteFuncMatchingLt(const FuncValue: TValue);
begin
  if FuncValue.IsType<TFunc<TValue>> then
    FResult := FuncValue.AsType<TFunc<TValue>>()()
  else
  if FuncValue.IsType<TFunc<T, TValue>> then
    FResult := FuncValue.AsType<TFunc<T, TValue>>()(FValue.AsType<T>);
end;

procedure TMatch<T>._ExecuteFuncMatchingRange(const FuncValue: TValue);
begin
  if FuncValue.IsType<TFunc<TValue>> then
    FResult := FuncValue.AsType<TFunc<TValue>>()()
  else
  if FuncValue.IsType<TFunc<T, TValue>> then
    FResult := FuncValue.AsType<TFunc<T, TValue>>()(FValue.AsType<T>);
end;

function TMatch<T>._MatchingProcCaseIf: Boolean;
var
  LProcPair: TPair<TValue, TValue>;
begin
  Result := False;
  for LProcPair in FCases[CASE_IF_PROC] do
  begin
    if _ArraysAreNotEqualCaseIf(LProcPair) then
      Continue;
    if FValue.AsType<T> <> LProcPair.Key.AsType<T> then
      Continue;
    _ExecuteProcMatchingCaseIf(LProcPair.Value);
    Result := True;
  end;
end;

procedure TMatch<T>._ExecuteProcMatchingCaseIf(const ProcValue: TValue);
begin
  if ProcValue.IsType<TProc> then
    ProcValue.AsType<TProc>()()
  else
  if ProcValue.IsType<TProc<T>> then
    ProcValue.AsType<TProc<T>>()(FValue.AsType<T>);
end;

procedure TMatch<T>._StartVariables;
begin
  FGuardCount := 0;
  FRegexCount := 0;
  FUseGuard := False;
  FUseRegex := False;
  FSession := TMatchSession.sMatch;
  FResult := TValue.Empty;
end;

function TMatch<T>.CaseIf(const ACondition: Boolean): TMatch<T>;
begin
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard]) then
    raise Exception.Create('Use Guard after session [sMatch, sGuard]');
  Result := TMatch<T>(Self);
  if ACondition then
    Result.FGuardCount := Result.FGuardCount + 1
  else
    Result.FGuardCount := Result.FGuardCount - 1;
  Result.FSession := TMatchSession.sGuard;
  Result.FUseGuard := True;
end;

function TMatch<T>.Combine(const AMatch: TMatch<T>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  Result.FCombines.Add(TValue.From<TMatch<T>>(AMatch));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseEq(const AValue: Tuple;
  const AFunc: TFunc<Tuple, TValue>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  FCases[CASE_EQ_FUNC].AddOrSetValue(TValue.From<Tuple>(AValue),
                                     TValue.From<TFunc<Tuple, TValue>>(AFunc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseEq(const AValue: T; const AProc: TProc<TValue>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  FCases[CASE_EQ_PROC].AddOrSetValue(TValue.From<T>(AValue),
                                     TValue.From<TProc<TValue>>(AProc));
  Result.FSession := TMatchSession.sCase;
end;

{ TMatch }

class function TMatch.Value<T>: T;
begin
  Result := FMatch.AsType<TMatch<T>>.FValue.AsType<T>;
end;

function TMatch<T>.CaseIn(const ASet: TSysCharSet;
  const AProc: TProc): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  FCases[CASE_IN_PROC].AddOrSetValue(TValue.From<TSysCharSet>(ASet),
                                     TValue.From<TProc>(AProc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseIn(const ASet: TIntegerSet;
  const AProc: TProc): TMatch<T>;
var
  LItem: Integer;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;

  for LItem in ASet do
    FCases[CASE_IN_PROC].AddOrSetValue(TValue.From<Integer>(LItem),
                                       TValue.From<TProc>(AProc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseIn(const ASet: TSysCharSet;
  const AProc: TProc<TValue>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  FCases[CASE_IN_PROC].AddOrSetValue(TValue.From<TSysCharSet>(ASet),
                                     TValue.From<TProc<TValue>>(AProc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseIn(const ASet: TSysCharSet;
  const AFunc: TFunc<TValue>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  FCases[CASE_IN_PROC].AddOrSetValue(TValue.From<TSysCharSet>(ASet),
                                     TValue.From<TFunc<TValue>>(AFunc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseIn(const ASet: TSysCharSet;
  const AProc: TProc<T>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  FCases[CASE_IN_PROC].AddOrSetValue(TValue.From<TSysCharSet>(ASet),
                                     TValue.From<TProc<T>>(AProc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseIn(const ASet: TSysCharSet;
  const AFunc: TFunc<T, TValue>): TMatch<T>;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  FCases[CASE_IN_PROC].AddOrSetValue(TValue.From<TSysCharSet>(ASet),
                                     TValue.From<TFunc<T, TValue>>(AFunc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseIn(const ASet: TIntegerSet;
  const AProc: TProc<TValue>): TMatch<T>;
var
  LItem: Integer;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  for LItem in ASet do
    FCases[CASE_IN_PROC].AddOrSetValue(TValue.From<Integer>(LItem),
                                       TValue.From<TProc<TValue>>(AProc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseIn(const ASet: TIntegerSet;
  const AFunc: TFunc<TValue>): TMatch<T>;
var
  LItem: Integer;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  for LItem in ASet do
    FCases[CASE_IN_PROC].AddOrSetValue(TValue.From<Integer>(LItem),
                                       TValue.From<TFunc<TValue>>(AFunc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseIn(const ASet: TIntegerSet;
  const AProc: TProc<T>): TMatch<T>;
var
  LItem: Integer;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  for LItem in ASet do
    FCases[CASE_IN_PROC].AddOrSetValue(TValue.From<Integer>(LItem),
                                       TValue.From<TProc<T>>(AProc));
  Result.FSession := TMatchSession.sCase;
end;

function TMatch<T>.CaseIn(const ASet: TIntegerSet;
  const AFunc: TFunc<T, TValue>): TMatch<T>;
var
  LItem: Integer;
begin
  Result := TMatch<T>(Self);
  if not (FSession in [TMatchSession.sMatch, TMatchSession.sGuard, TMatchSession.sCase]) then
    Exit;
  for LItem in ASet do
    FCases[CASE_IN_PROC].AddOrSetValue(TValue.From<Integer>(LItem),
                                       TValue.From<TFunc<T, TValue>>(AFunc));
  Result.FSession := TMatchSession.sCase;
end;

end.


