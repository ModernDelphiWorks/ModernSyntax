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

unit ModernSyntax.ResultPair;

interface

uses
  Rtti,
  TypInfo,
  Classes,
  SysUtils;

type
  TResultType = (rtNone, rtSuccess, rtFailure);

  EFailureException<F> = class(Exception)
  public
    constructor Create(const AValue: F);
  end;
  ESuccessException<S> = class(Exception)
  public
    constructor Create(const AValue: S);
  end;
  ETypeIncompatibility = class(Exception)
  public
    constructor Create(const AMessage: string = '');
  end;

  TResultValue = record
    Success: TValue;
    Failure: TValue;
    constructor Create(const ASuccess: TValue; const AFailure: TValue);
  end;

  TResultPairValue<T> = record
  private
    FValue: T;
    FHasValue: Boolean;
  public
    constructor Create(AValue: T);
    class function CreateNil: TResultPairValue<T>; static;
    function GetValue: T;
    function HasValue: Boolean;
  end;

  TResultPair<S, F> = record
  strict private
    type
      TMapFunc<Return> = reference to function(const ASelf: TResultPair<S, F>): Return;
      TFuncOk = reference to function(const ASuccess: S): TResultPair<S, F>;
      TFuncFail = reference to function(const AFailure: F): TResultPair<S, F>;
      TFuncExec = reference to function: TResultPair<S, F>;
  strict private
    FSuccess: TResultPairValue<S>;
    FFailure: TResultPairValue<F>;
    FSuccessFuncs: TArray<TFuncOk>;
    FFailureFuncs: TArray<TFuncFail>;
    FResultType: TResultType;
  strict private
    procedure _DestroySuccess;
    procedure _DestroyFailure;

    /// <summary>
    ///   Sets the success value for the TResultPair.
    /// </summary>
    /// <remarks>
    ///   Use this procedure to set the success value for the current TResultPair instance.
    ///   The success value represents the successful result of an operation in the Railway Pattern.
    /// </remarks>
    /// <param name="ASuccess">
    ///   The success value of type S to set.
    /// </param>
    procedure _SetSuccessValue(const ASuccess: S); //inline;

    /// <summary>
    ///   Sets the failure value for the TResultPair.
    /// </summary>
    /// <remarks>
    ///   Use this procedure to set the failure value for the current TResultPair instance.
    ///   The failure value represents an error or failure in the Railway Pattern.
    /// </remarks>
    /// <param name="AFailure">
    ///   The failure value of type F to set.
    /// </param>
    procedure _SetFailureValue(const AFailure: F); inline;

    /// <summary>
    ///   Returns a TResultPair with the success value set.
    /// </summary>
    /// <remarks>
    ///   Use this function to create and return a new TResultPair instance with the success
    ///   value set to the value specified in <paramref name="ASuccess"/>.
    /// </remarks>
    /// <param name="ASuccess">
    ///   The success value of type S to set in the returned TResultPair.
    /// </param>
    /// <returns>
    ///   A new TResultPair instance with the success value set to <paramref name="ASuccess"/>.
    /// </returns>
    function _ReturnSuccess: TResultPair<S, F>; inline;

    /// <summary>
    ///   Returns a TResultPair with the failure value set.
    /// </summary>
    /// <remarks>
    ///   Use this function to create and return a new TResultPair instance with the failure
    ///   value set to the value specified in <paramref name="AFailure"/>.
    /// </remarks>
    /// <param name="AFailure">
    ///   The failure value of type F to set in the returned TResultPair.
    /// </param>
    /// <returns>
    ///   A new TResultPair instance with the failure value set to <paramref name="AFailure"/>.
    /// </returns>
    function _ReturnFailure: TResultPair<S, F>; inline;

    constructor Create(const AResultType: TResultType);
  public
    class operator Implicit(const V: TResultPair<S, F>): TResultPairValue<S>;
    class operator Implicit(const V: TResultPairValue<S>): TResultPair<S, F>;
    class operator Implicit(const V: TResultPair<S, F>): TResultPairValue<F>;
    class operator Implicit(const V: TResultPairValue<F>): TResultPair<S, F>;
    class operator Equal(const Left, Right: TResultPair<S, F>): Boolean;
    class operator NotEqual(const Left, Right: TResultPair<S, F>): Boolean;

    /// <summary>
    ///   Creates and returns a new TResultPair<S, F> instance, initiating a Railway Pattern workflow.
    /// </summary>
    /// <returns>
    ///   A new TResultPair<S, F> instance.
    /// </returns>
    class function New: TResultPair<S, F>; static; inline;

    /// <summary>
    ///   Releases any resources associated with the current TResultPair instance.
    /// </summary>
    /// <remarks>
    ///   Use this procedure to release any resources, if applicable, and perform necessary cleanup
    ///   for the current TResultPair instance. It's recommended to call this method when you are
    ///   finished using the TResultPair object to ensure proper resource management.
    ///
    ///   IDEMPOTENT: calling Dispose twice on the same instance frees at most once. The value
    ///   slot is cleared before the object is freed, so a second call finds nothing to free and
    ///   returns without touching released memory. It is also safe on a pair whose S/F slot was
    ///   never set and on a slot holding nil.
    ///
    ///   IDEMPOTENCE IS PER INSTANCE, NOT PER OBJECT. TResultPair is an unmanaged record, so
    ///   assigning it (or passing it by value, or going through one of the Implicit operators)
    ///   produces an INDEPENDENT copy that holds the SAME object pointer. Clearing the slot
    ///   clears it in one copy only. Two copies with one Dispose each therefore free the same
    ///   object TWICE:
    ///
    ///     LA := TResultPair&lt;TObject, TObject&gt;.New.Success(TObject.Create);
    ///     LB := LA;      // independent copy, same pointer
    ///     LA.Dispose;    // frees the object, clears LA's slot only
    ///     LB.Dispose;    // DOUBLE FREE - LB's slot still points at the released object
    ///
    ///   The guarantee is "Dispose twice through the SAME variable is harmless", which is what
    ///   protects a cleanup path that runs more than once. It is NOT "the object can only ever
    ///   be freed once". Exactly one copy must own the value; decide which one and dispose only
    ///   that one.
    ///
    ///   STILL MANUAL BY DESIGN: TResultPair is a plain (unmanaged) record and deliberately has
    ///   NO class operator Finalize. Going out of scope frees nothing; ownership of any class
    ///   value stays with the caller. See the note above the implementation of _DestroyFailure
    ///   for why adding Finalize would be a double-free, both inside this unit and in existing
    ///   consumers.
    /// </remarks>
    procedure Dispose; inline;

    /// <summary>
    ///   Creates a new instance of TResultPair representing a success result.
    /// </summary>
    /// <param name="ASuccess">
    ///   The success value to be stored in the instance.
    /// </param>
    /// <returns>
    ///   A TResultPair instance with the given success value.
    /// </returns>
    function Success(const ASuccess: S): TResultPair<S, F>; //inline;

    /// <summary>
    ///   Creates a new instance of TResultPair representing a failure result.
    /// </summary>
    /// <param name="AFailure">
    ///   The failure value to be stored in the instance.
    /// </param>
    /// <returns>
    ///   A TResultPair instance with the given failure value.
    /// </returns>
    function Failure(const AFailure: F): TResultPair<S, F>; //inline;

    /// <summary>
    ///   Executes a success procedure if the current instance represents a success result,
    ///   otherwise, executes a failure procedure.
    /// </summary>
    /// <param name="AFailureProc">
    ///   The procedure to be executed in case of failure.
    /// </param>
    /// <param name="ASuccessProc">
    ///   The procedure to be executed in case of success.
    /// </param>
    /// <returns>
    ///   The same TResultPair instance for chaining.
    /// </returns>
