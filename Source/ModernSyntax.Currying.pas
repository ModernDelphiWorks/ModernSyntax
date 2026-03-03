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

unit ModernSyntax.Currying;

interface

uses
  Rtti,
  Math,
  Classes,
  SysUtils,
  TypInfo,
  Generics.Collections,
  Generics.Defaults,
  SyncObjs,
  DateUtils;

type
  /// <summary>
  /// Interface for objects that require cleanup of resources.
  /// </summary>
  ICleanup = interface
    ['{A8B8D8A0-5C5E-4D7B-9F2A-8D8C7B5F8E9C}']
    /// <summary>
    /// Performs cleanup of resources held by the object.
    /// </summary>
    procedure Cleanup;
  end;

  /// <summary>
  /// Interface defining numeric operations for a generic type T.
  /// </summary>
  INumeric<T> = interface
    ['{B9C8D7A0-4D5E-4C7B-8F2A-9D8C7B5F8E9C}']
    /// <summary>
    /// Adds the specified value to the current value.
    /// </summary>
    /// <param name="Value">The value to add.</param>
    /// <returns>The result of the addition.</returns>
    function Add(const Value: T): T;
    /// <summary>
    /// Subtracts the specified value from the current value.
    /// </summary>
    /// <param name="Value">The value to subtract.</param>
    /// <returns>The result of the subtraction.</returns>
    function Subtract(const Value: T): T;
    /// <summary>
    /// Multiplies the current value by the specified value.
    /// </summary>
    /// <param name="Value">The value to multiply by.</param>
    /// <returns>The result of the multiplication.</returns>
    function Multiply(const Value: T): T;
    /// <summary>
    /// Divides the current value by the specified value.
    /// </summary>
    /// <param name="Value">The value to divide by.</param>
    /// <returns>The result of the division.</returns>
    function Divide(const Value: T): T;
    /// <summary>
    /// Raises the current value to the power of the specified value.
    /// </summary>
    /// <param name="Value">The exponent value.</param>
    /// <returns>The result of the power operation.</returns>
    function Power(const Value: T): T;
    /// <summary>
    /// Computes the modulus of the current value with the specified value.
    /// </summary>
    /// <param name="Value">The value to compute modulus with.</param>
    /// <returns>The modulus result.</returns>
    function Modulus(const Value: T): T;
    /// <summary>
    /// Returns the string representation of the current value.
    /// </summary>
    /// <returns>The string representation of the value.</returns>
    function AsString: string;
    /// <summary>
    /// Retrieves the current value.
    /// </summary>
    /// <returns>The current value of type T.</returns>
    function GetValue: T;
  end;

  /// <summary>
  /// Represents a pipeline for chaining operations on a value of type T.
  /// </summary>
  TPipeline<T> = record
  private
    FValue: T;
  public
    /// <summary>
    /// Creates a new pipeline instance with the specified initial value.
    /// </summary>
    /// <param name="AValue">The initial value of type T.</param>
    constructor Create(AValue: T);
    /// <summary>
    /// Applies a function to the current value, transforming it to a new type U.
    /// </summary>
    /// <param name="F">The function to apply, transforming T to U.</param>
    /// <returns>A new pipeline with the transformed value of type U.</returns>
    function Apply<U>(F: TFunc<T, U>): TPipeline<U>;
    /// <summary>
    /// Maps the current value to a new value of type U using the specified function.
    /// </summary>
    /// <param name="F">The mapping function from T to U.</param>
    /// <returns>A new pipeline with the mapped value of type U.</returns>
    function Map<U>(F: TFunc<T, U>): TPipeline<U>;
    /// <summary>
    /// Chains another operation on the current value, transforming it to type U.
    /// </summary>
    /// <param name="F">The function to chain, transforming T to U.</param>
    /// <returns>A new pipeline with the result of type U.</returns>
    function Thn<U>(F: TFunc<T, U>): TPipeline<U>;
    /// <summary>
    /// Retrieves the current value in the pipeline.
    /// </summary>
    /// <returns>The current value of type T.</returns>
    function Value: T;
  end;

  /// <summary>
  /// A thread-safe cache for memoizing function results.
  /// </summary>
  TMemoizedCache<T, U> = class(TInterfacedObject, ICleanup)
  private
    FCache: TDictionary<T, U>;
    FLock: TCriticalSection;
  public
    /// <summary>
    /// Creates a new memoized cache instance.
    /// </summary>
    constructor Create;
    /// <summary>
    /// Destroys the memoized cache instance, freeing resources.
    /// </summary>
    destructor Destroy; override;
    /// <summary>
    /// Clears the cache, releasing all stored key-value pairs.
    /// </summary>
    procedure Cleanup;
    /// <summary>
    /// Retrieves a value from the cache or computes and stores it if not present.
    /// </summary>
    /// <param name="Key">The key to lookup or store.</param>
    /// <param name="Func">The function to compute the value if not cached.</param>
    /// <returns>The cached or computed value of type U.</returns>
    function GetOrAdd(Key: T; Func: TFunc<T, U>): U;
  end;

  /// <summary>
  /// Provides functional programming utilities with currying capabilities.
  /// </summary>
  TCurrying = record
  private
    FValue: TValue;
  public
    /// <summary>
    /// Creates a new TCurrying instance with the specified initial value.
    /// </summary>
    /// <param name="AValue">The initial value to wrap.</param>
    constructor Create(AValue: TValue);
    /// <summary>
    /// Applies a binary operation to the current value and a new value, returning a curried function.
    /// </summary>
    /// <param name="Operation">The binary operation to apply, taking two arguments of type T.</param>
    /// <returns>A function that takes a single argument of type T and returns a new TCurrying instance.</returns>
    function Op<T>(const Operation: TFunc<T, T, T>): TFunc<T, TCurrying>;
    /// <summary>
    /// Concatenates a string to the current value, returning a curried function.
    /// </summary>
    /// <returns>A function that takes a string and returns a new TCurrying instance with the concatenated result.</returns>
    function Concat: TFunc<string, TCurrying>;
    /// <summary>
    /// Retrieves the current value as the specified type T.
    /// </summary>
    /// <returns>The current value cast to type T.</returns>
    function Value<T>: T;
    /// <summary>
    /// Retrieves the current value as a TValue.
    /// </summary>
    /// <returns>The current value as a TValue.</returns>
    function TValueValue: TValue;

    /// <summary>
    /// Composes two functions, creating a new function that applies G then F.
    /// </summary>
    /// <param name="F">The outer function, transforming U to V.</param>
    /// <param name="G">The inner function, transforming T to U.</param>
    /// <returns>A function that takes T and returns V after applying G then F.</returns>
    class function Compose<T, U, V>(F: TFunc<U, V>; G: TFunc<T, U>): TFunc<T, V>; static;
    /// <summary>
    /// Creates a partially applied function by fixing one argument of a binary function.
    /// </summary>
    /// <param name="F">The binary function to partially apply.</param>
    /// <param name="FirstArg">The argument to fix.</param>
    /// <param name="FixFirst">If True, fixes the first argument; if False, fixes the second.</param>
    /// <returns>A function that takes one argument and returns the result of applying F.</returns>
    class function Partial<T, V>(F: TFunc<T, T, V>; FirstArg: T; FixFirst: Boolean = True): TFunc<T, V>; static;
    /// <summary>
    /// Memoizes a function, caching its results for subsequent calls with the same input.
    /// </summary>
    /// <param name="F">The function to memoize.</param>
    /// <returns>A memoized version of the function.</returns>
    class function Memoize<T, U>(F: TFunc<T, U>): TFunc<T, U>; static;
    /// <summary>
    /// Creates a pipeline starting with the specified value.
    /// </summary>
    /// <param name="X">The initial value of type T.</param>
    /// <returns>A pipeline instance with the initial value.</returns>
    class function Pipe<T>(X: T): TPipeline<T>; static;
    /// <summary>
    /// Curries a binary function into a function that takes arguments one at a time.
    /// </summary>
    /// <param name="F">The binary function to curry.</param>
    /// <returns>A curried function that takes T and returns a function from U to V.</returns>
    class function Curry<T, U, V>(F: TFunc<T, U, V>): TFunc<T, TFunc<U, V>>; static;
    /// <summary>
    /// Uncurries a curried function back into a binary function.
    /// </summary>
    /// <param name="F">The curried function to uncurry.</param>
    /// <returns>A binary function that takes T and U and returns V.</returns>
    class function UnCurry<T, U, V>(F: TFunc<T, TFunc<U, V>>): TFunc<T, U, V>; static;
    /// <summary>
    /// Maps a function over a list, transforming each element.
    /// </summary>
    /// <param name="List">The input list of type T.</param>
    /// <param name="F">The function to apply to each element, transforming T to U.</param>
    /// <returns>A new list with elements of type U.</returns>
    class function Map<T, U>(List: TList<T>; F: TFunc<T, U>): TList<U>; static;
    /// <summary>
    /// Filters a list based on a predicate, keeping only elements that satisfy it.
    /// </summary>
    /// <param name="List">The input list of type T.</param>
    /// <param name="Predicate">The predicate to test each element.</param>
    /// <returns>A new list with elements that satisfy the predicate.</returns>
    class function Filter<T>(List: TList<T>; Predicate: TFunc<T, Boolean>): TList<T>; static;
    /// <summary>
    /// Reduces a list to a single value using a folding function.
    /// </summary>
    /// <param name="List">The input list of type T.</param>
    /// <param name="Initial">The initial accumulator value of type U.</param>
    /// <param name="F">The folding function, combining U and T into U.</param>
    /// <returns>The final accumulated value of type U.</returns>
    class function Fold<T, U>(List: TList<T>; Initial: U; F: TFunc<U, T, U>): U; static;
    /// <summary>
    /// Converts an array to a string with a specified separator.
    /// </summary>
    /// <param name="Arr">The array to convert.</param>
    /// <param name="Separator">The separator to use between elements (default: ', ').</param>
    /// <returns>A string representation of the array.</returns>
    class function ArrayToString<T>(const Arr: TArray<T>; const Separator: string = ', '): string; static;
    /// <summary>
    /// Takes the first N elements from a list.
    /// </summary>
    /// <param name="List">The input list of type T.</param>
    /// <param name="Count">The number of elements to take.</param>
    /// <returns>A new list with the first Count elements.</returns>
    class function Take<T>(List: TList<T>; Count: Integer): TList<T>; static;
    /// <summary>
    /// Drops the first N elements from a list.
    /// </summary>
    /// <param name="List">The input list of type T.</param>
    /// <param name="Count">The number of elements to drop.</param>
    /// <returns>A new list with the remaining elements after dropping Count elements.</returns>
    class function Drop<T>(List: TList<T>; Count: Integer): TList<T>; static;
    /// <summary>
    /// Zips two lists into a list of pairs.
    /// </summary>
    /// <param name="List1">The first list of type T1.</param>
    /// <param name="List2">The second list of type T2.</param>
    /// <returns>A list of pairs combining elements from List1 and List2.</returns>
    class function Zip<T1, T2>(List1: TList<T1>; List2: TList<T2>): TList<TPair<T1, T2>>; static;
    /// <summary>
    /// Checks if any element in the list satisfies the predicate.
    /// </summary>
    /// <param name="List">The input list of type T.</param>
    /// <param name="Predicate">The predicate to test elements.</param>
    /// <returns>True if at least one element satisfies the predicate, False otherwise.</returns>
    class function Any<T>(List: TList<T>; Predicate: TFunc<T, Boolean>): Boolean; static;
    /// <summary>
    /// Checks if all elements in the list satisfy the predicate.
    /// </summary>
    /// <param name="List">The input list of type T.</param>
    /// <param name="Predicate">The predicate to test elements.</param>
    /// <returns>True if all elements satisfy the predicate, False otherwise.</returns>
    class function All<T>(List: TList<T>; Predicate: TFunc<T, Boolean>): Boolean; static;
    /// <summary>
    /// Groups a list into a dictionary based on a key selector function.
    /// </summary>
    /// <param name="List">The input list of type T.</param>
    /// <param name="KeySelector">The function to extract keys of type TKey from elements.</param>
    /// <returns>A dictionary mapping keys to lists of elements.</returns>
    class function GroupBy<T, TKey>(List: TList<T>; KeySelector: TFunc<T, TKey>): TDictionary<TKey, TList<T>>; static;
    /// <summary>
    /// Takes elements from a list while the predicate is true.
    /// </summary>
    /// <param name="List">The input list of type T.</param>
    /// <param name="Predicate">The predicate to test elements.</param>
    /// <returns>A new list with elements taken while the predicate holds.</returns>
    class function TakeWhile<T>(List: TList<T>; Predicate: TFunc<T, Boolean>): TList<T>; static;
    /// <summary>
    /// Drops elements from a list while the predicate is true.
    /// </summary>
    /// <param name="List">The input list of type T.</param>
    /// <param name="Predicate">The predicate to test elements.</param>
    /// <returns>A new list with remaining elements after dropping while the predicate holds.</returns>
    class function DropWhile<T>(List: TList<T>; Predicate: TFunc<T, Boolean>): TList<T>; static;
    /// <summary>
    /// Returns a list with distinct elements, removing duplicates.
    /// </summary>
    /// <param name="List">The input list of type T.</param>
    /// <returns>A new list with unique elements.</returns>
    class function Distinct<T>(List: TList<T>): TList<T>; static;
    /// <summary>
    /// Reverses the order of elements in a list.
    /// </summary>
    /// <param name="List">The input list of type T.</param>
    /// <returns>A new list with elements in reverse order.</returns>
    class function Reverse<T>(List: TList<T>): TList<T>; static;
    /// <summary>
    /// Sorts a list using an optional comparer.
    /// </summary>
    /// <param name="List">The input list of type T.</param>
    /// <param name="Comparer">The comparer to use for sorting (default: nil, uses default comparer).</param>
    /// <returns>A new sorted list of type T.</returns>
    class function Sort<T>(List: TList<T>; Comparer: IComparer<T> = nil): TList<T>; static;
    /// <summary>
    /// Counts elements in a list that satisfy a predicate.
    /// </summary>
    /// <param name="List">The input list of type T.</param>
    /// <param name="Predicate">The predicate to test elements.</param>
    /// <returns>The number of elements that satisfy the predicate.</returns>
    class function Count<T>(List: TList<T>; Predicate: TFunc<T, Boolean>): Integer; static;
    /// <summary>
    /// Returns the first element in a list that satisfies a predicate.
    /// </summary>
    /// <param name="List">The input list of type T.</param>
    /// <param name="Predicate">The predicate to test elements.</param>
    /// <returns>The first element that satisfies the predicate.</returns>
    class function First<T>(List: TList<T>; Predicate: TFunc<T, Boolean>): T; static;
    /// <summary>
    /// Returns the last element in a list that satisfies a predicate.
    /// </summary>
    /// <param name="List">The input list of type T.</param>
    /// <param name="Predicate">The predicate to test elements.</param>
    /// <returns>The last element that satisfies the predicate.</returns>
    class function Last<T>(List: TList<T>; Predicate: TFunc<T, Boolean>): T; static;
    /// <summary>
    /// Concatenates two lists into a single list.
    /// </summary>
    /// <param name="List1">The first list of type T.</param>
    /// <param name="List2">The second list of type T.</param>
    /// <returns>A new list containing all elements from List1 followed by List2.</returns>
    class function ConcatLists<T>(List1, List2: TList<T>): TList<T>; static;
    /// <summary>
    /// Partitions a list into two lists based on a predicate.
    /// </summary>
    /// <param name="List">The input list of type T.</param>
    /// <param name="Predicate">The predicate to partition elements.</param>
    /// <returns>A pair of lists: the first with elements satisfying the predicate, the second with those that don't.</returns>
    class function Partition<T>(List: TList<T>; Predicate: TFunc<T, Boolean>): TPair<TList<T>, TList<T>>; static;
    /// <summary>
    /// Flattens a list of lists into a single list.
    /// </summary>
    /// <param name="List">The list of lists of type T.</param>
    /// <returns>A new list with all sublist elements flattened.</returns>
    class function Flatten<T>(List: TList<TList<T>>): TList<T>; static;
    /// <summary>
    /// Checks if two lists are equal in length and element order.
    /// </summary>
    /// <param name="List1">The first list of type T.</param>
    /// <param name="List2">The second list of type T.</param>
    /// <returns>True if the lists are equal, False otherwise.</returns>
    class function SequenceEqual<T>(List1, List2: TList<T>): Boolean; static;
  end;

  /// <summary>
  /// Implements numeric operations for the Byte type.
  /// </summary>
  TNumericByte = class(TInterfacedObject, INumeric<Byte>)
  private
    FValue: Byte;
  public
    /// <summary>
    /// Creates a new TNumericByte instance with the specified value.
    /// </summary>
    /// <param name="AValue">The initial value of type Byte.</param>
    constructor Create(AValue: Byte);
    function Add(const Value: Byte): Byte;
    function Subtract(const Value: Byte): Byte;
    function Multiply(const Value: Byte): Byte;
    function Divide(const Value: Byte): Byte;
    function Power(const Value: Byte): Byte;
    function Modulus(const Value: Byte): Byte;
    function AsString: string;
    function GetValue: Byte;
  end;

  /// <summary>
  /// Implements numeric operations for the ShortInt type.
  /// </summary>
  TNumericShortInt = class(TInterfacedObject, INumeric<ShortInt>)
  private
    FValue: ShortInt;
  public
    /// <summary>
    /// Creates a new TNumericShortInt instance with the specified value.
    /// </summary>
    /// <param name="AValue">The initial value of type ShortInt.</param>
    constructor Create(AValue: ShortInt);
    function Add(const Value: ShortInt): ShortInt;
    function Subtract(const Value: ShortInt): ShortInt;
    function Multiply(const Value: ShortInt): ShortInt;
    function Divide(const Value: ShortInt): ShortInt;
    function Power(const Value: ShortInt): ShortInt;
    function Modulus(const Value: ShortInt): ShortInt;
    function AsString: string;
    function GetValue: ShortInt;
  end;

  /// <summary>
  /// Implements numeric operations for the Word type.
  /// </summary>
  TNumericWord = class(TInterfacedObject, INumeric<Word>)
  private
    FValue: Word;
  public
    /// <summary>
    /// Creates a new TNumericWord instance with the specified value.
    /// </summary>
    /// <param name="AValue">The initial value of type Word.</param>
    constructor Create(AValue: Word);
    function Add(const Value: Word): Word;
    function Subtract(const Value: Word): Word;
    function Multiply(const Value: Word): Word;
    function Divide(const Value: Word): Word;
    function Power(const Value: Word): Word;
    function Modulus(const Value: Word): Word;
    function AsString: string;
    function GetValue: Word;
  end;

  /// <summary>
  /// Implements numeric operations for the SmallInt type.
  /// </summary>
  TNumericSmallInt = class(TInterfacedObject, INumeric<SmallInt>)
  private
    FValue: SmallInt;
  public
    /// <summary>
    /// Creates a new TNumericSmallInt instance with the specified value.
    /// </summary>
    /// <param name="AValue">The initial value of type SmallInt.</param>
    constructor Create(AValue: SmallInt);
    function Add(const Value: SmallInt): SmallInt;
    function Subtract(const Value: SmallInt): SmallInt;
    function Multiply(const Value: SmallInt): SmallInt;
    function Divide(const Value: SmallInt): SmallInt;
    function Power(const Value: SmallInt): SmallInt;
    function Modulus(const Value: SmallInt): SmallInt;
    function AsString: string;
    function GetValue: SmallInt;
  end;

  /// <summary>
  /// Implements numeric operations for the LongWord type.
  /// </summary>
  TNumericLongWord = class(TInterfacedObject, INumeric<LongWord>)
  private
    FValue: LongWord;
  public
    /// <summary>
    /// Creates a new TNumericLongWord instance with the specified value.
    /// </summary>
    /// <param name="AValue">The initial value of type LongWord.</param>
    constructor Create(AValue: LongWord);
    function Add(const Value: LongWord): LongWord;
    function Subtract(const Value: LongWord): LongWord;
    function Multiply(const Value: LongWord): LongWord;
    function Divide(const Value: LongWord): LongWord;
    function Power(const Value: LongWord): LongWord;
    function Modulus(const Value: LongWord): LongWord;
    function AsString: string;
    function GetValue: LongWord;
  end;

  /// <summary>
  /// Implements numeric operations for the Int64 type.
  /// </summary>
  TNumericInt64 = class(TInterfacedObject, INumeric<Int64>)
  private
    FValue: Int64;
  public
    /// <summary>
    /// Creates a new TNumericInt64 instance with the specified value.
    /// </summary>
    /// <param name="AValue">The initial value of type Int64.</param>
    constructor Create(AValue: Int64);
    function Add(const Value: Int64): Int64;
    function Subtract(const Value: Int64): Int64;
    function Multiply(const Value: Int64): Int64;
    function Divide(const Value: Int64): Int64;
    function Power(const Value: Int64): Int64;
    function Modulus(const Value: Int64): Int64;
    function AsString: string;
    function GetValue: Int64;
  end;

  /// <summary>
  /// Implements numeric operations for the Single type.
  /// </summary>
  TNumericSingle = class(TInterfacedObject, INumeric<Single>)
  private
    FValue: Single;
  public
    /// <summary>
    /// Creates a new TNumericSingle instance with the specified value.
    /// </summary>
    /// <param name="AValue">The initial value of type Single.</param>
    constructor Create(AValue: Single);
    function Add(const Value: Single): Single;
    function Subtract(const Value: Single): Single;
    function Multiply(const Value: Single): Single;
    function Divide(const Value: Single): Single;
    function Power(const Value: Single): Single;
    function Modulus(const Value: Single): Single;
    function AsString: string;
    function GetValue: Single;
  end;

  /// <summary>
  /// Implements numeric operations for the Double type.
  /// </summary>
  TNumericDouble = class(TInterfacedObject, INumeric<Double>)
  private
    FValue: Double;
  public
    /// <summary>
    /// Creates a new TNumericDouble instance with the specified value.
    /// </summary>
    /// <param name="AValue">The initial value of type Double.</param>
    constructor Create(AValue: Double);
    function Add(const Value: Double): Double;
    function Subtract(const Value: Double): Double;
    function Multiply(const Value: Double): Double;
    function Divide(const Value: Double): Double;
    function Power(const Value: Double): Double;
    function Modulus(const Value: Double): Double;
    function AsString: string;
    function GetValue: Double;
  end;

  /// <summary>
  /// Implements numeric operations for the Integer type.
  /// </summary>
  TNumericInteger = class(TInterfacedObject, INumeric<Integer>)
  private
    FValue: Integer;
  public
    /// <summary>
    /// Creates a new TNumericInteger instance with the specified value.
    /// </summary>
    /// <param name="AValue">The initial value of type Integer.</param>
    constructor Create(AValue: Integer);
    function Add(const Value: Integer): Integer;
    function Subtract(const Value: Integer): Integer;
    function Multiply(const Value: Integer): Integer;
    function Divide(const Value: Integer): Integer;
    function Power(const Value: Integer): Integer;
    function Modulus(const Value: Integer): Integer;
    function AsString: string;
    function GetValue: Integer;
  end;

  /// <summary>
  /// Implements numeric operations for the Extended type.
  /// </summary>
  TNumericExtended = class(TInterfacedObject, INumeric<Extended>)
  private
    FValue: Extended;
  public
    /// <summary>
    /// Creates a new TNumericExtended instance with the specified value.
    /// </summary>
    /// <param name="AValue">The initial value of type Extended.</param>
    constructor Create(AValue: Extended);
    function Add(const Value: Extended): Extended;
    function Subtract(const Value: Extended): Extended;
    function Multiply(const Value: Extended): Extended;
    function Divide(const Value: Extended): Extended;
    function Power(const Value: Extended): Extended;
    function Modulus(const Value: Extended): Extended;
    function AsString: string;
    function GetValue: Extended;
  end;

  /// <summary>
  /// Implements logical operations for the Boolean type.
  /// </summary>
  TNumericBoolean = class(TInterfacedObject, INumeric<Boolean>)
  private
    FValue: Boolean;
  public
    /// <summary>
    /// Creates a new TNumericBoolean instance with the specified value.
    /// </summary>
    /// <param name="AValue">The initial value of type Boolean.</param>
    constructor Create(AValue: Boolean);
    /// <summary>
    /// Performs a logical OR operation with the specified value.
    /// </summary>
    /// <param name="Value">The value to OR with.</param>
    /// <returns>The result of the OR operation.</returns>
    function Add(const Value: Boolean): Boolean;
    /// <summary>
    /// Not supported for Boolean; raises an exception.
    /// </summary>
    function Subtract(const Value: Boolean): Boolean;
    /// <summary>
    /// Performs a logical AND operation with the specified value.
    /// </summary>
    /// <param name="Value">The value to AND with.</param>
    /// <returns>The result of the AND operation.</returns>
    function Multiply(const Value: Boolean): Boolean;
    /// <summary>
    /// Not supported for Boolean; raises an exception.
    /// </summary>
    function Divide(const Value: Boolean): Boolean;
    /// <summary>
    /// Not supported for Boolean; raises an exception.
    /// </summary>
    function Power(const Value: Boolean): Boolean;
    /// <summary>
    /// Not supported for Boolean; raises an exception.
    /// </summary>
    function Modulus(const Value: Boolean): Boolean;
    /// <summary>
    /// Returns the string representation of the current Boolean value.
    /// </summary>
    /// <returns>'True' or 'False' as a string.</returns>
    function AsString: string;
    /// <summary>
    /// Retrieves the current Boolean value.
    /// </summary>
    /// <returns>The current value of type Boolean.</returns>
    function GetValue: Boolean;
  end;

  /// <summary>
  /// Implements operations for the TDateTime type.
  /// </summary>
  TNumericDateTime = class(TInterfacedObject, INumeric<TDateTime>)
  private
    FValue: TDateTime;
  public
    /// <summary>
    /// Creates a new TNumericDateTime instance with the specified value.
    /// </summary>
    /// <param name="AValue">The initial value of type TDateTime.</param>
    constructor Create(AValue: TDateTime);
    /// <summary>
    /// Adds the specified TDateTime (treated as days) to the current value.
    /// </summary>
    /// <param name="Value">The TDateTime value to add (interpreted as days).</param>
    /// <returns>The resulting TDateTime after addition.</returns>
    function Add(const Value: TDateTime): TDateTime;
    /// <summary>
    /// Subtracts the specified TDateTime (treated as days) from the current value.
    /// </summary>
    /// <param name="Value">The TDateTime value to subtract (interpreted as days).</param>
    /// <returns>The resulting TDateTime after subtraction.</returns>
    function Subtract(const Value: TDateTime): TDateTime;
    /// <summary>
    /// Not supported for TDateTime; raises an exception.
    /// </summary>
    function Multiply(const Value: TDateTime): TDateTime;
    /// <summary>
    /// Not supported for TDateTime; raises an exception.
    /// </summary>
    function Divide(const Value: TDateTime): TDateTime;
    /// <summary>
    /// Not supported for TDateTime; raises an exception.
    /// </summary>
    function Power(const Value: TDateTime): TDateTime;
    /// <summary>
    /// Not supported for TDateTime; raises an exception.
    /// </summary>
    function Modulus(const Value: TDateTime): TDateTime;
    /// <summary>
    /// Returns the string representation of the current TDateTime value.
    /// </summary>
    /// <returns>The TDateTime value as a string.</returns>
    function AsString: string;
    /// <summary>
    /// Retrieves the current TDateTime value.
    /// </summary>
    /// <returns>The current value of type TDateTime.</returns>
    function GetValue: TDateTime;
  end;

  /// <summary>
  /// Implements operations for the String type, treating it as a numeric-like entity.
  /// </summary>
  TNumericString = class(TInterfacedObject, INumeric<string>)
  private
    FValue: string;
  public
    /// <summary>
    /// Creates a new TNumericString instance with the specified value.
    /// </summary>
    /// <param name="AValue">The initial value of type string.</param>
    constructor Create(AValue: string);
    /// <summary>
    /// Concatenates the specified string to the current value.
    /// </summary>
    /// <param name="Value">The string to concatenate.</param>
    /// <returns>The concatenated string.</returns>
    function Add(const Value: string): string;
    /// <summary>
    /// Not supported for String; raises an exception.
    /// </summary>
    function Subtract(const Value: string): string;
    /// <summary>
    /// Repeats the current string the number of times specified by the length of the input string.
    /// </summary>
    /// <param name="Value">The string whose length determines the repetition count.</param>
    /// <returns>The repeated string.</returns>
    function Multiply(const Value: string): string;
    /// <summary>
    /// Not supported for String; raises an exception.
    /// </summary>
    function Divide(const Value: string): string;
    /// <summary>
    /// Not supported for String; raises an exception.
    /// </summary>
    function Power(const Value: string): string;
    /// <summary>
    /// Not supported for String; raises an exception.
    /// </summary>
    function Modulus(const Value: string): string;
    /// <summary>
    /// Returns the current string value.
    /// </summary>
    /// <returns>The current string value.</returns>
    function AsString: string;
    /// <summary>
    /// Retrieves the current string value.
    /// </summary>
    /// <returns>The current value of type string.</returns>
    function GetValue: string;
  end;

  /// <summary>
  /// Implements numeric operations for the Currency type.
  /// </summary>
  TNumericCurrency = class(TInterfacedObject, INumeric<Currency>)
  private
    FValue: Currency;
  public
    /// <summary>
    /// Creates a new TNumericCurrency instance with the specified value.
    /// </summary>
    /// <param name="AValue">The initial value of type Currency.</param>
    constructor Create(AValue: Currency);
    /// <summary>
    /// Adds the specified Currency value to the current value.
    /// </summary>
    /// <param name="Value">The Currency value to add.</param>
    /// <returns>The result of the addition.</returns>
    function Add(const Value: Currency): Currency;
    /// <summary>
    /// Subtracts the specified Currency value from the current value.
    /// </summary>
    /// <param name="Value">The Currency value to subtract.</param>
    /// <returns>The result of the subtraction.</returns>
    function Subtract(const Value: Currency): Currency;
    /// <summary>
    /// Multiplies the current value by the specified Currency value.
    /// </summary>
    /// <param name="Value">The Currency value to multiply by.</param>
    /// <returns>The result of the multiplication.</returns>
    function Multiply(const Value: Currency): Currency;
    /// <summary>
    /// Divides the current value by the specified Currency value.
    /// </summary>
    /// <param name="Value">The Currency value to divide by.</param>
    /// <returns>The result of the division.</returns>
    function Divide(const Value: Currency): Currency;
    /// <summary>
    /// Raises the current value to the power of the specified Currency value.
    /// </summary>
    /// <param name="Value">The exponent value as Currency.</param>
    /// <returns>The result of the power operation.</returns>
    function Power(const Value: Currency): Currency;
    /// <summary>
    /// Computes the modulus of the current value with the specified Currency value.
    /// </summary>
    /// <param name="Value">The Currency value to compute modulus with.</param>
    /// <returns>The modulus result.</returns>
    function Modulus(const Value: Currency): Currency;
    /// <summary>
    /// Returns the string representation of the current Currency value.
    /// </summary>
    /// <returns>The Currency value as a string.</returns>
    function AsString: string;
    /// <summary>
    /// Retrieves the current Currency value.
    /// </summary>
    /// <returns>The current value of type Currency.</returns>
    function GetValue: Currency;
  end;

