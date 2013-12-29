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
    FGetEnumeratorInstanceMethod: NuLib.RuntimeInvocation.RIFunc<TObject>;
    FGetEnumeratorInterfaceMethod: NuLib.RuntimeInvocation.RIFunc<IInterface>;
    FMoveNextMethod: NuLib.RuntimeInvocation.RIFunc<boolean>;
    FGetCurrentProperty: NuLib.RuntimeInvocation.RIFunc<T>;

    procedure Wrap;
  public
    constructor Create(const EnumerableObj: E);

    function GetEnumerator: IEnumeratorImpl<T>;
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

procedure TEnumerableWrapper<E, T>.Wrap;
var
  ctx: TRttiContext;
  typ, enumeratorType: TRttiType;
  getEnumMethod, moveNextMethod, getCurrentMethod: TRttiMethod;
  enumeratorObjImpl: TObject;
  currentProperty: TRttiProperty;
begin
  ctx := TRttiContext.Create;

  typ := ctx.GetType(TypeInfo(E));
  if not Assigned(typ) then
    raise EInvalidOpException.Create('Enumerable<T>.Wrap: Type "' + typ.Name + '" does not support enumeration');

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

    FGetEnumeratorInstanceMethod := RIConstructor.Func<TObject>(typ.Handle, 'GetEnumerator');
    FMoveNextMethod := RIConstructor.Func<boolean>(enumeratorType.Handle, 'MoveNext');
    FGetCurrentProperty := RIConstructor.PropGetter<T>(enumeratorType.Handle, 'Current');
  end
  else if (enumeratorType.TypeKind = tkInterface) then
  begin
    getCurrentMethod := enumeratorType.GetMethod('GetCurrent');
    if not Assigned(getCurrentMethod) then
      raise EInvalidOpException.Create('Enumerable<T>.Wrap: Type "' + typ.Name + '" does not support enumeration');

    FGetEnumeratorInterfaceMethod := RIConstructor.Func<IInterface>(typ.Handle, 'GetEnumerator');
    FMoveNextMethod := RIConstructor.Func<boolean>(enumeratorType.Handle, 'MoveNext');
    FGetCurrentProperty := RIConstructor.Func<T>(enumeratorType.Handle, 'GetCurrent');
  end
  else
    raise EInvalidOpException.Create('Enumerable<T>.Wrap: Type "' + typ.Name + '" does not support enumeration');
end;

end.
