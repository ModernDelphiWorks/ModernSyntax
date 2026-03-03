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

unit ModernSyntax.DotEnv;

interface

uses
  Rtti,
  SysUtils,
  Classes,
  Windows,
  Generics.Collections;

type
  TDotEnv = class
  private
    FFileName: String;
    FVariables: TDictionary<String, TValue>;
    FUseSystemFallback: Boolean;
    function _GetValue(const AName: String): TValue;
    function _ReplaceVars(const AValue: String): String;
    procedure _LoadFromFile(const AFileName: String);
  public
    /// <summary>
    /// Creates a TDotEnv instance and optionally loads a .env file.
    /// </summary>
    /// <param name="AFileName">The .env file path (default: '.env').</param>
    /// <param name="AUseSystemFallback">If true, falls back to system env vars (default: true).</param>
    constructor Create(const AFileName: String = '.env'; AUseSystemFallback: Boolean = True);
    destructor Destroy; override;

    // File .ENV Operations
    /// <summary>
    /// Reloads variables from the specified .env file.
    /// </summary>
    procedure Open;
    /// <summary>
    /// Loads variables from multiple .env files, later files override earlier ones.
    /// </summary>
    /// <param name="AFileNames">Array of .env file paths to load.</param>
    procedure LoadFiles(const AFileNames: array of String);
    /// <summary>
    /// Saves variables to the .env file.
    /// </summary>
    procedure Save;
    /// <summary>
    /// Adds or updates a variable.
    /// </summary>
    /// <param name="AName">The variable name.</param>
    /// <param name="AValue">The variable value.</param>
    procedure Add(const AName: String; const AValue: TValue);
    /// <summary>
    /// Adds a variable and returns self for chaining.
    /// </summary>
    /// <param name="AName">The variable name.</param>
    /// <param name="AValue">The variable value.</param>
    /// <returns>The TDotEnv instance.</returns>
    function Push(const AName: String; const AValue: TValue): TDotEnv;
    /// <summary>
    /// Deletes a variable.
    /// </summary>
    /// <param name="AName">The variable name.</param>
    procedure Delete(const AName: String);
    /// <summary>
    /// Gets a variable's value with type conversion; raises exception if not found.
    /// </summary>
    /// <param name="AName">The variable name.</param>
    /// <returns>The value as type T.</returns>
    function Value<T>(const AName: String): T;
    /// <summary>
    /// Tries to get a variable's value with type conversion.
    /// </summary>
    /// <param name="AName">The variable name.</param>
    /// <param name="AValue">The output value if found.</param>
    /// <returns>True if found and converted, False otherwise.</returns>
    function TryGet<T>(const AName: String; out AValue: T): Boolean;
    /// <summary>
    /// Gets a variable's value or a default if not found.
    /// </summary>
    /// <param name="AName">The variable name.</param>
    /// <param name="ADefault">The default value.</param>
    /// <returns>The value or default as type T.</returns>
    function GetOr<T>(const AName: String; const ADefault: T): T;
    /// <summary>
    /// Gets a variable's value with type conversion.
    /// </summary>
    /// <param name="AName">The variable name.</param>
    /// <returns>The value as type T.</returns>
    function Get<T>(const AName: String): T;
    /// <summary>
    /// Returns the number of variables stored.
    /// </summary>
    /// <returns>The count of variables.</returns>
    function Count: Integer;

    // Environment Variable Operations
    /// <summary>
    /// Creates a system environment variable.
    /// </summary>
    /// <param name="AName">The variable name.</param>
    /// <param name="AValue">The variable value.</param>
    /// <returns>The value set.</returns>
    function EnvCreate(const AName: String; const AValue: String): String;
    /// <summary>
    /// Loads a system environment variable.
    /// </summary>
    /// <param name="AName">The variable name.</param>
    /// <returns>The variable value.</returns>
    function EnvLoad(const AName: String): String;
    /// <summary>
    /// Updates a system environment variable.
    /// </summary>
    /// <param name="AName">The variable name.</param>
    /// <param name="AValue">The new value.</param>
    /// <returns>The updated value.</returns>
    function EnvUpdate(const AName: String; const AValue: String): String;
    /// <summary>
    /// Deletes a system environment variable.
    /// </summary>
    /// <param name="AName">The variable name.</param>
    /// <returns>Empty string on success.</returns>
    function EnvDelete(const AName: String): String;

    /// <summary>
    /// Provides direct access to variables by name.
    /// </summary>
    /// <param name="AName">The variable name.</param>
    /// <returns>The variable value as TValue.</returns>
    property Items[const AName: String]: TValue read _GetValue write Add; default;
    /// <summary>
    /// Controls whether to fallback to system environment variables.
    /// </summary>
    property UseSystemFallback: Boolean read FUseSystemFallback write FUseSystemFallback;
  end;