implementation

{ TCurrying }

constructor TCurrying.Create(AValue: TValue);
begin
  FValue := AValue;
end;

function TCurrying.Op<T>(const Operation: TFunc<T, T, T>): TFunc<T, TCurrying>;
var
  LCurrentValue: TValue;
begin
  LCurrentValue := FValue;
  Result :=
    function(Value: T): TCurrying
    var
      LValue: T;
      LNumeric: INumeric<T>;
      LResult: T;
    begin
      if LCurrentValue.TypeInfo.Kind = tkInterface then
      begin
        LNumeric := LCurrentValue.AsInterface as INumeric<T>;
        if LNumeric <> nil then
          LValue := LNumeric.GetValue
        else
          raise EInvalidCast.Create('Invalid cast to INumeric<T>');
      end
      else
        LValue := LCurrentValue.AsType<T>;
      LResult := Operation(LValue, Value);
      Result := TCurrying.Create(TValue.From<T>(LResult));
    end;
end;

function TCurrying.Concat: TFunc<string, TCurrying>;
var
  LCurrentValue: TValue;
begin
  LCurrentValue := FValue;
  Result :=
    function(AValue: string): TCurrying
    var
      LNewValue: string;
    begin
      if LCurrentValue.TypeInfo.Kind = tkUString then
        LNewValue := LCurrentValue.AsType<string> + AValue
      else if LCurrentValue.TypeInfo.Kind in [tkInteger, tkFloat] then
        LNewValue := LCurrentValue.ToString + AValue
      else if LCurrentValue.TypeInfo.Kind = tkInterface then
        LNewValue := (LCurrentValue.AsInterface as INumeric<Double>).AsString + AValue
      else
        LNewValue := AValue;
      Result := TCurrying.Create(TValue.From<string>(LNewValue));
    end;