//    function TryException(const ASuccessProc: TProc<S>;
//      const AFailureProc: TProc<F>): TResultPair<S, F>; inline;

    /// <summary>
    ///   Performs a "fold" over the result, applying the success function if it is a success result
    ///   or the failure function if it is a failure result.
    /// </summary>
    /// <typeparam name="R">
    ///   The type of return resulting from the application of the success or failure functions.
    /// </typeparam>
    /// <param name="AFailureFunc">
    ///   The function to be applied in case of failure.
    /// </param>
    /// <param name="ASuccessFunc">
    ///   The function to be applied in case of success.
    /// </param>
    /// <returns>
    ///   The result of the application of the function corresponding to the type of result.
    /// </returns>
    function Reduce<R>(const AFunc: TFunc<S, F, R>): R; inline;

    /// <summary>
    ///   Evaluates the result and executes the success function if it is a success result,
    ///   or executes the failure function if it is a failure result.
    /// </summary>
    /// <typeparam name="R">
    ///   The type of return resulting from the execution of the success or failure function.
    /// </typeparam>
    /// <param name="ASuccessFunc">
    ///   The function to be executed in case of success.
    /// </param>
    /// <param name="AFailureFunc">
    ///   The function to be executed in case of failure.
    /// </param>
    /// <returns>
    ///   The result of the execution of the function corresponding to the type of result.
    /// </returns>
    function When<R>(const ASuccessFunc: TFunc<S, R>;
      const AFailureFunc: TFunc<F, R>): R; overload; inline;
    function When(const ASuccessProc: TProc<S>;
      const AFailureProc: TProc<F>): TResultPair<S, F>; overload; inline;
    /// <summary>
    ///   Applies a mapping function to the success part of the result, producing a new result
    ///   containing the mapped value, keeping the failure part unchanged.
    /// </summary>
    /// <typeparam name="R">
    ///   The type of the value resulting after the mapping function is applied.
    /// </typeparam>
    /// <param name="ASuccessFunc">
    ///   The mapping function to be applied to the success part of the result.
    /// </param>
    /// <returns>
    ///   A new result with the success part mapped according to the specified function
    ///   and the failure part kept intact.
    /// </returns>
    function Map<R>(const ASuccessFunc: TFunc<S, R>): TResultPair<S, F>; overload; inline;

    /// <summary>
    ///   Applies a mapping function to the failure part of the result, producing a new result
    ///   containing the mapped failure part, keeping the success part unchanged.
    /// </summary>
    /// <typeparam name="R">
    ///   The type of the value resulting after the mapping function is applied to the failure part.
    /// </typeparam>
    /// <param name="AFailureFunc">
    ///   The mapping function to be applied to the failure part of the result.
    /// </param>
    /// <returns>
    ///   A new result with the failure part mapped according to the specified function
    ///   and the success part kept intact.
    /// </returns>
    function Map<R>(const AFailureFunc: TFunc<F, R>): TResultPair<S, F>; overload; inline;

    /// <summary>
    ///   Applies a mapping function that operates on the success part of the result, producing
    ///   a new result that can contain a mapped success part or be converted to a failure,
    ///   depending on the result of the mapping function.
    /// </summary>
    /// <typeparam name="R">
    ///   The type of the value resulting after the mapping function is applied to the success part.
    /// </typeparam>
    /// <param name="ASuccessFunc">
    ///   The mapping function to be applied to the success part of the result.
    /// </param>
    /// <returns>
    ///   A new result with the success part mapped or converted to failure based on the result
    ///   of the mapping function applied.
    /// </returns>
    function FlatMap(const ASuccessFunc: TFunc<S, TResultValue>): TResultPair<S, F>; overload; //inline;

    /// <summary>
    ///   Applies a mapping function that operates on the failure part of the result, producing
    ///   a new result that can contain a mapped failure part or be converted to success,
    ///   depending on the result of the mapping function.
    /// </summary>
    /// <typeparam name="R">
    ///   The type of the value resulting after the mapping function is applied to the failure part.
    /// </typeparam>
    /// <param name="AFailureFunc">
    ///   The mapping function to be applied to the failure part of the result.
    /// </param>
    /// <returns>
    ///   A new result with the failure part mapped or converted to success based on the result
    ///   of the mapping function applied.
    /// </returns>
    function FlatMap(const AFailureFunc: TFunc<F, TResultValue>): TResultPair<S, F>; overload; //inline;

    /// <summary>
    ///   Creates an instance of a success result containing the specified value.
    /// </summary>
    /// <param name="ASuccess">
    ///   The value to be placed in the success part of the result.
    /// </param>
    /// <returns>
    ///   An instance of a result containing the success part filled with the specified value
    ///   and the failure part empty.
    /// </returns>
    function Pure(const ASuccess: S): TResultPair<S, F>; overload; inline;

    /// <summary>
    ///   Creates an instance of a failure result containing the specified error.
    /// </summary>
    /// <param name="AFailure">
    ///   The error to be placed in the failure part of the result.
    /// </param>
    /// <returns>
    ///   An instance of a result containing the failure part filled with the specified error
    ///   and the success part empty.
    /// </returns>
    function Pure(const AFailure: F): TResultPair<S, F>; overload; inline;

    /// <summary>
    ///   Swaps the success and failure parts of the result.
    /// </summary>
    /// <returns>
    ///   A new instance of result with the success and failure parts swapped.
    /// </returns>
    function Swap: TResultPair<F, S>; inline;

    /// <summary>
    ///   Attempts to recover the failure, applying a conversion function <paramref name="AFailureFunc"/>
    ///   to obtain a new value of type <typeparamref name="N"/> and keeping the success part
    ///   unchanged.
    /// </summary>
    /// <typeparam name="N">
    ///   The new type for the recovered failure part.
    /// </typeparam>
    /// <param name="AFailureFunc">
    ///   The conversion function to be applied to the current failure part to obtain a value of <typeparamref name="N"/>.
    /// </param>
    /// <returns>
    ///   A new instance of result with the recovered failure part or the success part.
    /// </returns>
    function Recover<R>(const AFailureFunc: TFunc<F, R>): TResultPair<R, S>; inline;

    /// <summary>
    ///   Gets the success value, applying a function <paramref name="ASuccessFunc"/> if
    ///   the result is a success (<paramref name="rtSuccess"/>), or returning a default value
    ///   if it is a failure (<paramref name="rtFailure"/>).
    /// </summary>
    /// <param name="ASuccessFunc">
    ///   The function to be applied to the success value.
    /// </param>
    /// <returns>
    ///   The success value, or the default value of the success part if it is a failure.
    /// </returns>
    function SuccessOrElse(const ASuccessFunc: TFunc<S, S>): S; inline;

    /// <summary>
    ///   Gets the success value, returning it if the result is a success
    ///   (<paramref name="rtSuccess"/>), or throwing the exception contained in the failure part
    ///   (<paramref name="rtFailure"/>).
    /// </summary>
    /// <returns>
    ///   The success value, or throws the exception contained in the failure part.
    /// </returns>
    /// <exception cref="EFailureValue">
    ///   Exception contained in the failure part, if the result is a failure.
    /// </exception>
    function SuccessOrException: S; inline;

    /// <summary>
    ///   Gets the success value, returning it if the result is a success
    ///   (<paramref name="rtSuccess"/>), or a default value if it is a failure result
    ///   (<paramref name="rtFailure"/>).
    /// </summary>
    /// <returns>
    ///   The success value if the result is a success, otherwise, a value
    ///   provided as a default.
    /// </returns>
    function SuccessOrDefault: S; overload; inline;

    /// <summary>
    ///   Gets the success value, returning it if the result is a success
    ///   (<paramref name="rtSuccess"/>), or a default value provided as a parameter if
    ///   it is a failure result (<paramref name="rtFailure"/>).
    /// </summary>
    /// <param name="ADefault">
    ///   The default value to be returned if the result is a failure.
    /// </param>
    /// <returns>
    ///   The success value if the result is a success, otherwise, the value
    ///   provided as a default.
    /// </returns>
    function SuccessOrDefault(const ADefault: S): S; overload; inline;

    /// <summary>
    ///   Gets the failure value, throwing it as an exception if the result is a failure
    ///   (<paramref name="rtFailure"/>).
    /// </summary>
    /// <exception cref="EFailureValueException">
    ///   Thrown when the result is a failure, containing the failure value.
    /// </exception>
    /// <returns>
    ///   The failure value, if the result is a failure.
    /// </returns>
    function FailureOrElse(const AFailureFunc: TFunc<F, F>): F; inline;

    /// <summary>
    ///   Gets the failure value, throwing it as an exception if the result is a failure
    ///   (<paramref name="rtFailure"/>).
    /// </summary>
    /// <exception cref="EFailureValueException">
    ///   Thrown when the result is a failure, containing the failure value.
    /// </exception>
    /// <returns>
    ///   The failure value, if the result is a failure.
    /// </returns>
    function FailureOrException: F; inline;

    /// <summary>
    ///   Gets the failure value or the default value of type <typeparamref name="F"/>,
    ///   if the result is a failure (<paramref name="rtFailure"/>).
    /// </summary>
    /// <returns>
    ///   The failure value, if the result is a failure, otherwise, a default value of <typeparamref name="F"/>.
    /// </returns>
    function FailureOrDefault: F; overload; inline;

    /// <summary>
    ///   Gets the failure value or a default value provided, if the result is a failure
    ///   (<paramref name="rtFailure"/>).
    /// </summary>
    /// <param name="ADefault">
    ///   The default value to be returned if the result is a failure.
    /// </param>
    /// <returns>
    ///   The failure value, if the result is a failure, otherwise, the default value provided.
    /// </returns>
    function FailureOrDefault(const ADefault: F): F; overload; inline;

    /// <summary>
    ///   Determines whether the result is a success (<paramref name="rtSuccess"/>).
    /// </summary>
    /// <returns>
    ///   <c>True</c> if the result is a success, otherwise <c>False</c>.
    /// </returns>
    function isSuccess: Boolean; inline;

    /// <summary>
    ///   Determines whether the result is a failure (<paramref name="rtFailure"/>).
    /// </summary>
    /// <returns>
    ///   <c>True</c> if the result is a failure, otherwise <c>False</c>.
    /// </returns>
    function isFailure: Boolean; inline;

    /// <summary>
    ///   Gets the success value contained in the result, throwing an exception if it is a failure result.
    /// </summary>
    /// <returns>
    ///   The success value, if the result is a success.
    /// </returns>
    /// <exception cref="EInvalidOperation">
    ///   Thrown if the result is a failure.
    /// </exception>
    function ValueSuccess: S; inline;

    /// <summary>
    ///   Gets the failure value contained in the result, throwing an exception if it is a success result.
    /// </summary>
    /// <returns>
    ///   The failure value, if the result is a failure.
    /// </returns>
    /// <exception cref="EInvalidOperation">
    ///   Thrown if the result is a success.
    /// </exception>
    function ValueFailure: F; inline;

    /// <summary>
    ///   Executes a custom function specified by AFunc. The result of this function determines whether
    ///   the workflow continues down the success or failure path.
    /// </summary>
    /// <param name="AFunc">
    ///   A custom function that receives the current TResultPair<S, F> instance and returns a new
    ///   TResultPair<S, F>.
    /// </param>
    /// <returns>
    ///   The TResultPair<S, F> instance after executing the custom function.
    /// </returns>
    function Exec(const AFunc: TFuncExec): TResultPair<S, F>; inline;

    /// <summary>
    ///   Marks the current step as successful and provides a value ASuccess to carry forward in the
    ///   success path.
    /// </summary>
    /// <param name="ASuccess">
    ///   The value representing the successful outcome of the current step.
    /// </param>
    /// <returns>
    ///   The TResultPair<S, F> instance after marking the step as successful.
    /// </returns>
    function Ok(const ASuccessProc: TProc<S>): TResultPair<S, F>; inline;

    /// <summary>
    ///   Marks the current step as a failure and provides a value AFailure to carry forward in the
    ///   failure path.
    /// </summary>
    /// <param name="AFailure">
    ///   The value representing the failure outcome of the current step.
    /// </param>
    /// <returns>
    ///   The TResultPair<S, F> instance after marking the step as a failure.
    /// </returns>
    function Fail(const AFailureProc: TProc<F>): TResultPair<S, F>; inline;

    /// <summary>
    ///   Specifies a custom function AFunc to execute if the previous step was successful. It continues
    ///   the success path.
    /// </summary>
    /// <param name="AFunc">
    ///   A custom function that processes the successful outcome and returns a new TResultPair<S, F>.
    /// </param>
    /// <returns>
    ///   The TResultPair<S, F> instance after executing the custom function.
    /// </returns>
    function ThenOf(const AFunc: TFuncOk): TResultPair<S, F>; inline;

    /// <summary>
    ///   Specifies a custom function AFunc to execute if the previous step resulted in failure. It
    ///   continues the failure path.
    /// </summary>
    /// <param name="AFunc">
    ///   A custom function that processes the failure outcome and returns a new TResultPair<S, F>.
    /// </param>
    /// <returns>
    ///   The TResultPair<S, F> instance after executing the custom function.
    /// </returns>
    function ExceptOf(const AFunc: TFuncFail): TResultPair<S, F>; inline;

    /// <summary>
    ///   Returns the current TResultPair<S, F> instance, allowing you to retrieve the final result of
    ///   the Railway Pattern workflow.
    /// </summary>
    /// <returns>
    ///   The current TResultPair<S, F> instance.
    /// </returns>
    function Return: TResultPair<S, F>; inline;
  end;

