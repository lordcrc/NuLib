//  Copyright 2013 Asbjørn Heid
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

unit NuLib.Containers;

interface

uses
  NuLib.Containers.Common,
  NuLib.Containers.Detail,
  NuLib.Containers.Detail.OpenAddressingInline,
  NuLib.Containers.Detail.OpenAddressingSeparate;

type
  Pair<T1, T2> = record
    Value1: T1;
    Value2: T2;

    constructor Create(const V1: T1; const V2: T2);

    property Key: T1 read value1 write value1;
    property Value: T2 read value2 write value2;

    property First: T1 read value1 write value1;
    property Second: T2 read value2 write value2;
  end;

  Dictionary<K, V> = record
  public
    type
      EnumeratorImpl<T> = record
      strict private
        FEnum: NuLib.IEnumerator<T>;
      public
        constructor Create(const Enum: NuLib.IEnumerator<T>);

        function GetEnumerator: NuLib.IEnumerator<T>;
      end;

      // this belongs in Detail, but due to type forwarding limitations
      // it has to go here :(
      DictionaryElementEnumerator = class(TInterfacedObject, IEnumerator<Pair<K, V>>)
      strict private
        FDictEnum: NuLib.Containers.Detail.DictionaryEnumerator<K, V>;
      public
        constructor Create(const DictEnum: NuLib.Containers.Detail.DictionaryEnumerator<K, V>);

        function GetCurrent: Pair<K, V>;
        function MoveNext: Boolean;
        procedure Reset;

        property Current: Pair<K, V> read GetCurrent;
      end;

  private
    type
//      TDictImpl = NuLib.Containers.Detail.OpenAddressingSeparate.Dictionary<K, V>;
      TDictImpl = NuLib.Containers.Detail.OpenAddressingInline.Dictionary<K, V>;
  strict private
    FDict: NuLib.Containers.Detail.IDictionaryImplementation<K,V>;

  private
    function GetCount: UInt32; inline;
    function GetItem(const Key: K): V; inline;
    procedure SetItem(const Key: K; const Value: V); inline;
    function GetEmpty: Boolean;
    function GetContains(const Key: K): Boolean;
    function GetKeys: EnumeratorImpl<K>;
    function GetValues: EnumeratorImpl<V>;

  public
    procedure Clear;
    function Remove(const Key: K): Boolean;

    procedure Reserve(const MinNewCapacity: UInt32);

    function GetEnumerator: DictionaryElementEnumerator;

    property Empty: Boolean read GetEmpty;
    property Count: UInt32 read GetCount;
    property Item[const Key: K]: V read GetItem write SetItem; default;
    property Contains[const Key: K]: Boolean read GetContains;
    property Keys: EnumeratorImpl<K> read GetKeys;
    property Values: EnumeratorImpl<V> read GetValues;

    class function Create: Dictionary<K, V>; overload; static;
    class function Create(const Comparer: NuLib.IEqualityComparer<K>): Dictionary<K, V>; overload; static;
    class function Create(const Comparison: NuLib.EqualityComparisonFunction<K>; const Hasher: NuLib.HashFunction<K>): Dictionary<K, V>; overload; static;
  end;

implementation

{ Pair<T1, T2> }

constructor Pair<T1, T2>.Create(const V1: T1; const V2: T2);
begin
  Value1 := V1;
  Value2 := V2;
end;

{ Dictionary<K, V> }

class function Dictionary<K, V>.Create: Dictionary<K, V>;
begin
  result.FDict := TDictImpl.Create(NuLib.Containers.Detail.EqualityComparerInstance<K>.Get());
end;

procedure Dictionary<K, V>.Clear;
begin
  FDict.Clear;
end;

class function Dictionary<K, V>.Create(const Comparer: NuLib.IEqualityComparer<K>): Dictionary<K, V>;
begin
  result.FDict := TDictImpl.Create(Comparer);
end;

class function Dictionary<K, V>.Create(const Comparison: NuLib.EqualityComparisonFunction<K>;
  const Hasher: NuLib.HashFunction<K>): Dictionary<K, V>;
begin
  result.FDict := TDictImpl.Create(NuLib.Containers.Common.DelegatedEqualityComparer<K>.Create(Comparison, Hasher));
end;

function Dictionary<K, V>.GetContains(const Key: K): Boolean;
begin
  result := FDict.Contains[Key];
end;

function Dictionary<K, V>.GetCount: UInt32;
begin
  result := FDict.Count;
end;

function Dictionary<K, V>.GetEmpty: Boolean;
begin
  result := FDict.Empty;
end;

function Dictionary<K, V>.GetEnumerator: DictionaryElementEnumerator;
begin
  result := DictionaryElementEnumerator.Create(FDict.GetEnumerator);
end;

function Dictionary<K, V>.GetItem(const Key: K): V;
begin
  result := FDict.Item[Key];
end;

function Dictionary<K, V>.GetKeys: EnumeratorImpl<K>;
begin
  result := EnumeratorImpl<K>.Create(NuLib.Containers.Detail.DictionaryKeyEnumerator<K,V>.Create(FDict.GetEnumerator));
end;

function Dictionary<K, V>.GetValues: EnumeratorImpl<V>;
begin
  result := EnumeratorImpl<V>.Create(NuLib.Containers.Detail.DictionaryValueEnumerator<K,V>.Create(FDict.GetEnumerator));
end;

function Dictionary<K, V>.Remove(const Key: K): Boolean;
begin
  result := FDict.Remove(Key);
end;

procedure Dictionary<K, V>.Reserve(const MinNewCapacity: UInt32);
begin
  FDict.Reserve(MinNewCapacity);
end;

procedure Dictionary<K, V>.SetItem(const Key: K; const Value: V);
begin
  FDict.Item[Key] := Value;
end;

{ Dictionary<K, V>.EnumeratorImpl<T> }

constructor Dictionary<K, V>.EnumeratorImpl<T>.Create(const Enum: NuLib.IEnumerator<T>);
begin
  FEnum := Enum;
end;

function Dictionary<K, V>.EnumeratorImpl<T>.GetEnumerator: NuLib.IEnumerator<T>;
begin
  result := FEnum;
end;

{ Dictionary<K, V>.DictionaryElementEnumerator<K, V> }

constructor Dictionary<K, V>.DictionaryElementEnumerator.Create(
  const DictEnum: NuLib.Containers.Detail.DictionaryEnumerator<K, V>);
begin
  inherited Create;

  FDictEnum := DictEnum;
end;

function Dictionary<K, V>.DictionaryElementEnumerator.GetCurrent: Pair<K, V>;
begin
  with FDictEnum.Current do
    result := Pair<K,V>.Create(KeyRef^, ValueRef^);
end;

function Dictionary<K, V>.DictionaryElementEnumerator.MoveNext: Boolean;
begin
  result := FDictEnum.MoveNext;
end;

procedure Dictionary<K, V>.DictionaryElementEnumerator.Reset;
begin
  FDictEnum.Reset;
end;

end.
