unit NuContainers.Detail.OpenAddressingInline;

interface

uses
  Generics.Defaults, NuContainers.Common, NuContainers.Detail;

type
  DictItemFlag = (difHasKey, difOccupied);
  DictItemFlags = set of DictItemFlag;

  Dictionary<K, V> = class(TInterfacedObject, IDictionaryImplementation<K, V>)
  public
    type
      DictItem = record
        Hash: UInt32;
        Key: K;
        Value: V;
        Flags: DictItemFlags;
      end;
      PDictItem = ^DictItem;
  private
    FItems: TArray<DictItem>;

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

    function GetComparer: IEqualityComparer<K>;
    function GetCount: UInt32;
    function GetCapacity: UInt32;
    function GetItem(const Key: K): V;
    procedure SetItem(const Key: K; const Value: V);
    function GetLoad: double;
    function GetEmpty: Boolean; inline;
    function GetContains(const Key: K): Boolean;
  public
    const MINIMUM_CAPACITY = 7;
  public
    constructor Create(const Comparer: NuContainers.IEqualityComparer<K>);
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

function MurmurFinalize(const hash: UInt32): UInt32; inline;

// returns 0 if v is 0 or result > 2^31
function NextPow2(v: UInt32): UInt64; inline;

// works for v <= 2^32
function LargestPrimeLessThan(v: UInt64; out PrimitiveRoot: UInt32): UInt32;

procedure SwapData(var v1, v2; Size: UInt32); inline;

procedure IntRefToMethPtr(const IntRef; var MethPtr; MethNo: Integer);

implementation

uses
  System.SysUtils;

function MurmurFinalize(const hash: UInt32): UInt32;
begin
  result := hash;
  result := result xor (result shr 16);
  result := result * $85ebca6b;
  result := result xor (result shr 13);
  result := result * $c2b2ae35;
  result := result xor (result shr 16);
end;

function NextPow2(v: UInt32): UInt64;
begin
  v := v or (v shr 1);
  v := v or (v shr 2);
  v := v or (v shr 4);
  v := v or (v shr 8);
  v := v or (v shr 16);
  result := v;
  result := result + 1;
end;

const
  PrimeList: array[0..30] of UInt32 = (
  3, 7, 13, 31, 61, 127, 251, 509, 1021, 2039, 4093, 8191, 16381, 32749, 65521,
  131071, 262139, 524287, 1048573, 2097143, 4194301, 8388593, 16777213,
  33554393, 67108859, 134217689, 268435399, 536870909, 1073741789,
  2147483647, 4294967291);
  PrimitiveRootList: array[0..30] of UInt32 = (
//  2, 3, 2, 3, 2, 3, 6, 2, 10, 7, 2, 17, 2, 2, 17,
//  3, 2, 3, 2, 5, 7, 3, 5,
//  3, 2, 3, 3, 2, 2,
//  7, 2);
  2, // 3
  3, // 7
  6, // 13
  12, // 31
  17, // 61
  23, // 127
  24, // 251
  27, // 509
  30, // 1021
  33, // 2039
  34, // 4093
  35, // 8191
  40, // 16381
  44, // 32749
  46, // 65521
  52, // 131071
  54, // 262139
  56, // 524287
  60, // 1048573
  65, // 2097143
  73, // 4194301
  75, // 8388593
  80, // 16777213
  82, // 33554393
  87, // 67108859
  89, // 134217689
  93, // 268435399
  95, // 536870909
  90, // 1073741789
  99, // 2147483647
  101 // 4294967291
  );

function LargestPrimeLessThan(v: UInt64; out PrimitiveRoot: UInt32): UInt32;
var
  i: UInt32;
begin
  result := 0;
  PrimitiveRoot := 0;
  for i := 0 to High(PrimeList) do
  begin
    if PrimeList[i] > v  then
      exit;
    result := PrimeList[i];
    PrimitiveRoot := PrimitiveRootList[i];
  end;
end;

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
  FItems[idx].Value := Value;
  FItems[idx].Flags := [difHasKey, difOccupied];

  FCount := FCount + 1;
end;