implementation

constructor TDotEnv.Create(const AFileName: String = '.env'; AUseSystemFallback: Boolean = True);
begin
  FFileName := AFileName;
  FVariables := TDictionary<String, TValue>.Create;
  FUseSystemFallback := AUseSystemFallback;
  _LoadFromFile(FFileName);
end;

destructor TDotEnv.Destroy;
begin
  FVariables.Free;
  inherited;
end;

function TDotEnv.Count: Integer;
begin
  Result := FVariables.Count;
end;

procedure TDotEnv._LoadFromFile(const AFileName: String);
var
  LLines: TStringList;
  LLine, LTrimmedLine, LValue: String;
  LPosSeparator, LPosComment: Integer;
begin
  if FileExists(AFileName) then
  begin
    LLines := TStringList.Create;
    try
      LLines.LoadFromFile(AFileName);
      for LLine in LLines do
      begin
        LTrimmedLine := Trim(LLine);
        if (LTrimmedLine = '') or LTrimmedLine.StartsWith('#') then
          Continue;
        LPosComment := Pos('#', LTrimmedLine);
        if LPosComment > 0 then
          LTrimmedLine := Trim(Copy(LTrimmedLine, 1, LPosComment - 1));
        LPosSeparator := Pos('=', LTrimmedLine);
        if LPosSeparator > 0 then
        begin
          LValue := Trim(Copy(LTrimmedLine, LPosSeparator + 1, Length(LTrimmedLine)));
          LValue := _ReplaceVars(LValue);
          FVariables.AddOrSetValue(
            Trim(Copy(LTrimmedLine, 1, LPosSeparator - 1)),
            TValue.From<String>(LValue)
          );
        end;
      end;
    finally
      LLines.Free;
    end;
  end;
end;

function TDotEnv._ReplaceVars(const AValue: String): String;
var
  LResult: String;
  LStart, LEnd: Integer;
  LVarName: String;
  LVarValue: TValue;
begin
  LResult := AValue;
  LStart := Pos('${', LResult);
  while LStart > 0 do
  begin
    LEnd := Pos('}', LResult, LStart);
    if LEnd = 0 then Break;
    LVarName := Copy(LResult, LStart + 2, LEnd - LStart - 2);
    if FVariables.TryGetValue(LVarName, LVarValue) then
      LResult := StringReplace(LResult, '${' + LVarName + '}', LVarValue.AsType<String>, [rfReplaceAll]);
    LStart := Pos('${', LResult, LEnd);
  end;
  Result := LResult;
end;

procedure TDotEnv.Open;
begin
  _LoadFromFile(FFileName);
end;

procedure TDotEnv.LoadFiles(const AFileNames: array of String);
var
  LFile: String;
begin
  FVariables.Clear;
  for LFile in AFileNames do
    if FileExists(LFile) then
      _LoadFromFile(LFile);
end;

procedure TDotEnv.Save;
var
  LLines: TStringList;
  LPair: TPair<String, TValue>;
begin
  LLines := TStringList.Create;
  try
    for LPair in FVariables do
      LLines.Add(LPair.Key + '=' + LPair.Value.ToString);
    LLines.SaveToFile(FFileName);
  finally
    LLines.Free;
  end;
end;

procedure TDotEnv.Add(const AName: String; const AValue: TValue);
var
  LStringValue: String;
begin
  if AValue.IsType<String> then
  begin
    LStringValue := AValue.AsString;
    LStringValue := _ReplaceVars(LStringValue);
    FVariables.AddOrSetValue(AName, TValue.From<String>(LStringValue));
  end
  else
    FVariables.AddOrSetValue(AName, AValue);
end;

function TDotEnv.Push(const AName: String; const AValue: TValue): TDotEnv;
begin
  Add(AName, AValue);
  Result := Self;
end;

procedure TDotEnv.Delete(const AName: String);
begin
  FVariables.Remove(AName);
end;

function TDotEnv.Value<T>(const AName: String): T;
begin
  Result := Get<T>(AName);
end;