end;

function TCurrying.Value<T>: T;
begin
  Result := FValue.AsType<T>;
end;

function TCurrying.TValueValue: TValue;
begin
  Result := FValue;
end;

class function TCurrying.Compose<T, U, V>(F: TFunc<U, V>; G: TFunc<T, U>): TFunc<T, V>;
begin
  Result := function(X: T): V begin Result := F(G(X)); end;
end;

class function TCurrying.Partial<T, V>(F: TFunc<T, T, V>; FirstArg: T; FixFirst: Boolean): TFunc<T, V>;
begin
  if FixFirst then
    Result := function(Y: T): V begin Result := F(FirstArg, Y); end
  else
    Result := function(Y: T): V begin Result := F(Y, FirstArg); end;
end;

class function TCurrying.Memoize<T, U>(F: TFunc<T, U>): TFunc<T, U>;
var
  LCache: ICleanup;
  LFunc: TFunc<T, U>;
begin
  LCache := TMemoizedCache<T, U>.Create;
  LFunc := F;
  Result :=
    function(X: T): U
    begin
      Result := (LCache as TMemoizedCache<T, U>).GetOrAdd(X, LFunc);
    end;
end;

class function TCurrying.Pipe<T>(X: T): TPipeline<T>;
begin
  Result := TPipeline<T>.Create(X);
