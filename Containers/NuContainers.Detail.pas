unit NuContainers.Detail;

interface

uses
  Generics.Defaults, NuContainers.Common;

type
  TEqualityComparerWrapper<T> = class(TInterfacedObject, NuContainers.IEqualityComparer<T>)
  private
    FEq: Generics.Defaults.IEqualityComparer<T>;
  public
    function IEqualityComparer<T>.Equals = EC_Equals;
    function IEqualityComparer<T>.GetHashCode = EC_GetHashCode;

    constructor Create(Eq: Generics.Defaults.IEqualityComparer<T>);

    function EC_Equals(const Left, Right: T): Boolean;
    function EC_GetHashCode(const Value: T): UInt32;
  end;

  EqualityComparerInstance<T> = record
    class function Get: NuContainers.IEqualityComparer<T>; static;
  end;

  LifeTime = interface
  end;

function NewLifeTime(const Obj: TObject): LifeTime;

implementation

type
  TLifeTime = class(TInterfacedObject, LifeTime)
  private
    FObj: TObject;
  public
    constructor Create(Obj: TObject);
    destructor Destroy; override;
  end;

function NewLifeTime(const Obj: TObject): LifeTime;
begin
  result := TLifeTime.Create(Obj);
end;

{ TLifeTime }

constructor TLifeTime.Create(Obj: TObject);
begin
  inherited Create;
  FObj := Obj;
end;

destructor TLifeTime.Destroy;
begin
  FObj.Free;

  inherited;
end;

{ TEqualityComparerWrapper<T> }

constructor TEqualityComparerWrapper<T>.Create(Eq: Generics.Defaults.IEqualityComparer<T>);
begin
  inherited Create;

  FEq := Eq;
end;

function TEqualityComparerWrapper<T>.EC_Equals(const Left, Right: T): Boolean;
begin
  result := FEq.Equals(Left, Right);
end;

function TEqualityComparerWrapper<T>.EC_GetHashCode(const Value: T): UInt32;
begin
  result := UInt32(FEq.GetHashCode(Value));
end;

{ EqualityComparerInstance<T> }

class function EqualityComparerInstance<T>.Get: IEqualityComparer<T>;
begin
  result := TEqualityComparerWrapper<T>.Create(Generics.Defaults.TEqualityComparer<T>.Default);
end;

end.
