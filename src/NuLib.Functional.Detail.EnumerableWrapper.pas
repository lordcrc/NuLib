unit NuLib.Functional.Detail.EnumerableWrapper;

interface

uses
  NuLib.RuntimeInvocation,
  NuLib.Functional.Common,
  NuLib.Functional.Detail, System.Rtti;

type
  TEnumeratorWrapper<T> = class(TInterfacedObject, IEnumeratorImpl<T>)
  private
    FEnumeratorInstance: TObject;
    FMoveNextMethod: NuLib.RuntimeInvocation.RIFunc<boolean>;
    FGetCurrentProperty: NuLib.RuntimeInvocation.RIFunc<T>;
  public
    constructor Create(const EnumeratorInstance: TObject;
      const MoveNextMethod: NuLib.RuntimeInvocation.RIFunc<boolean>;
      const GetCurrentProperty: NuLib.RuntimeInvocation.RIFunc<T>);

    function GetCurrent: T;
    function MoveNext: Boolean;
  end;

  TEnumerableWrapper<E: class; T> = class(TInterfacedObject, IEnumerableImpl<T>)
  private
    FEnumerableObj: E;
    FGetEnumeratorInstanceMethod: NuLib.RuntimeInvocation.RIFunc<TObject>;
    FMoveNextMethod: NuLib.RuntimeInvocation.RIFunc<boolean>;
    FGetCurrentProperty: NuLib.RuntimeInvocation.RIFunc<T>;

    procedure Wrap;
  public
    constructor Create(const EnumerableObj: E);

    function GetEnumerator: IEnumeratorImpl<T>;
  end;

implementation

uses
  System.SysUtils;

{ TEnumeratorWrapper<T> }

constructor TEnumeratorWrapper<T>.Create(const EnumeratorInstance: TObject;
  const MoveNextMethod: NuLib.RuntimeInvocation.RIFunc<boolean>;
  const GetCurrentProperty: NuLib.RuntimeInvocation.RIFunc<T>);
begin
  inherited Create;

  FEnumeratorInstance := EnumeratorInstance;
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
begin
  enumeratorInstance := FGetEnumeratorInstanceMethod(FEnumerableObj);

  result := TEnumeratorWrapper<T>.Create(enumeratorInstance, FMoveNextMethod, FGetCurrentProperty);
end;

procedure TEnumerableWrapper<E, T>.Wrap;
var
  ctx: TRttiContext;
  typ, enumeratorType: TRttiType;
  getEnumMethod, moveNextMethod: TRttiMethod;
  enumeratorObjImpl: TObject;
  currentProperty: TRttiProperty;
  codeAddress: pointer;
begin
  ctx := TRttiContext.Create;

  typ := ctx.GetType(TypeInfo(E));
  if not Assigned(typ) then
    raise EInvalidOpException.Create('Enumerable<T>.Wrap: Class "' + E.ClassName + '" does not support enumeration');

  getEnumMethod := typ.GetMethod('GetEnumerator');
  if not Assigned(getEnumMethod) then
    raise EInvalidOpException.Create('Enumerable<T>.Wrap: Class "' + E.ClassName + '" does not support enumeration');

  enumeratorType := getEnumMethod.ReturnType;
  if not Assigned(enumeratorType) then
    raise EInvalidOpException.Create('Enumerable<T>.Wrap: Class "' + E.ClassName + '" does not support enumeration');

  moveNextMethod := enumeratorType.GetMethod('MoveNext');
  if not Assigned(moveNextMethod) then
    raise EInvalidOpException.Create('Enumerable<T>.Wrap: Class "' + E.ClassName + '" does not support enumeration');

  currentProperty := enumeratorType.GetProperty('Current');
  if not Assigned(currentProperty) then
    raise EInvalidOpException.Create('Enumerable<T>.Wrap: Class "' + E.ClassName + '" does not support enumeration');

  if enumeratorType.IsInstance then
  begin
    FGetEnumeratorInstanceMethod := RIConstructor<E>.Func<TObject>('GetEnumerator');
    FMoveNextMethod := RIConstructor.Func<boolean>(enumeratorType.Handle, 'MoveNext');
    FGetCurrentProperty := RIConstructor.PropGetter<T>(enumeratorType.Handle, 'Current');
  end
  else
    raise EInvalidOpException.Create('Enumerable<T>.Wrap: Class "' + E.ClassName + '" does not support enumeration');
end;

end.