implementation

{ TResultPairBr<S, F> }

procedure TResultPair<S, F>._DestroySuccess;
var
  LTypeInfo: PTypeInfo;
  LObject: TObject;
begin
  LTypeInfo := TypeInfo(S);
  // `if @FSuccess = nil` (the old guard) can never be True - it is the address of a field of
  // Self, not a pointer to the value. The guards that actually matter are these three.
  if LTypeInfo = nil then          // some type arguments carry no RTTI
    Exit;
  if LTypeInfo.Kind <> tkClass then // only class values are owned/freed here
    Exit;
  // Never set (or already released): nothing to free. Without this, GetValue would raise
  // 'Value is nil.' whenever S is a class and the pair carries a failure.
  if not FSuccess.HasValue then
    Exit;
  LObject := TValue.From<S>(FSuccess.GetValue).AsObject;
  // Clear the slot BEFORE freeing. This is what makes Dispose idempotent: a second call (or
  // a Dispose after some other code already released through this same instance) sees an
  // empty slot and returns without touching released memory.
  FSuccess := Default(TResultPairValue<S>);
  LObject.Free;
end;

procedure TResultPair<S, F>._SetFailureValue(const AFailure: F);
begin
  FFailure := TResultPairValue<F>.Create(AFailure);
  FResultType := TResultType.rtFailure;