procedure Dictionary<K, V>.ChangeCapacity(const MinNewCapacity: UInt32);
var
  p2Capacity: UInt64;
  newCapacity: UInt32;
  i, idx: UInt32;
  oldItems: TArray<DictItem>;
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

  FItems := nil;
  SetLength(FItems, FCapacity);

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
    // swapping prevents refcount changes, if applicable
//    FItems[idx].Key := oldItems[i].Key;
//    FItems[idx].Value := oldItems[i].Value;
    SwapData(FItems[idx].Key, oldItems[i].Key, SizeOf(K));
    SwapData(FItems[idx].Value, oldItems[i].Value, SizeOf(V));
    FItems[idx].Flags := oldItems[i].Flags;
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
  item: PDictItem;
  h, h1: UInt32;
  h2: UInt64; // ai*h2 needs to be 64 bit
  pr, ai, a, i: UInt32;
  emptyIndex: UInt32;
  keyEqual, foundEmpty: boolean;
begin
  result := False;
  if (Capacity = 0) then
    exit;

  h1 := Hash mod Capacity;
  h2 := (Hash mod (Capacity - 2)) + 1; // ensure h2 is never zero
  pr := FPrimitiveRoot; // pr is guaranteed to be < M
  ai := 1;
  Index := 0;
  emptyIndex := 0;
  foundEmpty := false;

  h := h1;
  while True do
  begin
    i := h;

    item := @FItems[i];

    if not (difHasKey in item^.Flags) then
    begin
      // we're at the end of our probing
      // item is empty, no key to check
      if not foundEmpty then
        emptyIndex := i;
      Index := emptyIndex;
      exit;
    end
    else if (item^.Hash = Hash) then // if hash mismatch keys can't match
    begin
      // hashes are equal
      // if occupied check if keys really match
      if (difOccupied in item^.Flags) then
      begin
        keyEqual := FComparer.Equals(Key, item^.Key);
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
    // Hash + pr^k * h2 = h mod M
    // pr^k * h2 can become larger than 32 bit quickly
    // which breaks the full sequence guarantee
    // so rewrite
    //   Hash = Hash mod M = x mod M
    //   pr^k = pr^k mod M = y mod M
    //     h2 = h2 mod M = z mod M
    //
    // Hash + pr^k * h2 = (x + y * z) mod M
    // so we let h = (x + y * z) mod M
    // with (y * z) being 64bit to avoid overflow

    ai := (ai * pr) mod Capacity;
    h := (h1 + ai * h2) mod Capacity;
  end;
end;

function Dictionary<K, V>.GetCapacity: UInt32;
begin
  result := FCapacity;
end;

function Dictionary<K, V>.GetComparer: IEqualityComparer<K>;
begin
  result := FComparer;
end;

function Dictionary<K, V>.GetContains(const Key: K): Boolean;
var
  idx: UInt32;
begin
  result := FindItem(Key, idx);
end;

function Dictionary<K, V>.GetCount: UInt32;
begin
  result := FCount;
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
    result := FItems[idx].Value;
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

  FItems[idx].Value := Default(V);
  FItems[idx].Flags := FItems[idx].Flags - [difOccupied];
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
    FItems[idx].Value := Value;
    FItems[idx].Flags := FItems[idx].Flags + [difOccupied];
    exit;
  end;

  AddItem(idx, Key, hash, Value);
end;

procedure SwapData(var v1, v2; Size: UInt32); inline;
type
  PData = ^UInt8;
var
  p1, p2, pt: PData;
  tv: array[0..1023] of UInt8; // yeah ok...
begin
  p1 := PData(@v1);
  p2 := PData(@v2);
  pt := PData(@tv);

  Move(p1^, pt^, Size);
  Move(p2^, p1^, Size);
  Move(pt^, p2^, Size);
end;

procedure IntRefToMethPtr(const IntRef; var MethPtr; MethNo: Integer);
type
  TVtable = array[0..999] of Pointer;
  PVtable = ^TVtable;
  PPVtable = ^PVtable;
begin
  // QI=0, AddRef=1, Release=2, 3 = first user method
  TMethod(MethPtr).Code := PPVtable(IntRef)^^[MethNo];
  TMethod(MethPtr).Data := Pointer(IntRef);
end;

end.
