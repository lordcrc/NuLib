unit NuLib.Containers.Test;

interface

uses
  WinApi.Windows,
  System.SysUtils,
  System.Classes,
  System.Character,
  Generics.Defaults,
  Generics.Collections,
  NuLib.Containers.Common,
  NuLib.Containers;

procedure RunTests;

implementation

type
  IDict<K, V> = interface
    function GetCount: UInt32;
    function GetItem(const Key: K): V;
    procedure SetItem(const Key: K; const Value: V);
    function GetEmpty: Boolean;
    function GetContains(const Key: K): Boolean;

    procedure Clear;
    function Remove(const Key: K): Boolean;

    property Empty: Boolean read GetEmpty;
    property Count: UInt32 read GetCount;
    property Item[const Key: K]: V read GetItem write SetItem; default;
    property Contains[const Key: K]: Boolean read GetContains;
  end;

  TDictRefWrapper<K, V> = class(TInterfacedObject, IDict<K, V>)
  private
    type
      TDict = Generics.Collections.TDictionary<K, V>;
  private
    FDict: TDict;
  public
    constructor Create(Comparer: Generics.Defaults.IEqualityComparer<K> = nil);
    destructor Destroy; override;

    function GetCount: UInt32;
    function GetItem(const Key: K): V;
    procedure SetItem(const Key: K; const Value: V);
    function GetEmpty: Boolean;
    function GetContains(const Key: K): Boolean;

    procedure Clear;
    function Remove(const Key: K): Boolean;
  end;

{ TDictRefWrapper<K, V> }

procedure TDictRefWrapper<K, V>.Clear;
begin
  FDict.Clear;
end;

constructor TDictRefWrapper<K, V>.Create(Comparer: Generics.Defaults.IEqualityComparer<K> = nil);
begin
  inherited Create;

  FDict := TDict.Create(Comparer)
end;

destructor TDictRefWrapper<K, V>.Destroy;
begin
  FDict.Free;

  inherited;
end;

function TDictRefWrapper<K, V>.GetContains(const Key: K): Boolean;
begin
  result := FDict.ContainsKey(Key);
end;

function TDictRefWrapper<K, V>.GetCount: UInt32;
begin
  result := FDict.Count;
end;

function TDictRefWrapper<K, V>.GetEmpty: Boolean;
begin
  result := FDict.Count = 0;
end;

function TDictRefWrapper<K, V>.GetItem(const Key: K): V;
begin
  if not FDict.TryGetValue(Key, result) then
  begin
    result := Default(V);
    FDict.Add(Key, result);
  end;
end;

function TDictRefWrapper<K, V>.Remove(const Key: K): Boolean;
begin
  result := FDict.ContainsKey(Key);
  if result then
    FDict.Remove(Key);
end;

procedure TDictRefWrapper<K, V>.SetItem(const Key: K; const Value: V);
begin
  FDict.AddOrSetValue(Key, Value);
end;

type
  TDictWrapper<K, V> = class(TInterfacedObject, IDict<K, V>)
  private
    type
      TDict = NuLib.Containers.Dictionary<K, V>;
  private
    FDict: TDict;
  public
    constructor Create(const Comparer: NuLib.Containers.Common.IEqualityComparer<K> = nil);

    function GetCount: UInt32;
    function GetItem(const Key: K): V;
    procedure SetItem(const Key: K; const Value: V);
    function GetEmpty: Boolean;
    function GetContains(const Key: K): Boolean;

    procedure Clear;
    function Remove(const Key: K): Boolean;
  end;


{ TDictWrapper<K, V> }

procedure TDictWrapper<K, V>.Clear;
begin
  FDict.Clear;
end;

constructor TDictWrapper<K, V>.Create(const Comparer: NuLib.Containers.Common.IEqualityComparer<K>);
begin
  inherited Create;

  if Assigned(Comparer) then
    FDict := TDict.Create(Comparer)
  else
    FDict := TDict.Create;
end;

function TDictWrapper<K, V>.GetContains(const Key: K): Boolean;
begin
  result := FDict.Contains[Key];
end;

function TDictWrapper<K, V>.GetCount: UInt32;
begin
  result := FDict.Count;
end;

function TDictWrapper<K, V>.GetEmpty: Boolean;
begin
  result := FDict.Empty;
end;

function TDictWrapper<K, V>.GetItem(const Key: K): V;
begin
  result := FDict[Key];
end;

function TDictWrapper<K, V>.Remove(const Key: K): Boolean;
begin
  result := FDict.Remove(Key);
end;

procedure TDictWrapper<K, V>.SetItem(const Key: K; const Value: V);
begin
  FDict[Key] := Value;
end;

