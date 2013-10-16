unit NuLib.Containers.Detail.OpenAddressingSeparate;

interface

uses
  Generics.Defaults, NuLib.Containers.Common, NuLib.Containers.Detail;

type
  DictItemFlag = (difHasKey, difOccupied);
  DictItemFlags = set of DictItemFlag;

  // for testing
  Dictionary<K, V> = class
  public
    type
      DictItem = record
        Hash: UInt32;
        Key: K;
        Flags: DictItemFlags;
      end;
  private
    FItems: TArray<DictItem>;
    FValues: TArray<V>;

    FCount: UInt32;
    FCapacity: UInt32;
    FPrimitiveRoot: UInt32; // primitive root of capacity
    FComparer: IEqualityComparer<K>;
    FFindProbes: TArray<UInt32>;

    function KeyHash(const Key: K): UInt32;

    procedure ChangeCapacity(const MinNewCapacity: UInt32);

    procedure Grow;
    function CheckCapacity(const MinimumReserve: UInt32): Boolean;

    procedure AddItem(const Index: UInt32; const Key: K; const Hash: UInt32; const Value: V);

    // finds the item index of the given key
    // returns true if the item contains a value otherwise false
    function FindItem(const Key: K; out Index: UInt32): Boolean; overload;
    // FindItem returns true if Key is found, in which case Index contains the item index
    // otherwise it returns false and Index contains an index to an available item for that Key
    function FindItem(const Key: K; const Hash: UInt32; out Index: UInt32): Boolean; overload;

    function GetItem(const Key: K): V;
    procedure SetItem(const Key: K; const Value: V);
    function GetLoad: double;
    function GetEmpty: Boolean; inline;
    function GetContains(const Key: K): Boolean;
  public
    const MINIMUM_CAPACITY = 7;
    const EMPTY_HASH = UInt32(-1); // max capacity is largest prime less than 2^32-1
  public
    constructor Create(const Comparer: NuLib.Containers.IEqualityComparer<K>);
    destructor Destroy; override;

    procedure Clear;
    function Remove(const Key: K): Boolean;

    procedure Reserve(const MinNewCapacity: UInt32);

    property Comparer: IEqualityComparer<K> read FComparer;
    property Empty: Boolean read GetEmpty;
    property Count: UInt32 read FCount;
    property Capacity: UInt32 read FCapacity;
    property Load: double read GetLoad;
    property Item[const Key: K]: V read GetItem write SetItem;
    property Contains[const Key: K]: Boolean read GetContains;
  end;

implementation

uses
  System.SysUtils;

{ Dictionary<K, V> }

procedure Dictionary<K, V>.AddItem(const Index: UInt32; const Key: K; const Hash: UInt32; const Value: V);
var
  idx: UInt32;
  hasItem, capacityChanged: boolean;
begin
  idx := Index;

  // add item
  capacityChanged := CheckCapacity(1);

  if capacityChanged then
  begin
    // capacity changed, need to get new index
    hasItem := FindItem(Key, Hash, idx);
    Assert(not hasItem);
  end;

  Assert(not (difOccupied in FItems[idx].Flags));

  FItems[idx].Key := Key;
  FItems[idx].Hash := Hash;
  FItems[idx].Flags := [difHasKey, difOccupied];
  FValues[idx] := Value;

  FCount := FCount + 1;
end;

procedure Dictionary<K, V>.ChangeCapacity(const MinNewCapacity: UInt32);
var
  p2Capacity: UInt64;
  newCapacity: UInt32;
  i, idx: UInt32;
  oldItems: TArray<DictItem>;
  oldValues: TArray<V>;
  hasItemOld, hasItemNew: boolean;
begin
  Assert(MinNewCapacity > 0);

  p2Capacity := NextPow2(MinNewCapacity);

  //FCapacity := p2Capacity;
  //FPrimitiveRoot := 3;
  newCapacity := LargestPrimeLessThan(p2Capacity, FPrimitiveRoot);

  if newCapacity = Capacity then
    raise ERangeError.Create('Cannot grow dictionary');

  FCapacity := newCapacity;

  // rehash

  oldItems := FItems;
  oldValues := FValues;

  FItems := nil;
  FValues := nil;
  SetLength(FItems, FCapacity);
  SetLength(FValues, FCapacity);

  if (Length(oldItems) = 0) then
    exit;

  for i := 0 to High(oldItems) do
  begin
    hasItemOld := difOccupied in oldItems[i].Flags;

    if not hasItemOld then
      continue;

    hasItemNew := FindItem(oldItems[i].Key, oldItems[i].Hash, idx);
    Assert(not hasItemNew);

    FItems[idx].Hash := oldItems[i].Hash;
    FItems[idx].Flags := oldItems[i].Flags;
    // swapping prevents refcount changes, if applicable
//    FItems[idx].Key := oldItems[i].Key;
//    FValues[idx] := oldValues[i];
    SwapData(FItems[idx].Key, oldItems[i].Key, SizeOf(K));
    SwapData(FValues[idx], oldValues[i], SizeOf(V));
  end;
