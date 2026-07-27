{
  ------------------------------------------------------------------------------
  ModernSyntax
  Functional programming toolkit and modern syntax extension for Delphi.

  SPDX-License-Identifier: MIT
  Copyright (c) 2025-2026 Isaque Pinheiro

  Licensed under the MIT License.
  See the LICENSE file in the project root for full license information.
  ------------------------------------------------------------------------------
}

{
  @abstract(ModernSyntax Library)
  @created(23 Abr 2023)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
}

{
  Compiler			CompilerVersion			Defined Symbol	Used BPL
  Delphi 12   ??         	36 				VER360			29
  Delphi 11.1 Alexandria 	35 				VER350			28
  Delphi 10.4 Sidney     	34 				VER340			27
  Delphi 10.3 Rio			33 				VER330			26
  Delphi 10.2 Tokyo			32 				VER320			25
  Delphi 10.1 Berlin	 	31				VER310			24
  Delphi 10 Seattle			30				VER300          23
  Delphi XE8				29 				VER290          22
  Delphi XE7				28 				VER280          21
  Delphi XE6				27 				VER270          20
  Delphi XE5				26 				VER260          19
  Delphi XE4				25 				VER250          18
  Delphi XE3				24 				VER240          17
  Delphi XE2				23 				VER230          16
  Delphi XE	        		22 				VER220          15
  Delphi 2010 	         	21 				VER210          14
}

{.$DEFINE FMX}
{.$DEFINE LOAD_DYNAMICALLY}

{$IFDEF FMX}
  {$DEFINE HAS_FMX}
{$ELSE}
  {$DEFINE HAS_VCL}
{$ENDIF}

// Delphi ???
{$IFDEF VER360}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
  {$DEFINE DELPHI19_UP}
  {$DEFINE DELPHI20_UP}
  {$DEFINE DELPHI21_UP}
  {$DEFINE DELPHI22_UP}
  {$DEFINE DELPHI23_UP}
  {$DEFINE DELPHI24_UP}
  {$DEFINE DELPHI25_UP}
  {$DEFINE DELPHI26_UP}
  {$DEFINE DELPHI27_UP}
  {$DEFINE DELPHI28_UP}
  {$DEFINE DELPHI29_UP}
{$ENDIF}

// Delphi Alexandria
{$IFDEF VER350}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
  {$DEFINE DELPHI19_UP}
  {$DEFINE DELPHI20_UP}
  {$DEFINE DELPHI21_UP}
  {$DEFINE DELPHI22_UP}
  {$DEFINE DELPHI23_UP}
  {$DEFINE DELPHI24_UP}
  {$DEFINE DELPHI25_UP}
  {$DEFINE DELPHI26_UP}
  {$DEFINE DELPHI27_UP}
  {$DEFINE DELPHI28_UP}
{$ENDIF}

// Delphi Sidney
{$IFDEF VER340}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
  {$DEFINE DELPHI19_UP}
  {$DEFINE DELPHI20_UP}
  {$DEFINE DELPHI21_UP}
  {$DEFINE DELPHI22_UP}
  {$DEFINE DELPHI23_UP}
  {$DEFINE DELPHI24_UP}
  {$DEFINE DELPHI25_UP}
  {$DEFINE DELPHI26_UP}
  {$DEFINE DELPHI27_UP}
{$ENDIF}

// Delphi Rio
{$IFDEF VER330}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
  {$DEFINE DELPHI19_UP}
  {$DEFINE DELPHI20_UP}
  {$DEFINE DELPHI21_UP}
  {$DEFINE DELPHI22_UP}
  {$DEFINE DELPHI23_UP}
  {$DEFINE DELPHI24_UP}
  {$DEFINE DELPHI25_UP}
  {$DEFINE DELPHI26_UP}
{$ENDIF}