type
  TRefStringEqualityComparer = class(TInterfacedObject, Generics.Defaults.IEqualityComparer<string>)
  public
    function Equals(const Left, Right: string): Boolean; reintroduce;
    function GetHashCode(const Value: string): Integer; reintroduce;
  end;

  TStringEqualityComparer = class(TInterfacedObject, NuLib.Containers.Common.IEqualityComparer<string>)
  public
    function Equals(const Left, Right: string): Boolean; reintroduce;
    function GetHashCode(const Value: string): UInt32; reintroduce;
  end;

function Equals(const Left, Right: string): Boolean; inline;
begin
  result := Left = Right;
end;

// murmur hash

function rotl32(const x: UInt32; r: UInt8): UInt32; inline;
begin
  result := (x shl r) or (x shr (32 - r));
end;

function MurmurFinalize(const hash: UInt32): UInt32; inline;
begin
  result := hash;
  result := result xor (result shr 16);
  result := result * $85ebca6b;
  result := result xor (result shr 13);
  result := result * $c2b2ae35;
  result := result xor (result shr 16);
end;

function MurmurHash3(const Data; const DataLength, Seed: UInt32): UInt32;
const
  C1 = $cc9e2d51;
  C2 = $1b873593;
  C3 = 5;
  C4 = $e6546b64;
type
  PBlock = ^UInt32;
  TByteBlock = array[0..3] of UInt8;
  PByteBlock = ^TByteBlock;
var
  block: PBlock;
  tail: PByteBlock;
  i, numBlocks: integer;
  r: UInt32;
  h1, k1: UInt32;
begin
  numBlocks := DataLength div 4;

  h1 := Seed;

  // body

  block := PBlock(@Data);

  for i := 0 to numBlocks-1 do
  begin
    k1 := block^;

    k1 := k1 * c1;
    k1 := rotl32(k1, 15);
    k1 := k1 * c2;

    h1 := h1 xor k1;
    h1 := rotl32(h1, 13);
    h1 := h1 * C3 + C4;

    inc(block);
  end;

  // tail
  tail := PByteBlock(block);

  k1 := 0;

  r := DataLength and 3;
  if r = 3 then
    k1 := k1 xor (tail[2] shl 16);
  if r >= 2 then
    k1 := k1 xor (tail[1] shl 8);
  if r >= 1 then
    k1 := k1 xor tail[0];

  k1 := k1 * c1;
  k1 := rotl32(k1, 15);
  k1 := k1 * c2;
  h1 := h1 xor k1;

  // finalization

  h1 := h1 xor DataLength;

  // mixing is done separately
  //h1 = fmix32(h1);

  result := h1;
end;

function StringEquals(const Left, Right: string): Boolean; inline;
begin
  result := Left = Right;
end;

function StringGetHashCode(const Value: string): UInt32; inline;
begin
  result := MurmurHash3(Value[1], SizeOf(Value[1]) * Length(Value), 101);
end;

{ TRefStringEqualityComparer }

function TRefStringEqualityComparer.Equals(const Left, Right: string): Boolean;
begin
  result := StringEquals(Left, Right);
end;

function TRefStringEqualityComparer.GetHashCode(const Value: string): Integer;
begin
  result := StringGetHashCode(Value);
//  result := MurmurFinalize(result);
end;

{ TStringEqualityComparer }

function TStringEqualityComparer.Equals(const Left, Right: string): Boolean;
begin
  result := StringEquals(Left, Right);
end;

function TStringEqualityComparer.GetHashCode(const Value: string): UInt32;
begin
  result := StringGetHashCode(Value);
end;

type
  TRec = record
    i: integer;
    s: string;
    constructor Create(const ii: integer; const ss: string);
  end;

constructor TRec.Create(const ii: integer; const ss: string);
begin
  i := ii;
  s := ss;
end;

type
  TRefRecEqualityComparer = class(TInterfacedObject, Generics.Defaults.IEqualityComparer<TRec>)
  public
    function Equals(const Left, Right: TRec): Boolean; reintroduce;
    function GetHashCode(const Value: TRec): Integer; reintroduce;
  end;

  TRecEqualityComparer = class(TInterfacedObject, NuLib.Containers.Common.IEqualityComparer<TRec>)
  public
    function Equals(const Left, Right: TRec): Boolean; reintroduce;
    function GetHashCode(const Value: TRec): UInt32; reintroduce;
  end;

function RecEquals(const Left, Right: TRec): Boolean; inline;
begin
  result := (Left.i = Right.i) and (Left.s = Right.s);
end;

function RecGetHashCode(const Value: TRec): UInt32; inline;
begin
  result := MurmurHash3(Value.i, SizeOf(Value.i), 1) xor StringGetHashCode(Value.s);
