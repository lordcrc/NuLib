unit NuLib.Containers.Common;

interface

type
  IEqualityComparer<T> = interface
    function Equals(const Left, Right: T): Boolean;
    function GetHashCode(const Value: T): UInt32;
  end;

  EqualityComparisonFunction<T> = reference to function(const Left, Right: T): Boolean;

  HashFunction<T> = reference to function(const Value: T): UInt32;

  DelegatedEqualityComparer<T> = class(TInterfacedObject, IEqualityComparer<T>)
  private
    FComparisonFunc: EqualityComparisonFunction<T>;
    FHashFunc: HashFunction<T>;

    function Equals(const Left, Right: T): Boolean; reintroduce;
    function GetHashCode(const Value: T): UInt32; reintroduce;
  public
    constructor Create(const ComparisonFunc: EqualityComparisonFunction<T>; const HashFunc: HashFunction<T>);
  end;

implementation

{ DelegatedEqualityComparer<T> }

constructor DelegatedEqualityComparer<T>.Create(const ComparisonFunc: EqualityComparisonFunction<T>;
  const HashFunc: HashFunction<T>);
begin
  inherited Create;
  FComparisonFunc := ComparisonFunc;
  FHashFunc := HashFunc;
end;

function DelegatedEqualityComparer<T>.Equals(const Left, Right: T): Boolean;
begin
  result := FComparisonFunc(Left, Right);
end;

function DelegatedEqualityComparer<T>.GetHashCode(const Value: T): UInt32;
begin
  result := FHashFunc(Value);
end;

end.