end;

procedure TResultPair<S, F>._SetSuccessValue(const ASuccess: S);
begin
  FSuccess := TResultPairValue<S>.Create(ASuccess);
  FResultType := TResultType.rtSuccess;
end;

constructor TResultPair<S, F>.Create(const AResultType: TResultType);
begin
  FResultType := AResultType;
end;

procedure TResultPair<S, F>.Dispose;
begin
  _DestroySuccess;
  _DestroyFailure;
end;

// WHY THERE IS NO `class operator Finalize` HERE
// ----------------------------------------------
// The obvious "structural" fix for the leak of a class-typed failure value would be to give
// TResultPair a Finalize operator so that leaving scope releases it. It cannot be done in
// this shape, and it would be strictly worse than the leak:
//
//  1) The record is copied on almost every call. Success/Failure/Pure/Ok/Fail/When/Map/
//     ThenOf/ExceptOf/Return all do `Result := Self`, and Reduce/_ReturnSuccess/_ReturnFailure
//     keep local copies. Every one of those temporaries holds the SAME object pointer, so a
//     Finalize that frees would double-free inside this very unit, before any consumer code
//     is reached. Making it correct would require a full ownership model (class operator
//     Assign + a heap-allocated refcount), which changes copy semantics and cost for everyone.
//
//  2) Consumers already free manually. In the ERP that drives this framework there are ~9
//     call sites that read the failure and free it, plus ~1128 `procedure(E: Exception)`
//     callbacks whose body is `E.Free`. Turning the record managed converts every one of them
//     into a double free - heap corruption instead of a leak.
//
//  3) A consumer test asserts the current semantics on purpose ("leaving scope does NOT
//     release, which is why the consume-helper exists"). Finalize would both fail that test
//     and crash it.
//
//  4) Custom managed records (Initialize/Finalize/Assign) require Delphi 10.4+, and the
//     supported floor is Delphi XE - README.md:3 (badge) and README.md:33 (compatibility
//     matrix). Adding them would drop every compiler from XE to 10.3 that builds this unit
//     today, which is the whole lower half of the declared matrix.
//     (Correcting the earlier wording of this item: it cited ModernSyntax.inc and "Delphi 2010
//     upwards" and an FPC/Lazarus target, and all three were wrong. This unit does NOT include
//     ModernSyntax.inc - the only {$I} in the project is at ModernSyntax.Objects.pas:16 - and
//     no unit anywhere in the repository consumes a single symbol that file defines, so the
//     .inc does not set the floor; the README does. FPC/Lazarus is not a build target either:
//     the .inc's Lazarus block is dead code, guarded by {$IFDEF FCP} - a typo for FPC - at
//     ModernSyntax.inc:256. The CONCLUSION is unaffected: 10.4+ is still above the XE floor,
//     so Finalize still cannot be used.)
//
// So ownership stays explicit: Dispose is the single, MANUAL release point - and it is now
// idempotent, so calling it twice (or after someone else already released through the same
// instance) is harmless.
procedure TResultPair<S, F>._DestroyFailure;
var
  LTypeInfo: PTypeInfo;
  LObject: TObject;