end;

{ TRefRecEqualityComparer }

function TRefRecEqualityComparer.Equals(const Left, Right: TRec): Boolean;
begin
  result := RecEquals(Left, Right);
end;

function TRefRecEqualityComparer.GetHashCode(const Value: TRec): Integer;
begin
  result := RecGetHashCode(Value);
  result := MurmurFinalize(result);
end;

{ TRecEqualityComparer }

function TRecEqualityComparer.Equals(const Left, Right: TRec): Boolean;
begin
  result := RecEquals(Left, Right);
end;

function TRecEqualityComparer.GetHashCode(const Value: TRec): UInt32;
begin
  result := RecGetHashCode(Value);
end;




type
  TRefIntegerEqualityComparer = class(TInterfacedObject, Generics.Defaults.IEqualityComparer<Integer>)
  public
    function Equals(const Left, Right: Integer): Boolean; reintroduce;
    function GetHashCode(const Value: Integer): Integer; reintroduce;
  end;

  TIntegerEqualityComparer = class(TInterfacedObject, NuLib.Containers.Common.IEqualityComparer<Integer>)
  public
    function Equals(const Left, Right: Integer): Boolean; reintroduce;
    function GetHashCode(const Value: Integer): UInt32; reintroduce;
  end;

function IntegerEquals(const Left, Right: Integer): Boolean; inline;
begin
  result := Left = Right;
end;

function IntegerGetHashCode(const Value: Integer): UInt32; inline;
begin
  result := MurmurHash3(Value, SizeOf(Value), 0);
  //result := UInt32(Value) * 33 + 1;
  //result := UInt32(Value);
end;

{ TRefIntegerEqualityComparer }

function TRefIntegerEqualityComparer.Equals(const Left, Right: Integer): Boolean;
begin
  result := IntegerEquals(Left, Right);
end;

function TRefIntegerEqualityComparer.GetHashCode(const Value: Integer): Integer;
begin
  result := IntegerGetHashCode(Value);
//  result := MurmurFinalize(result);
end;

{ TIntegerEqualityComparer }

function TIntegerEqualityComparer.Equals(const Left, Right: Integer): Boolean;
begin
  result := IntegerEquals(Left, Right);
end;

function TIntegerEqualityComparer.GetHashCode(const Value: Integer): UInt32;
begin
  result := IntegerGetHashCode(Value);
end;




type
  TProcedure = reference to procedure;

// measure time taken to execute proc
function ExecTime(const proc: TProcedure): double;
var
  st, ft, f: int64;
begin
  QueryPerformanceFrequency(f);
  QueryPerformanceCounter(st);
  proc;
  QueryPerformanceCounter(ft);
  result := (ft - st) / f;
end;

procedure WordHist(const dict: IDict<String,Integer>; Words: TStrings); overload;
var
  s: string;
  c: integer;
begin
  for s in Words do
  begin
    c := dict[s];

    dict[s] := c + 1;
  end;
end;

procedure WordHist(const dict: IDict<TRec,Integer>; Words: TStrings); overload;
var
  r: TRec;
  s: string;
  c: integer;
begin
  for s in Words do
  begin
    r := TRec.Create(Length(s), s);

    c := dict[r];

    dict[r] := c + 1;
  end;
end;

procedure MakeWordlist;
var
  words, sl: TStringList;
  sr: TStreamReader;
  s: string;
  i: integer;
begin
  sr := TStreamReader.Create('primes1.txt');
  words := TStringList.Create;
  sl := TStringList.Create;
  sl.Delimiter := #9;
  sl.StrictDelimiter := False;
  sl.QuoteChar := #0;
  while not sr.EndOfStream do
  begin
    s := sr.ReadLine;
    for i := 1 to Length(s) do
    begin
      if not (TCharacter.IsLetterOrDigit(s[i])) then
        s[i] := ' ';
    end;
    sl.DelimitedText := s;
    words.Capacity := words.Capacity + sl.Count;
    for i := 0 to sl.Count-1 do
      if Trim(sl[i]) <> '' then
        words.Add(sl[i]);
  end;
  sr.Free;
  sl.Free;

  words.SaveToFile('words.txt');
  words.Free;
end;

procedure Test1;
var
  d1, d2: IDict<String,Integer>;
  words1, words2: TStringList;
  t1, t2: double;