end;

class function TCurrying.Curry<T, U, V>(F: TFunc<T, U, V>): TFunc<T, TFunc<U, V>>;
begin
  Result := function(X: T): TFunc<U, V>
    begin
      Result := function(Y: U): V begin Result := F(X, Y); end;
    end;
end;

class function TCurrying.UnCurry<T, U, V>(F: TFunc<T, TFunc<U, V>>): TFunc<T, U, V>;
begin
  Result := function(X: T; Y: U): V begin Result := F(X)(Y); end;
end;

class function TCurrying.Map<T, U>(List: TList<T>; F: TFunc<T, U>): TList<U>;
var
  LItem: T;
begin
  Result := TList<U>.Create;
  try
    for LItem in List do
      Result.Add(F(LItem));
  except
    Result.Free;
    raise;
  end;
end;

class function TCurrying.Filter<T>(List: TList<T>; Predicate: TFunc<T, Boolean>): TList<T>;
var
  LItem: T;
begin
  Result := TList<T>.Create;
  try
    for LItem in List do
      if Predicate(LItem) then
        Result.Add(LItem);
  except
    Result.Free;
    raise;
  end;
end;

class function TCurrying.Fold<T, U>(List: TList<T>; Initial: U; F: TFunc<U, T, U>): U;
var
  LItem: T;
  LAccumulator: U;
