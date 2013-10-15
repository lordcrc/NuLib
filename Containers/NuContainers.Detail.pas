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

  IDictionaryImplementation<K, V> = interface
    function GetComparer: IEqualityComparer<K>;
    function GetEmpty: Boolean;
    function GetCount: UInt32;
    function GetCapacity: UInt32;
    function GetItem(const Key: K): V;
    function GetContains(const Key: K): Boolean;

    procedure SetItem(const Key: K; const Value: V);

    procedure Clear;
    function Remove(const Key: K): Boolean;

    procedure Reserve(const MinNewCapacity: UInt32);

    property Comparer: IEqualityComparer<K> read GetComparer;
    property Empty: Boolean read GetEmpty;
    property Count: UInt32 read GetCount;
    property Capacity: UInt32 read GetCapacity;
    property Item[const Key: K]: V read GetItem write SetItem;
    property Contains[const Key: K]: Boolean read GetContains;
  end;

implementation

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
