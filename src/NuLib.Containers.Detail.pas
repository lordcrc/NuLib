unit NuLib.Containers.Detail;

interface

uses
  Generics.Defaults, NuLib.Containers.Common;

type
  TEqualityComparerWrapper<T> = class(TInterfacedObject, NuLib.Containers.IEqualityComparer<T>)
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
    class function Get: NuLib.Containers.IEqualityComparer<T>; static;
  end;

  IEnumerator<T> = interface
    function GetCurrent: T;
    function MoveNext: Boolean;
    procedure Reset;

    property Current: T read GetCurrent;
  end;

  ///	<summary>
  ///	  GetEnumerator implementation.
  ///	</summary>
  ///	<typeparam name="T">
  ///	  Enumerator to return.
  ///	</typeparam>
  EnumeratorImpl<T> = record
  strict private
    FEnum: NuLib.IEnumerator<T>;
  public
    constructor Create(const Enum: NuLib.IEnumerator<T>);

    function GetEnumerator: NuLib.IEnumerator<T>;
  end;

  DictionaryElementView<K, V> = record
  public
    type
      KeyPtr = ^K;
      ValuePtr = ^V;
  strict private
    FKeyRef: KeyPtr;
    FValueRef: ValuePtr;
  public
    constructor Create(const KeyRef: KeyPtr; const ValueRef: ValuePtr);

    property KeyRef: KeyPtr read FKeyRef;
    property ValueRef: ValuePtr read FValueRef;
  end;

  DictionaryElementViewEnumerator<K, V> = class(TInterfacedObject, IEnumerator<DictionaryElementView<K, V>>)
  public
    type
      ElementView = DictionaryElementView<K, V>;
  protected
    function DoMoveNext: Boolean; virtual; abstract;
    procedure DoReset; virtual; abstract;
    function GetCurrentElementView: ElementView; virtual; abstract;
  public
    function GetCurrent: ElementView;
    function MoveNext: Boolean;
    procedure Reset;

    property Current: ElementView read GetCurrent;
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

    function GetEnumerator: DictionaryElementViewEnumerator<K, V>;

    property Comparer: IEqualityComparer<K> read GetComparer;
    property Empty: Boolean read GetEmpty;
    property Count: UInt32 read GetCount;
    property Capacity: UInt32 read GetCapacity;
    property Item[const Key: K]: V read GetItem write SetItem;
    property Contains[const Key: K]: Boolean read GetContains;
  end;

  DictionaryKeyEnumerator<K, V> = class(TInterfacedObject, IEnumerator<K>)
  private
    FDictEnum: DictionaryElementViewEnumerator<K, V>;
  public
    // takes ownership of DictEnum
    constructor Create(const DictEnum: DictionaryElementViewEnumerator<K,V>);
    destructor Destroy; override;

    function GetCurrent: K;
    function MoveNext: Boolean;
    procedure Reset;

    property Current: K read GetCurrent;
  end;

  DictionaryValueEnumerator<K, V> = class(TInterfacedObject, IEnumerator<V>)
  private
    FDictEnum: DictionaryElementViewEnumerator<K, V>;
  public
    // takes ownership of DictEnum
    constructor Create(const DictEnum: DictionaryElementViewEnumerator<K,V>);
    destructor Destroy; override;

    function GetCurrent: V;
    function MoveNext: Boolean;
    procedure Reset;

    property Current: V read GetCurrent;
  end;

function MurmurFinalize(const hash: UInt32): UInt32; inline;

implementation

function MurmurFinalize(const hash: UInt32): UInt32;
begin
  result := hash;
  result := result xor (result shr 16);
  result := result * $85ebca6b;
  result := result xor (result shr 13);
  result := result * $c2b2ae35;
  result := result xor (result shr 16);
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

{ EnumeratorImpl<T> }

constructor EnumeratorImpl<T>.Create(const Enum: NuLib.IEnumerator<T>);
begin
  FEnum := Enum;
end;

function EnumeratorImpl<T>.GetEnumerator: NuLib.IEnumerator<T>;
begin
  result := FEnum;
end;

{ DictionaryElementView<K, V> }

constructor DictionaryElementView<K, V>.Create(const KeyRef: KeyPtr; const ValueRef: ValuePtr);
begin
  FKeyRef := KeyRef;
  FValueRef := ValueRef;
end;

{ DictionaryElementViewEnumerator<K, V> }

function DictionaryElementViewEnumerator<K, V>.GetCurrent: ElementView;
begin
  result := GetCurrentElementView;
end;

function DictionaryElementViewEnumerator<K, V>.MoveNext: Boolean;
begin
  result := DoMoveNext;
end;

procedure DictionaryElementViewEnumerator<K, V>.Reset;
begin
  DoReset;
end;

{ DictionaryKeyEnumerator<K, V> }

constructor DictionaryKeyEnumerator<K, V>.Create(const DictEnum: DictionaryElementViewEnumerator<K, V>);
begin
  inherited Create;

  FDictEnum := DictEnum;
end;

destructor DictionaryKeyEnumerator<K, V>.Destroy;
begin
  FDictEnum.Free;

  inherited;
end;

function DictionaryKeyEnumerator<K, V>.GetCurrent: K;
begin
  result := FDictEnum.Current.KeyRef^;
end;

function DictionaryKeyEnumerator<K, V>.MoveNext: Boolean;
begin
  result := FDictEnum.MoveNext;
end;

procedure DictionaryKeyEnumerator<K, V>.Reset;
begin
  FDictEnum.Reset;
end;

{ DictionaryValueEnumerator<K, V> }

constructor DictionaryValueEnumerator<K, V>.Create(const DictEnum: DictionaryElementViewEnumerator<K, V>);
begin
  inherited Create;

  FDictEnum := DictEnum;
end;

destructor DictionaryValueEnumerator<K, V>.Destroy;
begin
  FDictEnum.Free;

  inherited;
end;

function DictionaryValueEnumerator<K, V>.GetCurrent: V;
begin
  result := FDictEnum.Current.ValueRef^;
end;

function DictionaryValueEnumerator<K, V>.MoveNext: Boolean;
begin
  result := FDictEnum.MoveNext;
end;

procedure DictionaryValueEnumerator<K, V>.Reset;
begin
  FDictEnum.Reset;
end;

end.