begin
  LTypeInfo := TypeInfo(F);
  if LTypeInfo = nil then
    Exit;
  if LTypeInfo.Kind <> tkClass then
    Exit;
  if not FFailure.HasValue then
    Exit;
  LObject := TValue.From<F>(FFailure.GetValue).AsObject;
  // Clear before freeing - see _DestroySuccess.
  FFailure := Default(TResultPairValue<F>);
  LObject.Free;
end;

function TResultPair<S, F>.Fail(const AFailureProc: TProc<F>): TResultPair<S, F>;
begin
  Result := Self;
  if not Assigned(AFailureProc) then
    Exit;
  case FResultType of
    TResultType.rtFailure: AFailureProc(FFailure.GetValue);
  end;
end;

function TResultPair<S, F>.Failure(const AFailure: F): TResultPair<S, F>;
begin
  _SetFailureValue(AFailure);
  Result := Self;
end;

function TResultPair<S, F>.Return: TResultPair<S, F>;
begin
  if Self.FResultType in [TResultType.rtSuccess] then
    Result := _ReturnSuccess
  else
  if Self.FResultType in [TResultType.rtFailure] then
    Result := _ReturnFailure;
end;

// KNOWN BUG - see https://github.com/ModernDelphiWorks/ModernSyntax/issues/8
// -------------------------------------------------------------------------
// Two defects live in this routine (and identically in _ReturnSuccess below). They are NOT
// fixed here on purpose: the correct fix is an ownership refactor of the whole Return chain,
// which changes what Return gives back, so it belongs in its own PR with its own tests.
//
//  1) THE TRANSFORMATION IS DISCARDED. `Result := Self` happens BEFORE the loop, while
//     _SetSuccessValue/_SetFailureValue write into Self. Result is a separate copy taken
//     beforehand, so the value handed back is the PRE-transformation one. TResultPair is a
//     record, so Self is the caller's own variable and the mutation does land there - which
//     means `x := x.Return` and `x.Return` disagree about the outcome.
//
//  2) USE-AFTER-FREE. _SetFailureValue(LResult.ValueFailure) copies the POINTER out of
//     LResult; the `finally` then does LResult.Dispose, which frees the object behind that
//     pointer. Self.FFailure is left holding released memory. Same shape for the success
//     branch.
//
// CHANGE OF BEHAVIOUR INTRODUCED BY PR #7 (for TResultPair<class, class> only):
//   before #7 - LResult.Dispose entered _DestroySuccess, called FSuccess.GetValue on a slot
//               that had never been set and raised 'Value is nil.'. The exception escaped the
//               `finally`, _DestroyFailure never ran and the object was never freed. An
//               ACCIDENTAL SHIELD: loud, and no dangling pointer.
//   after  #7 - _DestroySuccess returns early on `not FSuccess.HasValue`, _DestroyFailure runs
//               and frees the object. Verified by address comparison: `dangling? True`, and
//               SILENT.
// For a non-class S nothing changed (_DestroySuccess bailed out at the tkClass check both
// before and after), so there the dangling pointer is equally old. #7 is still a net win, but
// for <class, class> it traded a noisy abort for a quiet use-after-free, and the record has to
// say so.
function TResultPair<S, F>._ReturnFailure: TResultPair<S, F>;
var
  LFor: Integer;
  LResult: TResultPair<S, F>;