begin
  LAccumulator := Initial;
  for LItem in List do
    LAccumulator := F(LAccumulator, LItem);
  Result := LAccumulator;
end;

class function TCurrying.ArrayToString<T>(const Arr: TArray<T>; const Separator: string): string;
var
  LFor: Integer;
  LStrings: TArray<string>;
  LValue: TValue;
begin
  SetLength(LStrings, Length(Arr));
  for LFor := 0 to Length(Arr) - 1 do
  begin
    LValue := TValue.From<T>(Arr[LFor]);
    if LValue.TypeInfo^.Kind = tkRecord then
    begin
      if LValue.TypeInfo = TypeInfo(TPair<Integer, string>) then
      begin
        with LValue.AsType<TPair<Integer, string>> do
          LStrings[LFor] := Format('%d, %s', [Key, Value]);
      end
      else
        LStrings[LFor] := LValue.ToString;
    end
    else
      LStrings[LFor] := LValue.ToString;
  end;
  Result := String.Join(Separator, LStrings);
end;

class function TCurrying.Take<T>(List: TList<T>; Count: Integer): TList<T>;
var
  LFor: Integer;
  LItem: T;
begin
  Result := TList<T>.Create;
  try
    if Count <= 0 then Exit;
    LFor := 0;
    for LItem in List do
    begin
      if LFor >= Count then Break;
      Result.Add(LItem);
      Inc(LFor);
    end;
  except
    Result.Free;
    raise;
  end;
end;

class function TCurrying.Drop<T>(List: TList<T>; Count: Integer): TList<T>;
var
  LFor: Integer;
  LItem: T;
begin
  Result := TList<T>.Create;
  try
    if Count < 0 then Count := 0;
    LFor := 0;
    for LItem in List do
    begin
      if LFor < Count then
      begin
        Inc(LFor);
        Continue;
      end;
      Result.Add(LItem);
    end;
  except
    Result.Free;
    raise;
  end;
end;

class function TCurrying.Zip<T1, T2>(List1: TList<T1>; List2: TList<T2>): TList<TPair<T1, T2>>;
var
  LFor: Integer;
  LMinCount: Integer;
begin
  Result := TList<TPair<T1, T2>>.Create;
  try
    LMinCount := Min(List1.Count, List2.Count);
    for LFor := 0 to LMinCount - 1 do
      Result.Add(TPair<T1, T2>.Create(List1[LFor], List2[LFor]));
  except
    Result.Free;
    raise;
  end;
end;

class function TCurrying.Any<T>(List: TList<T>; Predicate: TFunc<T, Boolean>): Boolean;
var
  LItem: T;
begin
  for LItem in List do
    if Predicate(LItem) then
      Exit(True);
  Result := False;
end;

class function TCurrying.All<T>(List: TList<T>; Predicate: TFunc<T, Boolean>): Boolean;
var
  LItem: T;
begin
  for LItem in List do
    if not Predicate(LItem) then
      Exit(False);
  Result := True;
end;

class function TCurrying.GroupBy<T, TKey>(List: TList<T>; KeySelector: TFunc<T, TKey>): TDictionary<TKey, TList<T>>;
var
  LItem: T;
  LKey: TKey;
  LGroup: TList<T>;
begin
  Result := TDictionary<TKey, TList<T>>.Create;
  try
    for LItem in List do
    begin
      LKey := KeySelector(LItem);
      if not Result.TryGetValue(LKey, LGroup) then
      begin
        LGroup := TList<T>.Create;
        Result.Add(LKey, LGroup);
      end;
      LGroup.Add(LItem);
    end;
  except
    Result.Free;
    raise;
  end;
end;

class function TCurrying.TakeWhile<T>(List: TList<T>; Predicate: TFunc<T, Boolean>): TList<T>;
var
  LItem: T;