begin
  WriteLn('Test1');

  d1 := TDictRefWrapper<String,Integer>.Create(TRefStringEqualityComparer.Create);
  d2 := TDictWrapper<String,Integer>.Create(TStringEqualityComparer.Create);

  words1 := TStringList.Create;
  words1.LoadFromFile('words.txt');

  words2 := TStringList.Create;
  words2.LoadFromFile('words1.txt');

  WriteLn('Reference');
  t1 := ExecTime(
    procedure
    var
      i: integer;
    begin
      WordHist(d1, words1);
      for i := 0 to words1.Count-1 do
        d1.Remove(words1[i]);
      d1.Clear;
      WordHist(d1, words2);
      WordHist(d1, words1);
      for i := 0 to words2.Count-1 do
        d1.Remove(words2[i]);
    end);
  WriteLn('New');
  t2 := ExecTime(
    procedure
    var
      i: integer;
    begin
      WordHist(d2, words1);
      for i := 0 to words1.Count-1 do
        d2.Remove(words1[i]);
      d2.Clear;
      WordHist(d2, words2);
      WordHist(d2, words1);
      for i := 0 to words2.Count-1 do
        d2.Remove(words2[i]);
    end);

  WriteLn(Format('Count: %d  %d', [d1.Count, d2.Count]));
  WriteLn(Format('Time: %8.2f  %8.2f', [t1, t2]));

  words1.Free;
  words2.Free;
end;

procedure Test2;
var
  d1, d2: IDict<TRec,Integer>;
  words1, words2: TStringList;
  t1, t2: double;
begin
  WriteLn('Test2');
  d1 := TDictRefWrapper<TRec,Integer>.Create(TRefRecEqualityComparer.Create);
  d2 := TDictWrapper<TRec,Integer>.Create(TRecEqualityComparer.Create);

  words1 := TStringList.Create;
  words1.LoadFromFile('words.txt');

  words2 := TStringList.Create;
  words2.LoadFromFile('words1.txt');

  WriteLn('Reference');
  t1 := ExecTime(
    procedure
    var
      i: integer;
    begin
      WordHist(d1, words1);
      for i := 0 to words1.Count-1 do
        d1.Remove(TRec.Create(Length(words1[i]), words1[i]));
      d1.Clear;
      WordHist(d1, words2);
      WordHist(d1, words1);
      for i := 0 to words2.Count-1 do
        d1.Remove(TRec.Create(Length(words2[i]), words2[i]));
    end);
  WriteLn('New');
  t2 := ExecTime(
    procedure
    var
      i: integer;
    begin
      WordHist(d2, words1);
      for i := 0 to words1.Count-1 do
        d2.Remove(TRec.Create(Length(words1[i]), words1[i]));
      d2.Clear;
      WordHist(d2, words2);
      WordHist(d2, words1);
      for i := 0 to words2.Count-1 do
        d2.Remove(TRec.Create(Length(words2[i]), words2[i]));
    end);

  WriteLn(Format('Count: %d  %d', [d1.Count, d2.Count]));
  WriteLn(Format('Time: %8.2f  %8.2f', [t1, t2]));

  words1.Free;
  words2.Free;
end;


procedure Sieve(dict: IDict<Integer,Boolean>; const N: integer);
var
  i, k: integer;
begin
  for i := 2 to N-1 do
  begin
    if dict[i] then // not prime, no need
      continue;
    k := i;
    while (k < N) do
    begin
      k := k + i;
      dict[k] := True; // mark powers as non-primes
    end;
  end;
end;

procedure Test3;
var
  d1, d2: IDict<Integer,Boolean>;
  t1, t2: double;
  N, i, p1, p2: integer;
begin
  WriteLn('Test3');
  //d1 := TDictRefWrapper<Integer,Boolean>.Create(TRefIntegerEqualityComparer.Create);
  d1 := TDictRefWrapper<Integer,Boolean>.Create;
  d2 := TDictWrapper<Integer,Boolean>.Create(TIntegerEqualityComparer.Create);

  //N := 1000000 + 70000;
  N := 10000000;
  WriteLn('Reference');
  t1 := ExecTime(
    procedure
    begin
      Sieve(d1, N);
    end);
  WriteLn('New');
  t2 := ExecTime(
    procedure
    begin
      Sieve(d2, N);
    end);

  p1 := 0;
  p2 := 0;
  for i := 2 to N-1 do
  begin
    if not d1[i] then
      p1 := p1 + 1;
    if not d2[i] then
      p2 := p2 + 1;
  end;

  WriteLn(Format('Count: %d  %d', [d1.Count, d2.Count]));
  WriteLn(Format('Primes: %d  %d', [p1, p2]));
  WriteLn(Format('Time: %8.2f  %8.2f', [t1, t2]));
end;


procedure RunTests;
begin
  FormatSettings.DecimalSeparator := '.';

  //MakeWordlist;
  //Test1;
  //Test2;
  Test3;
end;

end.