begin
  Result := Self;
  for LFor := Low(FFailureFuncs) to High(FFailureFuncs) do
  begin
    LResult := FFailureFuncs[LFor](FFailure.GetValue);
    try
      if LResult.isSuccess then
        _SetSuccessValue(LResult.ValueSuccess)
      else
      if LResult.isFailure then
        _SetFailureValue(LResult.ValueFailure);
    finally
      LResult.Dispose;
    end;
  end;
end;

// KNOWN BUG - see https://github.com/ModernDelphiWorks/ModernSyntax/issues/8
// -------------------------------------------------------------------------
// Same two defects documented above _ReturnFailure, plus one of its own:
//
//  1) THE TRANSFORMATION IS DISCARDED. `Result := Self` below is taken before the loop, and
//     _SetSuccessValue/_SetFailureValue write into Self, so the returned pair carries the
//     pre-transformation state.
//
//  2) USE-AFTER-FREE. The value is adopted with _SetSuccessValue(LResult.ValueSuccess) and the
//     `finally` immediately disposes LResult, freeing the object the adopted pointer refers to.
//     Post-#7 this is silent for <class, class>; pre-#7 it aborted with 'Value is nil.'. Full
//     account in the note above _ReturnFailure.
//
//  3) THE CHAIN DOES NOT COMPOSE. Each step is fed from `Result.FSuccess.GetValue` - the stale
//     copy - instead of the accumulating Self, so with two or more success functions every step
//     sees the ORIGINAL value rather than its predecessor's output.
//
// Not fixed here for the same reason: the fix is an ownership refactor of the Return chain
// (issue #8), which changes Return's observable result.
function TResultPair<S, F>._ReturnSuccess: TResultPair<S, F>;
var
  LFor: Integer;
  LResult: TResultPair<S, F>;
begin
  Result := Self;
  for LFor := Low(FSuccessFuncs) to High(FSuccessFuncs) do
  begin
    LResult := FSuccessFuncs[LFor](Result.FSuccess.GetValue);
    try
      if LResult.isSuccess then
        _SetSuccessValue(LResult.ValueSuccess)
      else
      if LResult.isFailure then
        _SetFailureValue(LResult.ValueFailure);
    finally
      LResult.Dispose;
    end;
  end;
end;

function TResultPair<S, F>.Success(const ASuccess: S): TResultPair<S, F>;
begin
  _SetSuccessValue(ASuccess);
  Result := Self;
end;

function TResultPair<S, F>.isFailure: Boolean;
begin
  Result := FResultType = TResultType.rtFailure;
end;

function TResultPair<S, F>.isSuccess: Boolean;
begin
  Result := FResultType = TResultType.rtSuccess;
end;

function TResultPair<S, F>.Map<R>(
  const AFailureFunc: TFunc<F, R>): TResultPair<S, F>;
var
  LResult: TResultValue;
begin
  Result := Self;
  if not Assigned(AFailureFunc) then
    Exit;
  case FResultType of
    TResultType.rtFailure:
    begin
      LResult.Failure := TValue.From<R>(AFailureFunc(FFailure.GetValue));
      _SetFailureValue(LResult.Failure.AsType<F>);
    end;
  end;
end;

function TResultPair<S, F>.Map<R>(const ASuccessFunc: TFunc<S, R>): TResultPair<S, F>;
var
  LResult: TResultValue;
begin
  Result := Self;
  if not Assigned(ASuccessFunc) then
    Exit;
  case FResultType of
    TResultType.rtSuccess:
    begin
      LResult.Success := TValue.From<R>(ASuccessFunc(FSuccess.GetValue));
      _SetSuccessValue(LResult.Success.AsType<S>);
    end;
  end;
end;

function TResultPair<S, F>.When<R>(const ASuccessFunc: TFunc<S, R>;
  const AFailureFunc: TFunc<F, R>): R;