begin
  Result := TList<T>.Create;
  try
    for LItem in List do
    begin
      if not Predicate(LItem) then
        Break;
      Result.Add(LItem);
    end;
  except
    Result.Free;
    raise;
  end;
end;

class function TCurrying.DropWhile<T>(List: TList<T>; Predicate: TFunc<T, Boolean>): TList<T>;
var
  LItem: T;
  LStarted: Boolean;
begin
  Result := TList<T>.Create;
  LStarted := False;
  try
    for LItem in List do
    begin
      if LStarted or not Predicate(LItem) then
      begin
        LStarted := True;
        Result.Add(LItem);
      end;
    end;
  except
    Result.Free;
    raise;
  end;
end;

class function TCurrying.Distinct<T>(List: TList<T>): TList<T>;
var
  LItem: T;
  LSeen: TDictionary<T, Boolean>;
begin
  Result := TList<T>.Create;
  LSeen := TDictionary<T, Boolean>.Create;
  try
    for LItem in List do
    begin
      if not LSeen.ContainsKey(LItem) then
      begin
        LSeen.Add(LItem, True);
        Result.Add(LItem);
      end;
    end;
  finally
    LSeen.Free;
  end;
end;

class function TCurrying.Reverse<T>(List: TList<T>): TList<T>;
var
  LFor: Integer;
begin
  Result := TList<T>.Create;
  try
    for LFor := List.Count - 1 downto 0 do
      Result.Add(List[LFor]);
  except
    Result.Free;
    raise;
  end;
end;

class function TCurrying.Sort<T>(List: TList<T>; Comparer: IComparer<T>): TList<T>;
var
  LArray: TArray<T>;
begin
  Result := TList<T>.Create;
  try
    LArray := List.ToArray;
    if Comparer = nil then
      Comparer := TComparer<T>.Default;
    TArray.Sort<T>(LArray, Comparer);
    Result.AddRange(LArray);
  except
    Result.Free;
    raise;
  end;
end;

class function TCurrying.Count<T>(List: TList<T>; Predicate: TFunc<T, Boolean>): Integer;
var
  LItem: T;
begin
  Result := 0;
  for LItem in List do
    if Predicate(LItem) then
      Inc(Result);
end;

class function TCurrying.First<T>(List: TList<T>; Predicate: TFunc<T, Boolean>): T;
var
  LItem: T;
begin
  for LItem in List do
    if Predicate(LItem) then
      Exit(LItem);
  raise EListError.Create('No element satisfies the predicate in First');
end;

class function TCurrying.Last<T>(List: TList<T>; Predicate: TFunc<T, Boolean>): T;
var
  LItem: T;
  LFound: Boolean;
begin
  LFound := False;
  Result := Default(T);
  for LItem in List do
    if Predicate(LItem) then
    begin
      Result := LItem;
      LFound := True;
    end;
  if not LFound then
    raise EListError.Create('No element satisfies the predicate in Last');
end;

class function TCurrying.ConcatLists<T>(List1, List2: TList<T>): TList<T>;
var
  LItem: T;
begin
  Result := TList<T>.Create;
  try
    for LItem in List1 do
      Result.Add(LItem);
    for LItem in List2 do
      Result.Add(LItem);
  except
    Result.Free;
    raise;
  end;
end;

class function TCurrying.Partition<T>(List: TList<T>; Predicate: TFunc<T, Boolean>): TPair<TList<T>, TList<T>>;
var
  LTrueList, LFalseList: TList<T>;
  LItem: T;
begin
  LTrueList := TList<T>.Create;
  LFalseList := TList<T>.Create;
  try
    for LItem in List do
      if Predicate(LItem) then
        LTrueList.Add(LItem)
      else
        LFalseList.Add(LItem);
    Result := TPair<TList<T>, TList<T>>.Create(LTrueList, LFalseList);
  except
    LTrueList.Free;
    LFalseList.Free;
    raise;
  end;
end;

class function TCurrying.Flatten<T>(List: TList<TList<T>>): TList<T>;
var
  LSubList: TList<T>;
  LItem: T;
begin
  Result := TList<T>.Create;
  try
    for LSubList in List do
      for LItem in LSubList do
        Result.Add(LItem);
  except
    Result.Free;
    raise;
  end;
end;

class function TCurrying.SequenceEqual<T>(List1, List2: TList<T>): Boolean;
var
  LFor: Integer;
begin
  if List1.Count <> List2.Count then
    Exit(False);
  for LFor := 0 to List1.Count - 1 do
    if not TEqualityComparer<T>.Default.Equals(List1[LFor], List2[LFor]) then
      Exit(False);
  Result := True;
end;

{ TPipeline<T> }

constructor TPipeline<T>.Create(AValue: T);
begin
  FValue := AValue;
end;

function TPipeline<T>.Apply<U>(F: TFunc<T, U>): TPipeline<U>;
begin
  Result := TPipeline<U>.Create(F(FValue));
end;

function TPipeline<T>.Map<U>(F: TFunc<T, U>): TPipeline<U>;
begin
  Result := TPipeline<U>.Create(F(FValue));
end;

function TPipeline<T>.Thn<U>(F: TFunc<T, U>): TPipeline<U>;
begin
  Result := TPipeline<U>.Create(F(FValue));
end;

function TPipeline<T>.Value: T;
begin
  Result := FValue;
end;

{ TMemoizedCache<T, U> }

constructor TMemoizedCache<T, U>.Create;
begin
  FCache := TDictionary<T, U>.Create;
  FLock := TCriticalSection.Create;
end;

destructor TMemoizedCache<T, U>.Destroy;
begin
  FCache.Free;
  FLock.Free;
  inherited;
end;

procedure TMemoizedCache<T, U>.Cleanup;
begin
  FLock.Enter;
  try
    FCache.Clear;
  finally
    FLock.Leave;
  end;
end;

function TMemoizedCache<T, U>.GetOrAdd(Key: T; Func: TFunc<T, U>): U;
begin
  FLock.Enter;
  try
    if not FCache.TryGetValue(Key, Result) then
    begin
      Result := Func(Key);
      FCache.Add(Key, Result);
    end;
  finally
    FLock.Leave;
  end;
end;

{ TNumericByte }

constructor TNumericByte.Create(AValue: Byte);
begin
  FValue := AValue;
end;

function TNumericByte.Add(const Value: Byte): Byte;
begin
  Result := FValue + Value;
end;

function TNumericByte.Subtract(const Value: Byte): Byte;
begin
  Result := FValue - Value;
end;

function TNumericByte.Multiply(const Value: Byte): Byte;
begin
  Result := FValue * Value;
end;

function TNumericByte.Divide(const Value: Byte): Byte;
begin
  if Value = 0 then
    raise EDivByZero.Create('Division by zero is not allowed');
  Result := FValue div Value;
end;

function TNumericByte.Power(const Value: Byte): Byte;
var
  LBase, LExponent, LResult: Byte;
begin
  LBase := FValue;
  LExponent := Value;
  LResult := 1;
  while LExponent > 0 do
  begin
    LResult := LResult * LBase;
    Dec(LExponent);
  end;
  Result := LResult;
end;

function TNumericByte.Modulus(const Value: Byte): Byte;
begin
  if Value = 0 then
    raise EDivByZero.Create('Modulus by zero is not allowed');
  Result := FValue mod Value;
end;

function TNumericByte.AsString: string;
begin
  Result := IntToStr(FValue);
end;

function TNumericByte.GetValue: Byte;
begin
  Result := FValue;
end;

{ TNumericShortInt }

constructor TNumericShortInt.Create(AValue: ShortInt);
begin
  FValue := AValue;
end;

function TNumericShortInt.Add(const Value: ShortInt): ShortInt;
begin
  Result := FValue + Value;
end;

function TNumericShortInt.Subtract(const Value: ShortInt): ShortInt;
begin
  Result := FValue - Value;
end;

function TNumericShortInt.Multiply(const Value: ShortInt): ShortInt;
begin
  Result := FValue * Value;
end;

function TNumericShortInt.Divide(const Value: ShortInt): ShortInt;
begin
  if Value = 0 then
    raise EDivByZero.Create('Division by zero is not allowed');
  Result := FValue div Value;