end;

function Dictionary<K, V>.CheckCapacity(const MinimumReserve: UInt32): Boolean;
var
  reservedCount: UInt64;
  maxLoadCapacity: UInt64;
begin
  result := False;

  reservedCount := UInt64(Count) + MinimumReserve;
  maxLoadCapacity := (Capacity shr 1) + (Capacity shr 2); // 75 %

  if reservedCount < maxLoadCapacity then
    exit;

  Grow;
  result := True;
end;

procedure Dictionary<K, V>.Clear;
begin
  FItems := nil;
  FCount := 0;
  FCapacity := 0;
end;

constructor Dictionary<K, V>.Create(const Comparer: IEqualityComparer<K>);
begin
  inherited Create;

  FComparer := Comparer;
end;

destructor Dictionary<K, V>.Destroy;
begin

  inherited;
end;

function Dictionary<K, V>.FindItem(const Key: K; out Index: UInt32): Boolean;
var
  hash: UInt32;
begin
  hash := KeyHash(Key);
  result := FindItem(Key, hash, Index);
end;

function Dictionary<K, V>.FindItem(const Key: K; const Hash: UInt32; out Index: UInt32): Boolean;
var
  h, h2: UInt32;
  pr, i, k: UInt32;
  emptyIndex: UInt32;
  keyEqual, foundEmpty: boolean;
begin
  result := False;
  if (Capacity = 0) then
    exit;

  h := Hash;
  h2 := (Hash mod (Capacity - 2)) + 1; // ensure h2 is never zero
  pr := FPrimitiveRoot;
  k := 0;
  Index := 0;
  emptyIndex := 0;
  foundEmpty := false;

  while True do
  begin
    i := h mod Capacity;
    //i := h and (Capacity - 1);

    if not (difHasKey in FItems[i].Flags) then
    begin
      // we're at the end of our probing
      // item is empty, no key to check
      if not foundEmpty then
        emptyIndex := i;
      Index := emptyIndex;
      exit;
    end
    else if (FItems[i].Hash = Hash) then // if hash mismatch keys can't match
    begin
      // hashes are equal
      // if occupied check if keys really match
      if (difOccupied in FItems[i].Flags) then
      begin
        keyEqual := FComparer.Equals(Key, FItems[i].Key);
        if keyEqual then
        begin
          Index := i;
          Result := True;
          exit;
        end;
      end
      else
      begin
        // removed item, update empty index if needed
        emptyIndex := i;
        foundEmpty := true;
      end;
    end;
    // hashes didn't match
    // this means the item was not the one we wanted

    // exponential probing
    // h = Hash + pr^k * h2 + k
    h := Hash + h2 + k;
    h2 := h2 * pr;
    k := k + 1;
  end;
end;

function Dictionary<K, V>.GetContains(const Key: K): Boolean;
var
  idx: UInt32;
begin
  result := FindItem(Key, idx);
end;

function Dictionary<K, V>.GetEmpty: Boolean;
begin
  result := Count = 0;
end;

function Dictionary<K, V>.GetItem(const Key: K): V;
var
  idx, hash: UInt32;
  hasItem: Boolean;
begin
  hash := KeyHash(Key);
  hasItem := FindItem(Key, hash, idx);
  if hasItem then
  begin
    result := FValues[idx];
    exit;
  end;

  // item not here, add default constructed value
  result := Default(V);
  AddItem(idx, Key, hash, result);
end;

function Dictionary<K, V>.GetLoad: double;
begin
  result := Count / Capacity;
end;

procedure Dictionary<K, V>.Grow;
var
  newCapacity: UInt64;
begin
  newCapacity := (3 * UInt64(Capacity)) div 2;
  if newCapacity < MINIMUM_CAPACITY then
    newCapacity := MINIMUM_CAPACITY;
  Reserve(newCapacity);
end;

function Dictionary<K, V>.KeyHash(const Key: K): UInt32;
begin
  result := FComparer.GetHashCode(Key);
  result := MurmurFinalize(result);
end;

function Dictionary<K, V>.Remove(const Key: K): Boolean;
var
  idx: UInt32;
begin
  result := FindItem(Key, idx);
  if not result then
    exit;

  FItems[idx].Flags := FItems[idx].Flags - [difOccupied];
  FValues[idx] := Default(V);
  FCount := FCount - 1;
end;

procedure Dictionary<K, V>.Reserve(const MinNewCapacity: UInt32);
begin
  if MinNewCapacity <= Capacity then
    exit;

  ChangeCapacity(MinNewCapacity);
end;

procedure Dictionary<K, V>.SetItem(const Key: K; const Value: V);
var
  hash, idx: UInt32;
  hasItem: Boolean;
begin
  hash := KeyHash(Key);
  hasItem := FindItem(Key, hash, idx);
  if hasItem then
  begin
    // change value at idx
    FItems[idx].Flags := FItems[idx].Flags + [difOccupied];
    FValues[idx] := Value;
    exit;
  end;

  AddItem(idx, Key, hash, Value);
end;

end.