begin
  Result := Default(R);
  if (not Assigned(ASuccessFunc)) and (not Assigned(AFailureFunc)) then
    Exit;
  case FResultType of
    TResultType.rtSuccess: Result := ASuccessFunc(FSuccess.GetValue);
    TResultType.rtFailure: Result := AFailureFunc(FFailure.GetValue);
  end;
end;

function TResultPair<S, F>.When(const ASuccessProc: TProc<S>;
  const AFailureProc: TProc<F>): TResultPair<S, F>;
begin
  Result := Self;
  if (not Assigned(ASuccessProc)) and (not Assigned(AFailureProc)) then
    Exit;
  case FResultType of
    TResultType.rtSuccess: ASuccessProc(FSuccess.GetValue);
    TResultType.rtFailure: AFailureProc(FFailure.GetValue);
  end;
end;

function TResultPair<S, F>.Reduce<R>(const AFunc: TFunc<S, F, R>): R;
begin
  Result := Default(R);
  if not Assigned(AFunc) then
    Exit;
  case FResultType of
    TResultType.rtSuccess: Result := AFunc(FSuccess.GetValue, Default(F));
    TResultType.rtFailure: Result := AFunc(Default(S), FFailure.GetValue);
  end;
end;

function TResultPair<S, F>.ThenOf(const AFunc: TFuncOk): TResultPair<S, F>;
begin
  Result := Self;
  if (FResultType in [TResultType.rtSuccess]) and Assigned(AFunc) then
  begin
    SetLength(Result.FSuccessFuncs, Length(FSuccessFuncs) + 1);
    Result.FSuccessFuncs[Length(Result.FSuccessFuncs) - 1] := AFunc;
  end;
end;

//function TResultPair<S, F>.TryException(const ASuccessProc: TProc<S>;
//  const AFailureProc: TProc<F>): TResultPair<S, F>;
//begin
//  Result := Self;
//  if (not Assigned(ASuccessProc)) and (not Assigned(AFailureProc)) then
//    Exit;
//  case FResultType of
//    TResultType.rtSuccess: ASuccessProc(FSuccess.GetValue);
//    TResultType.rtFailure: AFailureProc(FFailure.GetValue);
//  end;
//end;

function TResultPair<S, F>.SuccessOrException: S;
begin
  if FResultType = TResultType.rtFailure then
    raise EFailureException<F>.Create(FFailure.GetValue);
  Result := FSuccess.GetValue;
end;

class operator TResultPair<S, F>.Implicit(
  const V: TResultPairValue<F>): TResultPair<S, F>;
begin
  Result.FFailure := V;
end;

class operator TResultPair<S, F>.Implicit(
  const V: TResultPair<S, F>): TResultPairValue<F>;
begin
  Result := V.FFailure;
end;

class operator TResultPair<S, F>.Implicit(
  const V: TResultPairValue<S>): TResultPair<S, F>;
begin
  Result.FSuccess := V;
end;

class operator TResultPair<S, F>.Implicit(
  const V: TResultPair<S, F>): TResultPairValue<S>;
begin
  Result := V.FSuccess;
end;

function TResultPair<S, F>.ValueFailure: F;
begin
  Result := FFailure.GetValue;
end;

function TResultPair<S, F>.ValueSuccess: S;
begin
  Result := FSuccess.GetValue;
end;

class function TResultPair<S, F>.New: TResultPair<S, F>;
begin
  Result := TResultPair<S, F>.Create(TResultType.rtNone);
end;

class operator TResultPair<S, F>.NotEqual(const Left,
  Right: TResultPair<S, F>): Boolean;
begin
  Result := not (Left = Right);
end;

function TResultPair<S, F>.Ok(const ASuccessProc: TProc<S>): TResultPair<S, F>;
begin
  Result := Self;
  if not Assigned(ASuccessProc) then
    Exit;
  case FResultType of
    TResultType.rtSuccess: ASuccessProc(FSuccess.GetValue);
  end;
end;

function TResultPair<S, F>.FlatMap(
  const ASuccessFunc: TFunc<S, TResultValue>): TResultPair<S, F>;
var
  LResult: TResultValue;
begin
  Result := Self;
  if not Assigned(ASuccessFunc) then
    Exit;
  LResult := ASuccessFunc(FSuccess.GetValue);
  if not LResult.Success.IsEmpty then
    _SetSuccessValue(LResult.Success.AsType<S>);

  if not LResult.Failure.IsEmpty then
    _SetFailureValue(LResult.Failure.AsType<F>);
end;

function TResultPair<S, F>.FlatMap(
  const AFailureFunc: TFunc<F, TResultValue>): TResultPair<S, F>;
var
  LResult: TResultValue;
begin
  Result := Self;
  if not Assigned(AFailureFunc) then
    Exit;
  LResult := AFailureFunc(FFailure.GetValue);
  if not LResult.Success.IsEmpty then
    _SetSuccessValue(LResult.Success.AsType<S>);

  if not LResult.Failure.IsEmpty then
    _SetFailureValue(LResult.Failure.AsType<F>);
end;

function TResultPair<S, F>.Pure(const ASuccess: S): TResultPair<S, F>;
begin
  _SetSuccessValue(ASuccess);
  Result := Self;
end;

function TResultPair<S, F>.Pure(const AFailure: F): TResultPair<S, F>;
begin
  _SetFailureValue(AFailure);
  Result := Self;
end;

function TResultPair<S, F>.SuccessOrElse(const ASuccessFunc: TFunc<S, S>): S;
begin
  case FResultType of
    TResultType.rtSuccess: Result := FSuccess.GetValue;
    TResultType.rtFailure: Result := ASuccessFunc(FSuccess.GetValue);
  else
    Result := Default(S);
  end;