function TDotEnv.TryGet<T>(const AName: String; out AValue: T): Boolean;
begin
  try
    AValue := Get<T>(AName);
    Result := True;
  except
    AValue := Default(T);
    Result := False;
  end;
end;

function TDotEnv.Get<T>(const AName: String): T;
var
  LResult: TValue;
  LStringValue: String;
begin
  if FVariables.TryGetValue(AName, LResult) then
  begin
    if LResult.IsType<T> then
      Result := LResult.AsType<T>
    else if LResult.IsType<String> then
    begin
      LStringValue := LResult.AsString;
      try
        if TypeInfo(T) = TypeInfo(Integer) then
          Result := TValue.From<Integer>(StrToInt(LStringValue)).AsType<T>
        else if TypeInfo(T) = TypeInfo(String) then
          Result := TValue.From<String>(LStringValue).AsType<T>
        else
          raise Exception.CreateFmt('Cannot convert %s to requested type', [AName]);
      except
        on E: EConvertError do
          raise Exception.CreateFmt('Invalid value for %s: %s', [AName, E.Message]);
      end;
    end
    else
      raise Exception.CreateFmt('Type mismatch for %s', [AName]);
  end
  else if FUseSystemFallback then
  begin
    LStringValue := EnvLoad(AName);
    if LStringValue <> '' then
    begin
      try
        if TypeInfo(T) = TypeInfo(Integer) then
          Result := TValue.From<Integer>(StrToInt(LStringValue)).AsType<T>
        else if TypeInfo(T) = TypeInfo(String) then
          Result := TValue.From<String>(LStringValue).AsType<T>
        else
          Result := TValue.From<String>(LStringValue).AsType<T>;
      except
        on E: EConvertError do
          raise Exception.CreateFmt('Invalid system env value for %s: %s', [AName, E.Message]);
      end;
    end
    else
      raise Exception.CreateFmt('Variable %s not found', [AName]);
  end
  else
    raise Exception.CreateFmt('Variable %s not found', [AName]);
end;

function TDotEnv.GetOr<T>(const AName: String; const ADefault: T): T;
var
  LResult: TValue;
  LStringValue: String;
begin
  if FVariables.TryGetValue(AName, LResult) then
  begin
    if LResult.IsType<T> then
      Result := LResult.AsType<T>
    else if LResult.IsType<String> then
    begin
      LStringValue := LResult.AsString;
      try
        if TypeInfo(T) = TypeInfo(Integer) then
          Result := TValue.From<Integer>(StrToInt(LStringValue)).AsType<T>
        else if TypeInfo(T) = TypeInfo(String) then
          Result := TValue.From<String>(LStringValue).AsType<T>
        else
          Result := ADefault;
      except
        Result := ADefault;
      end;
    end
    else
      Result := ADefault;
  end
  else if FUseSystemFallback then
  begin
    LStringValue := EnvLoad(AName);
    if LStringValue <> '' then
    begin
      try
        if TypeInfo(T) = TypeInfo(Integer) then
          Result := TValue.From<Integer>(StrToInt(LStringValue)).AsType<T>
        else if TypeInfo(T) = TypeInfo(String) then
          Result := TValue.From<String>(LStringValue).AsType<T>
        else
          Result := ADefault;
      except
        Result := ADefault;
      end;
    end
    else
      Result := ADefault;
  end
  else
    Result := ADefault;
end;

function TDotEnv._GetValue(const AName: String): TValue;
begin
  if FVariables.TryGetValue(AName, Result) then
    Exit;
  if FUseSystemFallback then
    Result := TValue.From<String>(EnvLoad(AName))
  else
    Result := TValue.Empty;
end;

function TDotEnv.EnvCreate(const AName: String; const AValue: String): String;
begin
  if not SetEnvironmentVariable(PChar(AName), PChar(AValue)) then
    RaiseLastOSError;
  Result := AValue;
end;

function TDotEnv.EnvLoad(const AName: String): String;
begin
  Result := GetEnvironmentVariable(AName);
end;

function TDotEnv.EnvUpdate(const AName: String; const AValue: String): String;
begin
  if not SetEnvironmentVariable(PChar(AName), PChar(AValue)) then
    RaiseLastOSError;
  Result := AValue;
end;

function TDotEnv.EnvDelete(const AName: String): String;
begin
  if not SetEnvironmentVariable(PChar(AName), nil) then
    RaiseLastOSError;
  Result := '';
end;

end.
