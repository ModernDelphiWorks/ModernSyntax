{
                          Apache License
                      Version 2.0, January 2004
                   http://www.apache.org/licenses/

       Licensed under the Apache License, Version 2.0 (the "License");
       you may not use this file except in compliance with the License.
       You may obtain a copy of the License at

             http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing, software
       distributed under the License is distributed on an "AS IS" BASIS,
       WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
       See the License for the specific language governing permissions and
       limitations under the License.
}

{
  @abstract(Evolution4D: Modern Delphi Development Library for Delphi)
  @description(Evolution4D brings modern, fluent, and expressive syntax to Delphi, making code cleaner and development more productive.)
  @created(03 Abr 2025)
  @author(Isaque Pinheiro <isaquepsp@gmail.com>)
  @Discord(https://discord.gg/T2zJC8zX)
}

unit Evolution.RegEx;

interface

uses
  SysUtils,
  RegularExpressions;

type
  TMatchLib = RegularExpressions.TMatch;
  TOptionLib = RegularExpressions.TRegExOption;
  TOptionsLib = RegularExpressions.TRegExOptions;
  TGroupLib = RegularExpressions.TGroupCollection;

  TEvolutionRegEx = class
  public
    /// <summary>
    ///   Determines whether the specified input String matches the specified regular expression pattern.
    /// </summary>
    /// <param name="AInput">The input String to match.</param>
    /// <param name="APattern">The regular expression pattern to match against.</param>
    /// <returns>True if the input String matches the pattern; otherwise, False.</returns>
    class function IsMatch(const AInput: String; const APattern: String): Boolean; overload; static;

    /// <summary>
    ///   Determines whether the specified input String matches the specified regular expression pattern with the specified options.
    /// </summary>
    /// <param name="AInput">The input String to match.</param>
    /// <param name="APattern">The regular expression pattern to match against.</param>
    /// <param name="AOptions">Additional options for matching.</param>
    /// <returns>True if the input String matches the pattern; otherwise, False.</returns>
    class function IsMatch(const AInput: String; const APattern: String; const AOptions: TOptionsLib): Boolean; overload; static; inline;

    /// <summary>
    ///   Searches the specified input String for a match to the specified regular expression pattern and returns a match result.
    /// </summary>
    /// <param name="AValue">The input String to search.</param>
    /// <param name="AExpression">The regular expression pattern to search for.</param>
    /// <returns>A match result object containing information about the match.</returns>
    class function MatchExpression(const AValue: String; const AExpression: String): TMatchLib; static; inline;

    /// <summary>
    ///   Replaces all occurrences of the specified pattern in the input String with the result of a specified evaluator function.
    /// </summary>
    /// <param name="AInput">The input String to search.</param>
    /// <param name="APattern">The regular expression pattern to search for.</param>
    /// <param name="AEvaluator">A function that provides replacement values for matched patterns.</param>
    /// <returns>The input String with all matched patterns replaced by the values provided by the evaluator function.</returns>
    class function Replace(const AInput, APattern: String; AEvaluator: TMatchEvaluator): String; overload; static; inline;

    /// <summary>
    ///   Replaces all occurrences of the specified pattern in the input String with a specified replacement String using the specified options.
    /// </summary>
    /// <param name="AInput">The input String to search.</param>
    /// <param name="APattern">The regular expression pattern to search for.</param>
    /// <param name="AReplacement">The replacement String to use for matched patterns.</param>
    /// <param name="AOptions">Additional options for the replacement operation.</param>
    /// <returns>The input String with all matched patterns replaced by the specified replacement String.</returns>
    class function Replace(const AInput, APattern, AReplacement: String; AOptions: TOptionsLib): String; overload; static; inline;

    /// <summary>
    ///   Replaces all occurrences of the specified pattern in the input String with the result of a specified evaluator function using the specified options.
    /// </summary>
    /// <param name="AInput">The input String to search.</param>
    /// <param name="APattern">The regular expression pattern to search for.</param>
    /// <param name="AEvaluator">A function that provides replacement values for matched patterns.</param>
    /// <param name="AOptions">Additional options for the replacement operation.</param>
    /// <returns>The input String with all matched patterns replaced by the values provided by the evaluator function.</returns>
    class function Replace(const AInput, APattern: String; AEvaluator: TMatchEvaluator; AOptions: TOptionsLib): String; overload; static; inline;

    /// <summary>
    ///   Replaces all occurrences of the specified pattern in the input String with a specified replacement String.
    /// </summary>
    /// <param name="AInput">The input String to search.</param>
    /// <param name="APattern">The regular expression pattern to search for.</param>
    /// <param name="AReplacement">The replacement String to use for matched patterns.</param>
    /// <returns>The input String with all matched patterns replaced by the specified replacement String.</returns>
    class function Replace(const AInput, APattern, AReplacement: String): String; overload; static; inline;

    /// <summary>
    ///   Determines whether the specified String is a valid email address.
    /// </summary>
    /// <param name="AEmail">The String to check for valid email format.</param>
    /// <returns>True if the String is a valid email address; otherwise, False.</returns>
    class function IsMatchValidEmail(const AEmail: String): Boolean; static; inline;

    /// <summary>
    ///   Determines whether the specified String is a valid UUID (Universally Unique Identifier).
    /// </summary>
    /// <param name="AUUID">The String to check for valid UUID format.</param>
    /// <returns>True if the String is a valid UUID; otherwise, False.</returns>
    class function IsMatchUUID(const AUUID: String): Boolean; static; inline;

    /// <summary>
    ///   Determines whether the specified String is a valid IPv4 address.
    /// </summary>
    /// <param name="AIPV4">
    ///   The String to check for valid IPv4 format.
    /// </param>
    /// <returns>
    ///   True if the String is a valid IPv4 address; otherwise, False.
    /// </returns>
    class function IsMatchIPV4(const AIPV4: String): Boolean; static; inline;

    /// <summary>
    ///   Determines whether the specified String is a valid Brazilian postal code (CEP).
    /// </summary>
    /// <param name="ACEP">
    ///   The String to check for valid CEP format.
    /// </param>
    /// <returns>
    ///   True if the String is a valid CEP; otherwise, False.
    /// </returns>
    class function IsMatchCEP(const ACEP: String): Boolean; static; inline;

    /// <summary>
    ///   Determines whether the specified String is a valid Brazilian individual taxpayer ID (CPF).
    /// </summary>
    /// <param name="ACPF">
    ///   The String to check for valid CPF format.
    /// </param>
    /// <returns>
    ///   True if the String is a valid CPF; otherwise, False.
    /// </returns>
    class function IsMatchCPF(const ACPF: String): Boolean; static; inline;

    /// <summary>
    ///   Determines whether the specified String is a valid Brazilian company taxpayer ID (CNPJ).
    /// </summary>
    /// <param name="ACNPJ">
    ///   The String to check for valid CNPJ format.
    /// </param>
    /// <returns>
    ///   True if the String is a valid CNPJ; otherwise, False.
    /// </returns>
    class function IsMatchCNPJ(const ACNPJ: String): Boolean; static; inline;

    /// <summary>
    ///   Determines whether the specified String is a valid Brazilian phone number with area code (DDD).
    /// </summary>
    /// <param name="APhone">
    ///   The String to check for valid DDD phone number format.
    /// </param>
    /// <returns>
    ///   True if the String is a valid DDD phone number; otherwise, False.
    /// </returns>
    class function IsMatchDDDPhone(const APhone: String): Boolean; static; inline;

    /// <summary>
    ///   Determines whether the specified String is a valid Mercosul vehicle license plate.
    /// </summary>
    /// <param name="APlaca">
    ///   The String to check for valid Mercosul license plate format.
    /// </param>
    /// <returns>
    ///   True if the String is a valid Mercosul license plate; otherwise, False.
    /// </returns>
    class function IsMatchPlacaMercosul(const APlaca: String): Boolean; static; inline;

    /// <summary>
    ///   Determines whether the specified String is a valid vehicle license plate (non-Mercosul format).
    /// </summary>
    /// <param name="APlaca">
    ///   The String to check for valid license plate format.
    /// </param>
    /// <returns>
    ///   True if the String is a valid license plate; otherwise, False.
    /// </returns>
    class function IsMatchPlaca(const APlaca: String): Boolean; static; inline;

    /// <summary>
    ///   Determines whether the specified String is a valid date.
    /// </summary>
    /// <param name="ADate">
    ///   The String to check for valid date format.
    /// </param>
    /// <returns>
    ///   True if the String is a valid date; otherwise, False.
    /// </returns>
    class function IsMatchData(const ADate: String): Boolean; static; inline;

    /// <summary>
    ///   Determines whether the specified String is a valid credit card number.
    /// </summary>
    /// <param name="ANumber">
    ///   The String to check for valid credit card number format.
    /// </param>
    /// <returns>
    ///   True if the String is a valid credit card number; otherwise, False.
    /// </returns>
    class function IsMatchCredCard(const ANumber: String): Boolean; static; inline;

    /// <summary>
    ///   Determines whether the specified String is a valid URL.
    /// </summary>
    /// <param name="AURL">
    ///   The String to check for valid URL format.
    /// </param>
    /// <returns>
    ///   True if the String is a valid URL; otherwise, False.
    /// </returns>
    class function IsMatchURL(const AURL: String): Boolean; static; inline;
  end;

implementation

{ TInfraRegEx }

class function TEvolutionRegEx.IsMatch(const AInput, APattern: String): Boolean;
begin
  Result := TRegEx.IsMatch(AInput, APattern, [roIgnoreCase]);
end;

class function TEvolutionRegEx.IsMatchCredCard(const ANumber: String): Boolean;
begin
  Result := TRegEx.IsMatch(ANumber, '^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\d{4}$');
end;

class function TEvolutionRegEx.IsMatchCEP(const ACEP: String): Boolean;
begin
  Result := TRegEx.IsMatch(ACEP, '^\d{8}$');
end;

class function TEvolutionRegEx.IsMatchCNPJ(const ACNPJ: String): Boolean;
begin
  Result := TRegEx.IsMatch(ACNPJ, '^\d{2}\.\d{3}\.\d{3}/\d{4}-\d{2}$');
end;

class function TEvolutionRegEx.IsMatchCPF(const ACPF: String): Boolean;
begin
  Result := TRegEx.IsMatch(ACPF, '^\d{3}\.\d{3}\.\d{3}-\d{2}$');
end;

class function TEvolutionRegEx.IsMatchData(const ADate: String): Boolean;
begin
  Result := TRegEx.IsMatch(ADate, '^(0[1-9]|[12][0-9]|3[01])/(0[1-9]|1[0-2])/\d{4}$');
end;

class function TEvolutionRegEx.IsMatchDDDPhone(const APhone: String): Boolean;
begin
  Result := TRegEx.IsMatch(APhone, '^\(\d{2}\) 9\d{4}-\d{4}$|^\(\d{2}\) [2-5]\d{3}-\d{4}$');
end;

class function TEvolutionRegEx.IsMatchIPV4(const AIPV4: String): Boolean;
begin
  Result := TRegEx.IsMatch(AIPV4, '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
end;

class function TEvolutionRegEx.IsMatch(const AInput, APattern: String;
  const AOptions: TOptionsLib): Boolean;
begin
  Result := TRegEx.IsMatch(AInput, APattern, AOptions);
end;

class function TEvolutionRegEx.IsMatchPlaca(const APlaca: String): Boolean;
begin
  Result := TRegEx.IsMatch(APlaca, '^[A-Z]{2,3}-\d{4}$');
end;

class function TEvolutionRegEx.IsMatchPlacaMercosul(const APlaca: String): Boolean;
begin
  Result := TRegEx.IsMatch(APlaca, '^[A-Z]{3}\d{1}[A-Z]\d{2}$|^[A-Z]{2}\d{2}[A-Z]\d{1}$');
end;

class function TEvolutionRegEx.IsMatchURL(const AURL: String): Boolean;
begin
  Result := TRegEx.IsMatch(AURL, '^(https?|ftp)://[-A-Z0-9+&@#/%?=~_|!:,.;]*[-A-Z0-9+&@#/%=~_|]', [roIgnoreCase]);
end;

class function TEvolutionRegEx.IsMatchUUID(const AUUID: String): Boolean;
begin
  Result := TRegEx.IsMatch(AUUID, '^(\{)?[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}(\})?$');
end;

class function TEvolutionRegEx.IsMatchValidEmail(const AEmail: String): Boolean;
begin
  Result := TRegEx.IsMatch(AEmail, '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
end;

class function TEvolutionRegEx.MatchExpression(const AValue,
  AExpression: String): TMatchLib;
var
  LRegEx: TRegEx;
  LMatch: TMatch;
begin
  LRegEx := TRegEx.Create(AExpression, [roIgnoreCase]);
  LMatch := LRegEx.Match(AValue);
  Result := LMatch;
end;

class function TEvolutionRegEx.Replace(const AInput, APattern: String;
  AEvaluator: TMatchEvaluator): String;
begin
   Result := TRegEx.Replace(AInput, APattern, AEvaluator);
end;

class function TEvolutionRegEx.Replace(const AInput, APattern, AReplacement: String;
  AOptions: TOptionsLib): String;
begin
   Result := TRegEx.Replace(AInput, APattern, AReplacement, AOptions);
end;

class function TEvolutionRegEx.Replace(const AInput, APattern: String;
  AEvaluator: TMatchEvaluator; AOptions: TOptionsLib): String;
begin
   Result := TRegEx.Replace(AInput, APattern, AEvaluator, AOptions);
end;

class function TEvolutionRegEx.Replace(const AInput, APattern,
  AReplacement: String): String;
begin
   Result := TRegEx.Replace(AInput, APattern, AReplacement);
end;

end.