end;

function TResultPair<S, F>.SuccessOrDefault(const ADefault: S): S;
begin
  case FResultType of
    TResultType.rtSuccess: Result := FSuccess.GetValue;
    TResultType.rtFailure: Result := ADefault;
  else
    Result := Default(S);
  end;
end;

function TResultPair<S, F>.SuccessOrDefault: S;
begin
  case FResultType of
    TResultType.rtSuccess: Result := FSuccess.GetValue;
    TResultType.rtFailure: Result := Default(S);
  else
    Result := Default(S);
  end;
end;

class operator TResultPair<S, F>.Equal(const Left,
  Right: TResultPair<S, F>): Boolean;
begin
  Result := (Left = Right);
end;

function TResultPair<S, F>.ExceptOf(const AFunc: TFuncFail): TResultPair<S, F>;
begin
  Result := Self;
  if (FResultType in [TResultType.rtFailure]) and Assigned(AFunc) then
  begin
    SetLength(Result.FFailureFuncs, Length(FFailureFuncs) + 1);
    Result.FFailureFuncs[Length(Result.FFailureFuncs) - 1] := AFunc;
  end;
end;

function TResultPair<S, F>.Exec(const AFunc: TFuncExec): TResultPair<S, F>;
var
  LResult: TResultPair<S, F>;
begin
  if not Assigned(AFunc) then
    Exit;
  LResult := AFunc();
  if LResult.isSuccess then
    Result.Success(LResult.FSuccess.GetValue)
  else
  if LResult.isFailure then
    Result.Failure(LResult.FFailure.GetValue);
end;

function TResultPair<S, F>.FailureOrDefault: F;
begin
  case FResultType of
    TResultType.rtSuccess: Result := Default(F);
    TResultType.rtFailure: Result := FFailure.GetValue;
  else
    Result := Default(F);
  end;
end;

function TResultPair<S, F>.FailureOrDefault(const ADefault: F): F;
begin
  case FResultType of
    TResultType.rtSuccess: Result := ADefault;
    TResultType.rtFailure: Result := FFailure.GetValue;
  else
    Result := Default(F);
  end;
end;

function TResultPair<S, F>.FailureOrElse(const AFailureFunc: TFunc<F, F>): F;
begin
  case FResultType of
    TResultType.rtSuccess: Result := AFailureFunc(FFailure.GetValue);
    TResultType.rtFailure: Result := FFailure.GetValue;
  else
    Result := Default(F);
  end;
end;

function TResultPair<S, F>.FailureOrException: F;
begin
  if FResultType = TResultType.rtSuccess then
    raise ESuccessException<F>.Create(FFailure.GetValue);
  Result := FFailure.GetValue;
end;

function TResultPair<S, F>.Swap: TResultPair<F, S>;
var
  LResult: TResultPair<F, S>;
begin
  LResult := TResultPair<F, S>.New;
  try
    case FResultType of
      TResultType.rtSuccess:
      begin
        LResult.FFailure := TResultPairValue<S>.Create(FSuccess.GetValue);
        LResult.FResultType := TResultType.rtFailure;
      end;
      TResultType.rtFailure:
      begin
        LResult.FSuccess := TResultPairValue<F>.Create(FFailure.GetValue);
        LResult.FResultType := TResultType.rtSuccess;
      end;
    end;
  except
    on E: Exception do
      raise ETypeIncompatibility.Create('[Success/Failure]');
  end;
  Result := LResult;
end;

function TResultPair<S, F>.Recover<R>(const AFailureFunc: TFunc<F, R>): TResultPair<R, S>;
var
  LCast: TValue;
  LResult: TResultPair<R, S>;
begin
  LResult := TResultPair<R, S>.New;
  if not Assigned(AFailureFunc) then
    Exit;
  case FResultType of
    TResultType.rtFailure:
    begin
      LCast := TValue.From<R>(AFailureFunc(FFailure.GetValue));
      LResult.FSuccess := TResultPairValue<R>.Create(LCast.AsType<R>);
      LResult.FResultType := TResultType.rtSuccess;
    end;
  end;
  Result := LResult;
end;

{ TResultPairValue<T> }

constructor TResultPairValue<T>.Create(AValue: T);
begin
  FValue := AValue;
  FHasValue := True;
end;

class function TResultPairValue<T>.CreateNil: TResultPairValue<T>;
begin
  Result.FHasValue := False;
end;

function TResultPairValue<T>.GetValue: T;
begin
  if not FHasValue then
    raise Exception.Create('Value is nil.');
  Result := FValue;
end;

function TResultPairValue<T>.HasValue: Boolean;
begin
  Result := FHasValue;
end;

{ EFailureException<S> }

constructor EFailureException<F>.Create(const AValue: F);
begin
  inherited CreateFmt('A generic exception occurred with value %s', [TValue.From<F>(AValue).AsString]);
end;

{ ESuccessException<S> }

constructor ESuccessException<S>.Create(const AValue: S);
begin
  inherited CreateFmt('A generic exception occurred with value %s', [TValue.From<S>(AValue).AsString]);
end;

{ ETypeIncompatibility }

constructor ETypeIncompatibility.Create(const AMessage: string);
begin
  inherited CreateFmt('Type incompatibility: %s', [AMessage]);
end;

{ TResult<S, F> }

constructor TResultValue.Create(const ASuccess: TValue; const AFailure:TValue);
begin
  Success := ASuccess;
  Failure := AFailure;
end;

end.


