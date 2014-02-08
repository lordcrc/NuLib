unit NuLib.Functional.Detail.EnumerableWrapper;

interface

uses
  NuLib.RuntimeInvocation,
  NuLib.Functional.Common,
  NuLib.Functional.Detail, System.Rtti;

type
  TEnumeratorWrapper<T> = class(TInterfacedObject, IEnumeratorImpl<T>)
  private
    FEnumeratorInstance: pointer;
    FEnumeratorLifetime: IInterface;
    FMoveNextMethod: NuLib.RuntimeInvocation.RIFunc<boolean>;
    FGetCurrentProperty: NuLib.RuntimeInvocation.RIFunc<T>;
  public
    constructor Create(const EnumeratorInstance: pointer;
      const EnumeratorLifetime: IInterface;
      const MoveNextMethod: NuLib.RuntimeInvocation.RIFunc<boolean>;
      const GetCurrentProperty: NuLib.RuntimeInvocation.RIFunc<T>);

    function GetCurrent: T;
    function MoveNext: Boolean;
  end;

  TEnumerableWrapper<E; T> = class(TInterfacedObject, IEnumerableImpl<T>)
  private
    FEnumerableObj: E;
    FHasCount: boolean;
    FGetEnumeratorInstanceMethod: NuLib.RuntimeInvocation.RIFunc<TObject>;
    FGetEnumeratorInterfaceMethod: NuLib.RuntimeInvocation.RIFunc<IInterface>;
    FMoveNextMethod: NuLib.RuntimeInvocation.RIFunc<boolean>;
    FGetCurrentProperty: NuLib.RuntimeInvocation.RIFunc<T>;
    FGetCountProperty: NuLib.RuntimeInvocation.RIFunc<Integer>;

    procedure Wrap;
  public
    constructor Create(const EnumerableObj: E);

    function HasCount: boolean;
    function GetCount: NativeInt;

    function GetEnumerator: IEnumeratorImpl<T>;
  end;

  TDynArrayWrapper<T> = class
  private
    FDynArray: pointer;
    FCurrentIndex: NativeInt;
    FCount: Integer;

  public
    constructor Create(const DynArray: pointer);

    function MoveNext(): boolean;
    function GetCurrent: T;
    function GetCount: Integer;

    class function GetDynArrayCount(const DynArray: pointer): Integer;
  end;

implementation

uses
  System.SysUtils, System.TypInfo;

{ TEnumeratorWrapper<T> }

constructor TEnumeratorWrapper<T>.Create(const EnumeratorInstance: pointer;
  const EnumeratorLifetime: IInterface;
  const MoveNextMethod: NuLib.RuntimeInvocation.RIFunc<boolean>;
  const GetCurrentProperty: NuLib.RuntimeInvocation.RIFunc<T>);
begin
  inherited Create;

  FEnumeratorInstance := EnumeratorInstance;
  FEnumeratorLifetime := EnumeratorLifetime;
  FMoveNextMethod := MoveNextMethod;
  FGetCurrentProperty := GetCurrentProperty;
end;

function TEnumeratorWrapper<T>.GetCurrent: T;
begin
  result := FGetCurrentProperty(FEnumeratorInstance);
end;

function TEnumeratorWrapper<T>.MoveNext: Boolean;
begin
  result := FMoveNextMethod(FEnumeratorInstance);
end;

{ TEnumerableWrapper<E, T> }

constructor TEnumerableWrapper<E, T>.Create(const EnumerableObj: E);
begin
  inherited Create;

  FEnumerableObj := EnumerableObj;
  Wrap;
end;

function TEnumerableWrapper<E, T>.GetCount: NativeInt;
begin
  result := FGetCountProperty(FEnumerableObj);
end;

function TEnumerableWrapper<E, T>.GetEnumerator: IEnumeratorImpl<T>;
var
  enumeratorInstance: TObject;
  enumeratorInterface: IInterface;
  enumerator: pointer;
begin
  enumerator := nil;
  enumeratorInterface := nil;
  if Assigned(FGetEnumeratorInstanceMethod) then
  begin
    enumeratorInstance := FGetEnumeratorInstanceMethod(FEnumerableObj);
    enumerator := pointer(enumeratorInstance);
  end;
  if Assigned(FGetEnumeratorInterfaceMethod) then
  begin
    enumeratorInterface := FGetEnumeratorInterfaceMethod(FEnumerableObj);
    enumerator := pointer(enumeratorInterface);
  end;

  Assert(Assigned(enumerator), 'Logic error in TEnumerableWrapper.GetEnumerator');

  result := TEnumeratorWrapper<T>.Create(enumerator, enumeratorInterface, FMoveNextMethod, FGetCurrentProperty);
end;

function TEnumerableWrapper<E, T>.HasCount: boolean;
begin
  result := FHasCount;
end;

procedure TEnumerableWrapper<E, T>.Wrap;
var
  ctx: TRttiContext;
  typ, enumeratorType: TRttiType;
  getEnumMethod, moveNextMethod, getCurrentMethod, getCountMethod: TRttiMethod;
  enumeratorObjImpl: TObject;
  currentProperty, countProperty: TRttiProperty;