end;

function TNumericShortInt.Power(const Value: ShortInt): ShortInt;
var
  LBase, LExponent, LResult: ShortInt;
begin
  LBase := FValue;
  LExponent := Value;
  LResult := 1;
  while LExponent > 0 do
  begin
    LResult := LResult * LBase;
    Dec(LExponent);
  end;
  Result := LResult;
end;

function TNumericShortInt.Modulus(const Value: ShortInt): ShortInt;
begin
  if Value = 0 then
    raise EDivByZero.Create('Modulus by zero is not allowed');
  Result := FValue mod Value;
end;

function TNumericShortInt.AsString: string;
begin
  Result := IntToStr(FValue);
end;

function TNumericShortInt.GetValue: ShortInt;
begin
  Result := FValue;
end;

{ TNumericWord }

constructor TNumericWord.Create(AValue: Word);
begin
  FValue := AValue;
end;

function TNumericWord.Add(const Value: Word): Word;
begin
  Result := FValue + Value;
end;

function TNumericWord.Subtract(const Value: Word): Word;
begin
  Result := FValue - Value;
end;

function TNumericWord.Multiply(const Value: Word): Word;
begin
  Result := FValue * Value;
end;

function TNumericWord.Divide(const Value: Word): Word;
begin
  if Value = 0 then
    raise EDivByZero.Create('Division by zero is not allowed');
  Result := FValue div Value;
end;

function TNumericWord.Power(const Value: Word): Word;
var
  LBase, LExponent, LResult: Word;
begin
  LBase := FValue;
  LExponent := Value;
  LResult := 1;
  while LExponent > 0 do
  begin
    LResult := LResult * LBase;
    Dec(LExponent);
  end;
  Result := LResult;
end;

function TNumericWord.Modulus(const Value: Word): Word;
begin
  if Value = 0 then
    raise EDivByZero.Create('Modulus by zero is not allowed');
  Result := FValue mod Value;
end;

function TNumericWord.AsString: string;
begin
  Result := IntToStr(FValue);
end;

function TNumericWord.GetValue: Word;
begin
  Result := FValue;
end;

{ TNumericSmallInt }

constructor TNumericSmallInt.Create(AValue: SmallInt);
begin
  FValue := AValue;
end;

function TNumericSmallInt.Add(const Value: SmallInt): SmallInt;
begin
  Result := FValue + Value;
end;

function TNumericSmallInt.Subtract(const Value: SmallInt): SmallInt;
begin
  Result := FValue - Value;
end;

function TNumericSmallInt.Multiply(const Value: SmallInt): SmallInt;
begin
  Result := FValue * Value;
end;

function TNumericSmallInt.Divide(const Value: SmallInt): SmallInt;
begin
  if Value = 0 then
    raise EDivByZero.Create('Division by zero is not allowed');
  Result := FValue div Value;
end;

function TNumericSmallInt.Power(const Value: SmallInt): SmallInt;
var
  LBase, LExponent, LResult: SmallInt;
begin
  LBase := FValue;
  LExponent := Value;
  LResult := 1;
  while LExponent > 0 do
  begin
    LResult := LResult * LBase;
    Dec(LExponent);
  end;
  Result := LResult;
end;

function TNumericSmallInt.Modulus(const Value: SmallInt): SmallInt;
begin
  if Value = 0 then
    raise EDivByZero.Create('Modulus by zero is not allowed');
  Result := FValue mod Value;
end;

function TNumericSmallInt.AsString: string;
begin
  Result := IntToStr(FValue);
end;

function TNumericSmallInt.GetValue: SmallInt;
begin
  Result := FValue;
end;

{ TNumericLongWord }

constructor TNumericLongWord.Create(AValue: LongWord);
begin
  FValue := AValue;
end;

function TNumericLongWord.Add(const Value: LongWord): LongWord;
begin
  Result := FValue + Value;
end;

function TNumericLongWord.Subtract(const Value: LongWord): LongWord;
begin
  Result := FValue - Value;
end;

function TNumericLongWord.Multiply(const Value: LongWord): LongWord;
begin
  Result := FValue * Value;
end;

function TNumericLongWord.Divide(const Value: LongWord): LongWord;
begin
  if Value = 0 then
    raise EDivByZero.Create('Division by zero is not allowed');
  Result := FValue div Value;
end;

function TNumericLongWord.Power(const Value: LongWord): LongWord;
var
  LBase, LExponent, LResult: LongWord;
begin
  LBase := FValue;
  LExponent := Value;
  LResult := 1;
  while LExponent > 0 do
  begin
    LResult := LResult * LBase;
    Dec(LExponent);
  end;
  Result := LResult;
end;

function TNumericLongWord.Modulus(const Value: LongWord): LongWord;
begin
  if Value = 0 then
    raise EDivByZero.Create('Modulus by zero is not allowed');
  Result := FValue mod Value;
end;

function TNumericLongWord.AsString: string;
begin
  Result := IntToStr(FValue);
end;

function TNumericLongWord.GetValue: LongWord;
begin
  Result := FValue;
end;

{ TNumericInt64 }

constructor TNumericInt64.Create(AValue: Int64);
begin
  FValue := AValue;
end;

function TNumericInt64.Add(const Value: Int64): Int64;
begin
  Result := FValue + Value;
end;

function TNumericInt64.Subtract(const Value: Int64): Int64;
begin
  Result := FValue - Value;
end;

function TNumericInt64.Multiply(const Value: Int64): Int64;
begin
  Result := FValue * Value;
end;

function TNumericInt64.Divide(const Value: Int64): Int64;
begin
  if Value = 0 then
    raise EDivByZero.Create('Division by zero is not allowed');
  Result := FValue div Value;
end;

function TNumericInt64.Power(const Value: Int64): Int64;
var
  LBase, LExponent, LResult: Int64;
begin
  LBase := FValue;
  LExponent := Value;
  LResult := 1;
  while LExponent > 0 do
  begin
    LResult := LResult * LBase;
    Dec(LExponent);
  end;
  Result := LResult;
end;

function TNumericInt64.Modulus(const Value: Int64): Int64;
begin
  if Value = 0 then
    raise EDivByZero.Create('Modulus by zero is not allowed');
  Result := FValue mod Value;
end;

function TNumericInt64.AsString: string;
begin
  Result := IntToStr(FValue);
end;

function TNumericInt64.GetValue: Int64;
begin
  Result := FValue;
end;

{ TNumericSingle }

constructor TNumericSingle.Create(AValue: Single);
begin
  FValue := AValue;
end;

function TNumericSingle.Add(const Value: Single): Single;
begin
  Result := FValue + Value;
end;

function TNumericSingle.Subtract(const Value: Single): Single;
begin
  Result := FValue - Value;
end;

function TNumericSingle.Multiply(const Value: Single): Single;
begin
  Result := FValue * Value;
end;

function TNumericSingle.Divide(const Value: Single): Single;
begin
  if Value = 0 then
    raise EDivByZero.Create('Division by zero is not allowed');
  Result := FValue / Value;
end;

function TNumericSingle.Power(const Value: Single): Single;
begin
  Result := Math.Power(FValue, Value);
end;

function TNumericSingle.Modulus(const Value: Single): Single;
begin
  if Value = 0 then
    raise EDivByZero.Create('Modulus by zero is not allowed');
  Result := Trunc(FValue) mod Trunc(Value);
end;

function TNumericSingle.AsString: string;
begin
  Result := FloatToStr(FValue);
end;

function TNumericSingle.GetValue: Single;
begin
  Result := FValue;
end;

{ TNumericDouble }

constructor TNumericDouble.Create(AValue: Double);
begin
  FValue := AValue;
end;

function TNumericDouble.Add(const Value: Double): Double;
begin
  Result := FValue + Value;
end;

function TNumericDouble.Subtract(const Value: Double): Double;
begin
  Result := FValue - Value;
end;

function TNumericDouble.Multiply(const Value: Double): Double;
begin
  Result := FValue * Value;
end;

