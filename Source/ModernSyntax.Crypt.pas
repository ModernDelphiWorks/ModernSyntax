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

unit ModernSyntax.Crypt;

interface

uses
  Classes,
  SysUtils,
  ModernSyntax.Std;

type
  PPacket = ^TPacket;
  TPacket = packed record
    case Integer of
      0: (b0, b1, b2, b3: Byte);  // As individual bytes
      1: (i: Integer);             // As a single integer
      2: (a: array[0..3] of Byte); // As an array of bytes
      3: (c: array[0..3] of AnsiChar); // As an array of AnsiChar
  end;

  TCrypt = record
  strict private
    class function _DecodePacket(AInBuf: PAnsiChar; var nChars: Integer): TPacket; static;
    class procedure _EncodePacket(const APacket: TPacket; NumChars: Integer; AOutBuf: PAnsiChar); static;
  public
    class function DecodeBase64(const AInput: String): TBytes; static; inline;
    class function EncodeBase64(const AInput: Pointer; const ASize: Integer): String; static; inline;
    class function EncodeString(const AInput: String): String; static; inline;
    class function DecodeString(const AInput: String): String; static; inline;
    class procedure EncodeStream(const AInput, AOutput: TStream); static;
    class procedure DecodeStream(const AInput, AOutput: TStream); static;
    class function Hash(const AValue: MarshaledAString): Cardinal; static; inline;
    class function MD5Simple(const AData: TDate; const ANr1, ANr2: Integer; const Akey: String): String; static; inline;
  end;

implementation

const
  C_BUFFERSIZE = 510;
  C_LINEBREAKINTERVAL = 75;

  C_ENCODETABLE: array[0..63] of AnsiChar =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

  C_DECODETABLE: array[#0..#127] of Integer = (
    Byte('='), 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 62, 64, 64, 64, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 64, 64, 64, 64, 64, 64,
    64,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 64, 64, 64, 64, 64,
    64, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 64, 64, 64, 64, 64);

{ TCrypt }

class procedure TCrypt._EncodePacket(const APacket: TPacket; NumChars: Integer; AOutBuf: PAnsiChar);
begin
  AOutBuf[0] := C_ENCODETABLE[APacket.a[0] shr 2];
  AOutBuf[1] := C_ENCODETABLE[((APacket.a[0] shl 4) or (APacket.a[1] shr 4)) and $0000003f];
  if NumChars < 2 then
    AOutBuf[2] := '='
  else
    AOutBuf[2] := C_ENCODETABLE[((APacket.a[1] shl 2) or (APacket.a[2] shr 6)) and $0000003f];
  if NumChars < 3 then
    AOutBuf[3] := '='
  else
    AOutBuf[3] := C_ENCODETABLE[APacket.a[2] and $0000003f];
end;

class function TCrypt._DecodePacket(AInBuf: PAnsiChar; var nChars: Integer): TPacket;
begin
  Result.a[0] := (C_DECODETABLE[AInBuf[0]] shl 2) or (C_DECODETABLE[AInBuf[1]] shr 4);
  nChars := 1;
  if AInBuf[2] <> '=' then
  begin
    Inc(nChars);
    Result.a[1] := Byte((C_DECODETABLE[AInBuf[1]] shl 4) or (C_DECODETABLE[AInBuf[2]] shr 2));
  end;
  if AInBuf[3] <> '=' then
  begin
    Inc(nChars);
    Result.a[2] := Byte((C_DECODETABLE[AInBuf[2]] shl 6) or C_DECODETABLE[AInBuf[3]]);
  end;
end;

class function TCrypt.DecodeBase64(const AInput: String): TBytes;
var
  LInStr: TMemoryStream;
  LOutStr: TBytesStream;
  LStream: TStringStream;
  LSize: Integer;
begin
  LInStr := TMemoryStream.Create;
  LStream := TStringStream.Create(AInput, TEncoding.ASCII);
  try
    LInStr.LoadFromStream(LStream);
    LOutStr := TBytesStream.Create;
    try
      DecodeStream(LInStr, LOutStr);
      LSize := LOutStr.Size;
      SetLength(Result, LSize);
      LOutStr.Position := 0;
      LOutStr.Read(Result[0], LSize);
    finally
      LOutStr.Free;
    end;
  finally
    LStream.Free;
    LInStr.Free;
  end;
end;

class function TCrypt.EncodeBase64(const AInput: Pointer; const ASize: Integer): String;
var
  LInStream: TMemoryStream;
  LOutStream: TMemoryStream;
begin
  LInStream := TMemoryStream.Create;
  try
    LInStream.WriteBuffer(AInput^, ASize);
    LInStream.Position := 0;
    LOutStream := TMemoryStream.Create;
    try
      EncodeStream(LInStream, LOutStream);
      SetString(Result, PAnsiChar(LOutStream.Memory), LOutStream.Size);
    finally
      LOutStream.Free;
    end;
  finally
    LInStream.Free;
  end;
end;

class function TCrypt.EncodeString(const AInput: String): String;
var
  LInStr: TStringStream;
  LOutStr: TStringStream;
begin
  LInStr := TStringStream.Create(AInput);
  try
    LOutStr := TStringStream.Create('');
    try
      EncodeStream(LInStr, LOutStr);
      Result := LOutStr.DataString;
    finally
      LOutStr.Free;
    end;
  finally
    LInStr.Free;
  end;
end;

class function TCrypt.DecodeString(const AInput: String): String;
var
  LInStr: TStringStream;
  LOutStr: TStringStream;