begin
  ctx := TRttiContext.Create;

  typ := ctx.GetType(TypeInfo(E));
  if not Assigned(typ) then
    raise EInvalidOpException.Create('Enumerable<T>.Wrap: Type "' + typ.Name + '" does not support enumeration');

  if (typ.TypeKind = tkDynArray) then
  begin
    FGetEnumeratorInstanceMethod :=
      function(const Instance): TObject
      begin
        result := TDynArrayWrapper<T>.Create(pointer(Instance));
      end;

    FMoveNextMethod :=
      function(const Instance): boolean
      begin
        result := TDynArrayWrapper<T>(Instance).MoveNext();
      end;

    FGetCurrentProperty :=
      function(const Instance): T
      begin
        result := TDynArrayWrapper<T>(Instance).GetCurrent();
      end;

    FGetCountProperty :=
      function(const Instance): Integer
      begin
        result := TDynArrayWrapper<T>.GetDynArrayCount(pointer(Instance));
      end;

    FHasCount := True;

    exit;
  end;

  getEnumMethod := typ.GetMethod('GetEnumerator');
  if not Assigned(getEnumMethod) then
    raise EInvalidOpException.Create('Enumerable<T>.Wrap: Type "' + typ.Name + '" does not support enumeration');

  enumeratorType := getEnumMethod.ReturnType;
  if not Assigned(enumeratorType) then
    raise EInvalidOpException.Create('Enumerable<T>.Wrap: Type "' + typ.Name + '" does not support enumeration');

  moveNextMethod := enumeratorType.GetMethod('MoveNext');
  if not Assigned(moveNextMethod) then
    raise EInvalidOpException.Create('Enumerable<T>.Wrap: Type "' + typ.Name + '" does not support enumeration');

  if (enumeratorType.TypeKind = tkClass) then
  begin
    currentProperty := enumeratorType.GetProperty('Current');
    if not Assigned(currentProperty) then
      raise EInvalidOpException.Create('Enumerable<T>.Wrap: Type "' + typ.Name + '" does not support enumeration');

    countProperty := typ.GetProperty('Count');
    if Assigned(countProperty) then
    begin
      if (countProperty.PropertyType.Handle = TypeInfo(Integer)) then
      begin
        FGetCountProperty := RIConstructor.PropGetter<Integer>(typ.Handle, 'Count');
        FHasCount := True;
      end;
    end;

    FGetEnumeratorInstanceMethod := RIConstructor.Func<TObject>(typ.Handle, 'GetEnumerator');
    FMoveNextMethod := RIConstructor.Func<boolean>(enumeratorType.Handle, 'MoveNext');
    FGetCurrentProperty := RIConstructor.PropGetter<T>(enumeratorType.Handle, 'Current');
  end
  else if (enumeratorType.TypeKind = tkInterface) then
  begin
    getCurrentMethod := enumeratorType.GetMethod('GetCurrent');
    if not Assigned(getCurrentMethod) then
      raise EInvalidOpException.Create('Enumerable<T>.Wrap: Type "' + typ.Name + '" does not support enumeration');

    getCountMethod := typ.GetMethod('GetCount');
    if Assigned(getCountMethod) then
    begin
      if (getCountMethod.ReturnType.Handle = TypeInfo(Integer)) then
      begin
        FGetCountProperty := RIConstructor.Func<Integer>(typ.Handle, 'GetCount');
        FHasCount := True;
      end;
    end;

    FGetEnumeratorInterfaceMethod := RIConstructor.Func<IInterface>(typ.Handle, 'GetEnumerator');
    FMoveNextMethod := RIConstructor.Func<boolean>(enumeratorType.Handle, 'MoveNext');
    FGetCurrentProperty := RIConstructor.Func<T>(enumeratorType.Handle, 'GetCurrent');
  end
  else
    raise EInvalidOpException.Create('Enumerable<T>.Wrap: Type "' + typ.Name + '" does not support enumeration');
end;

{ TDynArrayWrapper<T> }

constructor TDynArrayWrapper<T>.Create(const DynArray: pointer);
begin
  inherited Create;

  FDynArray := DynArray;
  FCurrentIndex := -1;
  FCount := GetDynArrayCount(FDynArray);
end;

function TDynArrayWrapper<T>.GetCount: Integer;
begin
  result := FCount;
end;

function TDynArrayWrapper<T>.GetCurrent: T;
type
  PElm = ^T;
var
  a: PElm;
begin
  a := PElm(FDynArray);
  Inc(a, FCurrentIndex);
  result := a^;
end;

class function TDynArrayWrapper<T>.GetDynArrayCount(const DynArray: pointer): Integer;
var
  c: PNativeInt;
begin
  result := 0;
  if not Assigned(DynArray) then
    exit;
  c := PNativeInt(DynArray);
  Dec(c, 1);
  result := c^;
end;

function TDynArrayWrapper<T>.MoveNext: boolean;
begin
  result := (FCurrentIndex + 1) < FCount;
  if not result then
    exit;
  FCurrentIndex := FCurrentIndex + 1;
end;

end.