// Delphi Tokyo
{$IFDEF VER320}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
  {$DEFINE DELPHI19_UP}
  {$DEFINE DELPHI20_UP}
  {$DEFINE DELPHI21_UP}
  {$DEFINE DELPHI22_UP}
  {$DEFINE DELPHI23_UP}
  {$DEFINE DELPHI24_UP}
  {$DEFINE DELPHI25_UP}
{$ENDIF}

// Delphi BERLIN
{$IFDEF VER310}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
  {$DEFINE DELPHI19_UP}
  {$DEFINE DELPHI20_UP}
  {$DEFINE DELPHI21_UP}
  {$DEFINE DELPHI22_UP}
  {$DEFINE DELPHI23_UP}
  {$DEFINE DELPHI24_UP}
{$ENDIF}

// Delphi SEATLLE
{$IFDEF VER300}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
  {$DEFINE DELPHI19_UP}
  {$DEFINE DELPHI20_UP}
  {$DEFINE DELPHI21_UP}
  {$DEFINE DELPHI22_UP}
  {$DEFINE DELPHI23_UP}
{$ENDIF}

// Delphi XE8
{$IFDEF VER290}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
  {$DEFINE DELPHI19_UP}
  {$DEFINE DELPHI20_UP}
  {$DEFINE DELPHI21_UP}
  {$DEFINE DELPHI22_UP}
{$ENDIF}

// Delphi XE7
{$IFDEF VER280}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
  {$DEFINE DELPHI19_UP}
  {$DEFINE DELPHI20_UP}
  {$DEFINE DELPHI21_UP}
{$ENDIF}

// Delphi XE6
{$IFDEF VER270}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
  {$DEFINE DELPHI19_UP}
  {$DEFINE DELPHI20_UP}
{$ENDIF}

// Delphi XE5
{$IFDEF VER260}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
  {$DEFINE DELPHI19_UP}
{$ENDIF}

// Delphi XE4
{$IFDEF VER250}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
  {$DEFINE DELPHI18_UP}
{$ENDIF}

// Delphi XE3
{$IFDEF VER240}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
  {$DEFINE DELPHI17_UP}
{$ENDIF}

// Delphi XE2
{$IFDEF VER230}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
  {$DEFINE DELPHI16_UP}
{$ENDIF}

// Delphi XE
{$IFDEF VER220}
  {$DEFINE DELPHI14_UP}
  {$DEFINE DELPHI15_UP}
{$ENDIF}

//Delphi 2010
{$IFDEF VER210}
  {$DEFINE DELPHI14_UP}
{$ENDIF}

//Lazarus
// DEAD BLOCK - DO NOT "FIX" THE TYPO WITHOUT READING THIS.
// The guard says FCP; the FPC/Lazarus symbol is FPC, so this block has never been taken.
// Correcting it to {$IFDEF FPC} is not a no-op: it would start asserting that FPC provides
// the Delphi 2010 feature level (DELPHI14_UP), a mapping nobody has ever compiled or tested
// here - there is no FPC/Lazarus build of this library, and the declared floor is Delphi XE
// (README.md:3 and README.md:33).
// It is also, today, unobservable either way: this file is included by exactly one unit
// (ModernSyntax.Objects.pas:16) and NO unit in the repository reads DELPHI14_UP - or any other
// symbol defined below - so nothing changes behaviour whichever way the guard is spelled.
// Left as-is on purpose: activating an unverified compatibility claim is worse than a typo in
// code that no one reads. Fix it together with a real FPC target and a build that proves it.
{$IFDEF FCP}
  {$DEFINE DELPHI14_UP}
{$ENDIF}

{$IFDEF DELPHI15_UP}
  {$DEFINE FORMATSETTINGS}
{$ENDIF}

{$IFDEF DELPHI17_UP}
  {$DEFINE HAS_NET_ENCODING}
{$ELSEIF Defined(DELPHI16_UP)}
  {$DEFINE HAS_SOAP_ENCODING}
{$ELSE}
  {$DEFINE HAS_ENCDDECD}
{$ENDIF}