begin
  LInStr := TStringStream.Create(AInput);
  try
    LOutStr := TStringStream.Create('');
    try
      DecodeStream(LInStr, LOutStr);
      Result := LOutStr.DataString;
    finally
      LOutStr.Free;
    end;
  finally
    LInStr.Free;
  end;
end;

class procedure TCrypt.EncodeStream(const AInput, AOutput: TStream);
var
  LInBuffer: array[0..C_BUFFERSIZE] of Byte;
  LOutBuffer: array[0..1023] of AnsiChar;
  LBufferPtr: PAnsiChar;
  LI: Integer;
  LJ: Integer;
  LBytesRead: Integer;
  LPacket: TPacket;

  procedure L_WriteLineBreak;
  begin
    LOutBuffer[0] := #$0D;
    LOutBuffer[1] := #$0A;
    LBufferPtr := @LOutBuffer[2];
  end;

begin
  LBufferPtr := @LOutBuffer[0];
  repeat
    LBytesRead := AInput.Read(LInBuffer, SizeOf(LInBuffer));
    LI := 0;
    while LI < LBytesRead do
    begin
      LJ := TStd.Min(3, LBytesRead - LI);
      FillChar(LPacket, SizeOf(LPacket), 0);
      Move(LInBuffer[LI], LPacket, LJ);
      _EncodePacket(LPacket, LJ, LBufferPtr);
      Inc(LI, 3);
      Inc(LBufferPtr, 4);
      if LBufferPtr - @LOutBuffer[0] > SizeOf(LOutBuffer) - C_LINEBREAKINTERVAL then
      begin
        L_WriteLineBreak;
        AOutput.Write(LOutBuffer, LBufferPtr - @LOutBuffer[0]);
        LBufferPtr := @LOutBuffer[0];
      end;
    end;
  until LBytesRead = 0;
  if LBufferPtr <> @LOutBuffer[0] then
    AOutput.Write(LOutBuffer, LBufferPtr - @LOutBuffer[0]);
end;

class procedure TCrypt.DecodeStream(const AInput, AOutput: TStream);
var
  LInBuf: array[0..75] of AnsiChar;
  LOutBuf: array[0..60] of Byte;
  LInBufPtr, LOutBufPtr: PAnsiChar;
  LI: Integer;
  LJ: Integer;
  LK: Integer;
  LBytesRead: Integer;
  LPacket: TPacket;

  procedure L_SkipWhite;
  var
    LC: AnsiChar;
    LNumRead: Integer;
  begin
    while True do
    begin
      LNumRead := AInput.Read(LC, 1);
      if LNumRead = 1 then
      begin
        if LC in ['0'..'9','A'..'Z','a'..'z','+','/','='] then
        begin
          AInput.Position := AInput.Position - 1;
          Break;
        end;
      end
      else
        Break;
    end;
  end;

  function L_ReadInput: Integer;
  var
    LWhiteFound: Boolean;
    LEndReached: Boolean;
    LCntRead: Integer;
    LIdx: Integer;
    LIdxEnd: Integer;
  begin
    LIdxEnd := 0;
    repeat
      LWhiteFound := False;
      LCntRead := AInput.Read(LInBuf[LIdxEnd], (SizeOf(LInBuf)-LIdxEnd));
      LEndReached := LCntRead < (SizeOf(LInBuf)-LIdxEnd);
      LIdx := LIdxEnd;
      LIdxEnd := LCntRead + LIdxEnd;
      while (LIdx < LIdxEnd) do
      begin
        if not (LInBuf[LIdx] in ['0'..'9','A'..'Z','a'..'z','+','/','=']) then
        begin
          Dec(LIdxEnd);
          if LIdx < LIdxEnd then
            Move(LInBuf[LIdx+1], LInBuf[LIdx], LIdxEnd-LIdx);
          LWhiteFound := True;
        end
        else
          Inc(LIdx);
      end;
    until (not LWhiteFound) or (LEndReached);
    Result := LIdxEnd;
  end;

begin
  repeat
    L_SkipWhite;
    LBytesRead := L_ReadInput;
    LInBufPtr := LInBuf;
    LOutBufPtr := @LOutBuf;
    LI := 0;
    while LI < LBytesRead do
    begin
      LPacket := _DecodePacket(LInBufPtr, LJ);
      LK := 0;
      while LJ > 0 do
      begin
        LOutBufPtr^ := AnsiChar(LPacket.a[LK]);
        Inc(LOutBufPtr);
        Dec(LJ);
        Inc(LK);
      end;
      Inc(LInBufPtr, 4);
      Inc(LI, 4);
    end;
    AOutput.Write(LOutBuf, LOutBufPtr - PAnsiChar(@LOutBuf));
  until LBytesRead = 0;
end;

class function TCrypt.Hash(const AValue: MarshaledAString): Cardinal;
begin
  Result := SysUtils.HashName(AValue);
end;

class function TCrypt.MD5Simple(const AData: TDate; const ANr1, ANr2: Integer; const Akey: String): String;
var
  LData: String;
  LCode: String;
  LHash: String;
  LFor: Integer;
begin
  LData := FormatDateTime('YYYYMMDD', AData);
  LCode := LData + IntToStr(ANr1) + IntToStr(ANr2) + Akey;
  LHash := '';
  for LFor := 1 to Length(LCode) do
    LHash := LHash + IntToHex(Ord(LCode[LFor]), 2);
  Result := LHash;
end;

end.
