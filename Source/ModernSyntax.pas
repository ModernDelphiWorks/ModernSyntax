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

unit ModernSyntax;

interface

uses
  Rtti,
  SysUtils,
  Generics.Collections,
  Generics.Defaults;

type
  Tuple = array of TValue;

  IMSObserver = interface
    ['{5887CDFF-DA23-4466-A5CB-FBA1DFEAF907}']
    procedure Update(const Progress: Integer);
  end;

  TFuture = record
  private
    FValue: TValue;
    FErr: String;
    FIsOK: Boolean;
    FIsErr: Boolean;
  public
    /// <summary>
    ///   Checks if the future is in a successful state.
    /// </summary>
    /// <returns>
    ///   True if the future is successful, otherwise False.
    /// </returns>
    function IsOk: Boolean;

    /// <summary>
    ///   Checks if the future contains an error.
    /// </summary>
    /// <returns>
    ///   True if the future contains an error, otherwise False.
    /// </returns>
    function IsErr: Boolean;

    /// <summary>
    ///   Retrieves the successful value of the future.
    /// </summary>
    /// <returns>
    ///   The value of type T.
    /// </returns>
    function Ok<T>: T;

    /// <summary>
    ///   Retrieves the error message of the future.
    /// </summary>
    /// <returns>
    ///   The error message.
    /// </returns>
    function Err: String;

    /// <summary>
    ///   Sets the future to a successful state with a value.
    /// </summary>
    /// <param name="AValue">
    ///   The value to set.
    /// </param>
    procedure SetOk(const AValue: TValue);

    /// <summary>
    ///   Sets the future to an error state with an error message.
    /// </summary>
    /// <param name="AErr">
    ///   The error message to set.
    /// </param>
    procedure SetErr(const AErr: String);
  end;

  TSet<T> = class sealed
  strict private
    FItems: TDictionary<T, Boolean>;
    FComparer: IEqualityComparer<T>;
    function _GetCount: Integer;
  public
    /// <summary>
    ///   Initializes a new instance of the TSet class.
    /// </summary>
    constructor Create; overload;

    /// <summary>
    ///   Initializes a new instance of the TSet class with a custom comparer.
    /// </summary>
    /// <param name="Comparer">
    ///   The comparer to use for item equality.
    /// </param>
    constructor Create(const Comparer: IEqualityComparer<T>); overload;

    /// <summary>
    ///   Destroys the TSet instance.
    /// </summary>
    destructor Destroy; override;

    /// <summary>
    ///   Adds an item to the set.
    /// </summary>
    /// <param name="Item">
    ///   The item to add.
    /// </param>
    /// <returns>
    ///   True if the item was added, otherwise False.
    /// </returns>
    function Add(const Item: T): Boolean;

    /// <summary>
    ///   Checks if the set contains a specific item.
    /// </summary>
    /// <param name="Item">
    ///   The item to check.
    /// </param>
    /// <returns>
    ///   True if the set contains the item, otherwise False.
    /// </returns>
    function Contains(const Item: T): Boolean;

    /// <summary>
    ///   Removes an item from the set.
    /// </summary>
    /// <param name="Item">
    ///   The item to remove.
    /// </param>
    /// <returns>
    ///   True if the item was removed, otherwise False.
    /// </returns>
    function Remove(const Item: T): Boolean;

    /// <summary>
    ///   Converts the set to an array.
    /// </summary>
    /// <returns>
    ///   An array containing the items in the set.
    /// </returns>
    function ToArray: TArray<T>;

    /// <summary>
    ///   Creates a union of this set with another set.
    /// </summary>
    /// <param name="Other">
    ///   The other set to union with.
    /// </param>
    /// <returns>
    ///   A new set containing the union of both sets.
    /// </returns>
    function Union(const Other: TSet<T>): TSet<T>;

    /// <summary>
    ///   Clears all items from the set.
    /// </summary>
    procedure Clear;

    /// <summary>
    ///   Gets the number of items in the set.
    /// </summary>
    property Count: Integer read _GetCount;
  end;


implementation

{ TFuture }

function TFuture.Err: String;
begin
  Result := FErr;
end;

function TFuture.IsErr: Boolean;
begin
  Result := FIsErr;
end;

function TFuture.IsOk: Boolean;
begin
  Result := FIsOK;
end;

function TFuture.Ok<T>: T;
begin
  if not FIsOK then
    raise Exception.Create('Future is not in a success state');
  Result := FValue.AsType<T>;
end;

procedure TFuture.SetErr(const AErr: String);
begin
  FErr := AErr;
  FIsErr := True;
  FIsOK := False;
end;

procedure TFuture.SetOk(const AValue: TValue);
begin
  FValue := AValue;
  FIsOK := True;
  FIsErr := False;
end;

{ TSet<T> }

constructor TSet<T>.Create;
begin
  FComparer := TEqualityComparer<T>.Default;
  FItems := TDictionary<T, Boolean>.Create(FComparer);
end;

constructor TSet<T>.Create(const Comparer: IEqualityComparer<T>);
begin
  if Comparer = nil then
    FComparer := TEqualityComparer<T>.Default
  else
    FComparer := Comparer;
  FItems := TDictionary<T, Boolean>.Create(FComparer);
end;

destructor TSet<T>.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TSet<T>.Add(const Item: T): Boolean;
begin
  if not FItems.ContainsKey(Item) then
  begin
    FItems.Add(Item, True);
    Result := True;
  end
  else
    Result := False;
end;

function TSet<T>.Contains(const Item: T): Boolean;
begin
  Result := FItems.ContainsKey(Item);
end;

function TSet<T>.Remove(const Item: T): Boolean;
begin
  Result := FItems.ContainsKey(Item);
  if Result then
    FItems.Remove(Item);
end;

procedure TSet<T>.Clear;
begin
  FItems.Clear;
end;

function TSet<T>.ToArray: TArray<T>;
begin
  Result := FItems.Keys.ToArray;
end;

function TSet<T>._GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TSet<T>.Union(const Other: TSet<T>): TSet<T>;
var
  LItem: T;
begin
  Result := TSet<T>.Create(FComparer);
  for LItem in FItems.Keys do
    Result.Add(LItem);
  for LItem in Other.FItems.Keys do
    Result.Add(LItem);
end;

end.