function TNumericDouble.Divide(const Value: Double): Double;
begin
  if Value = 0 then
    raise EDivByZero.Create('Division by zero is not allowed');
  Result := FValue / Value;
end;

function TNumericDouble.Power(const Value: Double): Double;
begin
  Result := Math.Power(FValue, Value);
end;

function TNumericDouble.Modulus(const Value: Double): Double;
begin
  if Value = 0 then
    raise EDivByZero.Create('Modulus by zero is not allowed');
  Result := Trunc(FValue) mod Trunc(Value);
end;

function TNumericDouble.AsString: string;
begin
  Result := FloatToStr(FValue);
end;

function TNumericDouble.GetValue: Double;
begin
  Result := FValue;
end;

{ TNumericInteger }

constructor TNumericInteger.Create(AValue: Integer);
begin
  FValue := AValue;
end;

function TNumericInteger.Add(const Value: Integer): Integer;
begin
  Result := FValue + Value;
end;

function TNumericInteger.Subtract(const Value: Integer): Integer;
begin
  Result := FValue - Value;
end;

function TNumericInteger.Multiply(const Value: Integer): Integer;
begin
  Result := FValue * Value;
end;

function TNumericInteger.Divide(const Value: Integer): Integer;
begin
  if Value = 0 then
    raise EDivByZero.Create('Division by zero is not allowed');
  Result := FValue div Value;
end;

function TNumericInteger.Power(const Value: Integer): Integer;
var
  LBase, LExponent, LResult: Integer;
begin
  LBase := FValue;
  LExponent := Value;
  LResult := 1;
  while LExponent > 0 do
  begin
    LResult := LResult * LBase;
    Dec(LExponent);
  end;
  Result := LResult;
end;

function TNumericInteger.Modulus(const Value: Integer): Integer;
begin
  if Value = 0 then
    raise EDivByZero.Create('Modulus by zero is not allowed');
  Result := FValue mod Value;
end;

function TNumericInteger.AsString: string;
begin
  Result := IntToStr(FValue);
end;

function TNumericInteger.GetValue: Integer;
begin
  Result := FValue;
end;

{ TNumericExtended }

constructor TNumericExtended.Create(AValue: Extended);
begin
  FValue := AValue;
end;

function TNumericExtended.Add(const Value: Extended): Extended;
begin
  Result := FValue + Value;
end;

function TNumericExtended.Subtract(const Value: Extended): Extended;
begin
  Result := FValue - Value;
end;

function TNumericExtended.Multiply(const Value: Extended): Extended;
begin
  Result := FValue * Value;
end;

function TNumericExtended.Divide(const Value: Extended): Extended;
begin
  if Value = 0 then
    raise EDivByZero.Create('Division by zero is not allowed');
  Result := FValue / Value;
end;

function TNumericExtended.Power(const Value: Extended): Extended;
begin
  Result := Math.Power(FValue, Value);
end;

function TNumericExtended.Modulus(const Value: Extended): Extended;
begin
  if Value = 0 then
    raise EDivByZero.Create('Modulus by zero is not allowed');
  Result := Trunc(FValue) mod Trunc(Value);
end;

function TNumericExtended.AsString: string;
begin
  Result := FloatToStr(FValue);
end;

function TNumericExtended.GetValue: Extended;
begin
  Result := FValue;
end;

{ TNumericBoolean }

constructor TNumericBoolean.Create(AValue: Boolean);
begin
  FValue := AValue;
end;

function TNumericBoolean.Add(const Value: Boolean): Boolean;
begin
  Result := FValue or Value;
end;

function TNumericBoolean.Subtract(const Value: Boolean): Boolean;
begin
  raise EInvalidOperation.Create('Subtraction is not supported for Boolean');
end;

function TNumericBoolean.Multiply(const Value: Boolean): Boolean;
begin
  Result := FValue and Value;
end;

function TNumericBoolean.Divide(const Value: Boolean): Boolean;
begin
  raise EInvalidOperation.Create('Division is not supported for Boolean');
end;

function TNumericBoolean.Power(const Value: Boolean): Boolean;
begin
  raise EInvalidOperation.Create('Power is not supported for Boolean');
end;

function TNumericBoolean.Modulus(const Value: Boolean): Boolean;
begin
  raise EInvalidOperation.Create('Modulus is not supported for Boolean');
end;

function TNumericBoolean.AsString: string;
begin
  Result := BoolToStr(FValue, True);
end;

function TNumericBoolean.GetValue: Boolean;
begin
  Result := FValue;
end;

{ TNumericDateTime }

constructor TNumericDateTime.Create(AValue: TDateTime);
begin
  FValue := AValue;
end;

function TNumericDateTime.Add(const Value: TDateTime): TDateTime;
begin
  Result := FValue + Value;
end;

function TNumericDateTime.Subtract(const Value: TDateTime): TDateTime;
begin
  Result := FValue - Value;
end;

function TNumericDateTime.Multiply(const Value: TDateTime): TDateTime;
begin
  raise EInvalidOperation.Create('Multiplication is not supported for TDateTime');
end;

function TNumericDateTime.Divide(const Value: TDateTime): TDateTime;
begin
  raise EInvalidOperation.Create('Division is not supported for TDateTime');
end;

function TNumericDateTime.Power(const Value: TDateTime): TDateTime;
begin
  raise EInvalidOperation.Create('Power is not supported for TDateTime');
end;

function TNumericDateTime.Modulus(const Value: TDateTime): TDateTime;
begin
  raise EInvalidOperation.Create('Modulus is not supported for TDateTime');
end;

function TNumericDateTime.AsString: string;
begin
  Result := DateTimeToStr(FValue);
end;

function TNumericDateTime.GetValue: TDateTime;
begin
  Result := FValue;
end;

{ TNumericString }

constructor TNumericString.Create(AValue: string);
begin
  FValue := AValue;
end;

function TNumericString.Add(const Value: string): string;
begin
  Result := FValue + Value;
end;

function TNumericString.Subtract(const Value: string): string;
begin
  raise EInvalidOperation.Create('Subtraction is not supported for String');
end;

function TNumericString.Multiply(const Value: string): string;
var
  LCount, LFor: Integer;
  LResult: string;
begin
  LCount := Length(Value);
  LResult := '';
  for LFor := 1 to LCount do
    LResult := LResult + FValue;
  Result := LResult;
end;

function TNumericString.Divide(const Value: string): string;
begin
  raise EInvalidOperation.Create('Division is not supported for String');
end;

function TNumericString.Power(const Value: string): string;
begin
  raise EInvalidOperation.Create('Power is not supported for String');
end;

function TNumericString.Modulus(const Value: string): string;
begin
  raise EInvalidOperation.Create('Modulus is not supported for String');
end;

function TNumericString.AsString: string;
begin
  Result := FValue;
end;

function TNumericString.GetValue: string;
begin
  Result := FValue;
end;

{ TNumericCurrency }

constructor TNumericCurrency.Create(AValue: Currency);
begin
  FValue := AValue;
end;

function TNumericCurrency.Add(const Value: Currency): Currency;
begin
  Result := FValue + Value;
end;

function TNumericCurrency.Subtract(const Value: Currency): Currency;
begin
  Result := FValue - Value;
end;

function TNumericCurrency.Multiply(const Value: Currency): Currency;
begin
  Result := FValue * Value;
end;

function TNumericCurrency.Divide(const Value: Currency): Currency;
begin
  if Value = 0 then
    raise EDivByZero.Create('Division by zero is not allowed');
  Result := FValue / Value;
end;

function TNumericCurrency.Power(const Value: Currency): Currency;
begin
  Result := Math.Power(FValue, Value);
end;

function TNumericCurrency.Modulus(const Value: Currency): Currency;
begin
  if Value = 0 then
    raise EDivByZero.Create('Modulus by zero is not allowed');
  Result := Trunc(FValue) mod Trunc(Value);
end;

function TNumericCurrency.AsString: string;
begin
  Result := CurrToStr(FValue);
end;

function TNumericCurrency.GetValue: Currency;
begin
  Result := FValue;
end;

end.
