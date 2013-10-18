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

  ///	<summary>
  ///	  <para>
  ///	    An associative container.
  ///	  </para>
  ///	  <para>
  ///	    Provides fast key to value mapping.
  ///	  </para>
  ///	</summary>
  ///	<typeparam name="K">
  ///	  Key type
  ///	</typeparam>
  ///	<typeparam name="V">
  ///	  Value type
  ///	</typeparam>
  Dictionary<K, V> = record
  public
    type
      // this belongs in Detail, but due to type forwarding limitations
      // preventing Pair from being declared in Common it has to go here :(
      DictionaryElementEnumerator = class(TInterfacedObject, IEnumerator<Pair<K, V>>)
      strict private
        FDictEnum: NuLib.Containers.Detail.DictionaryElementViewEnumerator<K, V>;
      public
        constructor Create(const DictEnum: NuLib.Containers.Detail.DictionaryElementViewEnumerator<K, V>);

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
    ///	<summary>
    ///	  Removes all the elements in the dictionary.
    ///	</summary>
    procedure Clear;

    ///	<summary>
    ///	  Removes an element from the dictionary.
    ///	</summary>
    ///	<param name="Key">
    ///	  Key of the element to be removed.
    ///	</param>
    ///	<returns>
    ///	  True if the element was removed, false otherwise.
    ///	</returns>
    ///	<remarks>
    ///	  <para>
    ///	    Complexity (average): Constant.
    ///	  </para>
    ///	  <para>
    ///	    Complexity (worst-case): Linear in number of elements.
    ///	  </para>
    ///	</remarks>
    function Remove(const Key: K): Boolean;

    ///	<summary>
    ///	  Reserves capacity for a minmum number of elements.
    ///	</summary>
    ///	<param name="MinNewCapacity">
    ///	  Minimum number of elements the dictionary should be able to hold.
    ///	</param>
    ///	<remarks>
    ///	  <para>
    ///	    Complexity: Linear in number of elements if reallocation occurs.
    ///	  </para>
    ///	  <para>
    ///	    Reserving capacity does not guarantee that the dictionary will not
    ///	    reallocate memory when adding new elements, even though Count is
    ///	    less than MinNewCapacity.
    ///	  </para>
    ///	</remarks>
    procedure Reserve(const MinNewCapacity: UInt32);

    function GetEnumerator: DictionaryElementEnumerator;

    ///	<summary>
    ///	  Returns True if the dictionary is empty, otherwise False.
    ///	</summary>
    ///	<remarks>
    ///	  Complexity: Constant.
    ///	</remarks>
    property Empty: Boolean read GetEmpty;

    ///	<summary>
    ///	  Returns the number of elements in the dictionary.
    ///	</summary>
    ///	<value>
    ///	  Number of elements in the dictionary.
    ///	</value>
    ///	<remarks>
    ///	  Complexity: Constant.
    ///	</remarks>
    property Count: UInt32 read GetCount;

    ///	<summary>
    ///	  Returns the value of the element with the given key. If the element
    ///	  does not already exist in the dictionary, it is added, and the
    ///	  default value for type V is returned.
    ///	</summary>
    ///	<param name="Key">
    ///	  Key of the element.
    ///	</param>
    ///	<value>
    ///	  Value of the corresponding key.
    ///	</value>
    ///	<remarks>
    ///	  <para>
    ///	    Complexity (average): Constant.
    ///	  </para>
    ///	  <para>
    ///	    Complexity (worst-case): Linear in number of elements.
    ///	  </para>
    ///	  <para>
    ///	    May trigger reallocation (not included).
    ///	  </para>
    ///	</remarks>
    property Item[const Key: K]: V read GetItem write SetItem; default;

    ///	<summary>
    ///	  Checks if an element with the given key is present in the dictionary.
    ///	</summary>
    ///	<param name="Key">
    ///	  Key to look up.
    ///	</param>
    ///	<value>
    ///	  Returns True if the dictionary contains the element, False otherwise.
    ///	</value>
    ///	<remarks>
    ///	  <para>
    ///	    Complexity (average): Constant.
    ///	  </para>
    ///	  <para>
    ///	    Complexity (worst-case): Linear in number of elements.
    ///	  </para>
    ///	</remarks>
    property Contains[const Key: K]: Boolean read GetContains;

    ///	<summary>
    ///	  An enumerable for the keys in the dictionary.
    ///	</summary>
    ///	<remarks>
    ///	  The enumeration order is not defined, and typically does not
    ///	  correspond to the insertion order.
    ///	</remarks>
    property Keys: EnumeratorImpl<K> read GetKeys;

    ///	<summary>
    ///	  An enumerable for the values in the dictionary.
    ///	</summary>
    ///	<remarks>
    ///	  The enumeration order is not defined, and typically does not
    ///	  correspond to the insertion order.
    ///	</remarks>
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

{ Dictionary<K, V>.DictionaryElementEnumerator<K, V> }

constructor Dictionary<K, V>.DictionaryElementEnumerator.Create(
  const DictEnum: NuLib.Containers.Detail.DictionaryElementViewEnumerator<K, V>);
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
