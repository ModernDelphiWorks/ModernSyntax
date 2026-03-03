unit UTestMS.Muttle;

interface

uses
  DUnitX.TestFramework,
  ModernSyntax.Objects,
  System.SysUtils,
  System.Rtti,
  System.Variants;

type
  TTestObject = class(TObject)
  private
    FProperties: Integer;
    class var FInstanceCount: Integer;
    function _GetProperty: Integer;
    procedure _SetProperty1(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    class function InstanceCount: Integer; static;
    property Property1: Integer read _GetProperty write _SetProperty1;
  end;

  TValueType = record
    Field1: Integer;
  end;

  [TestFixture]
  TMutableRefTests = class
  private
    type
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure TestWithProvidedInstance;
//    [Test]
    procedure TestWithNil;
//    [Test]
    procedure TestValueTypeMutable;
//    [Test]
    procedure TestLazyInitialization;
//    [Test]
    procedure TestMemoryManagement;
  end;

implementation

{ TTestObject }

constructor TTestObject.Create;
begin
  inherited Create;
  Inc(FInstanceCount);
end;

destructor TTestObject.Destroy;
begin
  Dec(FInstanceCount);
  inherited Destroy;
end;

class function TTestObject.InstanceCount: Integer;
begin
  Result := FInstanceCount;
end;

procedure TTestObject._SetProperty1(const Value: Integer);
begin
   FProperties := Value;
end;

function TTestObject._GetProperty: Integer;
begin
  Result := FProperties;
end;

{ TMutableRefTests }

procedure TMutableRefTests.Setup;
begin
end;

procedure TMutableRefTests.TearDown;
begin
  Assert.IsTrue(TTestObject.InstanceCount = 0);
end;

procedure TMutableRefTests.TestWithProvidedInstance;
var
  Ref: TMutableRef<TTestObject>;
begin
  Ref := TTestObject.Create;
  Ref.AsRef.Property1 := 10; // Tentei tornar imutable, mas interceptar Sets em private não foi possível
  Assert.IsTrue(Ref.AsRef is TTestObject);
  Assert.IsTrue(not Ref.IsNull);
  Assert.IsTrue(Ref.IsLoaded);
  Assert.IsTrue(not Ref.IsMutable);
end;

procedure TMutableRefTests.TestWithNil;
var
  Ref: TMutableRef<TTestObject>;
  Obj: TTestObject;
begin
  Assert.IsTrue(Ref.IsNull);
  Obj := Ref.AsRef;
  Assert.IsTrue(not Ref.IsNull);
  Assert.IsTrue(Ref.IsLoaded);
  Assert.IsTrue(Assigned(Obj));
end;

procedure TMutableRefTests.TestValueTypeMutable;
var
  ValRef: TMutableRef<TValueType>;
begin
  ValRef := TMutableRef<TValueType>.Create(Default(TValueType), True);
  Assert.IsTrue(not ValRef.IsNull);
  Assert.IsTrue(ValRef.IsLoaded);

  ValRef.Scoped(
    function(AVal: TValueType): TValue
    begin
      AVal.Field1 := 42;
      Result := TValue.From<TValueType>(AVal);
    end);
  Assert.IsTrue(ValRef.AsRef.Field1 = 42);
end;

procedure TMutableRefTests.TestLazyInitialization;
var
  Ref: TMutableRef<TTestObject>;
  Obj1, Obj2: TTestObject;
begin
  Ref := default(TTestObject);
  Assert.IsTrue(Ref.IsNull); // Before accessing AsRef

  Obj1 := Ref.AsRef;
  Assert.IsTrue(not Ref.IsNull);
  Assert.IsTrue(Ref.IsLoaded);
  Assert.IsTrue(Assigned(Obj1));

  Obj2 := Ref.AsRef;
  Assert.IsTrue(Obj1 = Obj2); // Same instance
end;

procedure TMutableRefTests.TestMemoryManagement;
var
  Ref: TMutableRef<TTestObject>;
begin
  Assert.IsTrue(TTestObject.InstanceCount = 0);
  Ref := TTestObject.Create;
  Ref.AsRef; // Create the object
  Assert.IsTrue(TTestObject.InstanceCount = 1);

  // Let Ref go out of scope
  // The object should be destroyed when Ref is destroyed
end;

initialization
  TDUnitX.RegisterTestFixture(TMutableRefTests);

end.
