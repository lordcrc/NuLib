unit NuLib.Functional.Detail.Zip;

interface

uses
  NuLib.Common,
  NuLib.Functional.Common,
  NuLib.Functional.Detail;

type
  TZipEnumerator<T1, T2> = class(TInterfacedObject, IEnumeratorImpl<Tuple<T1, T2>>)
  private
    FSrc1: IEnumeratorImpl<T1>;
    FSrc2: IEnumeratorImpl<T2>;
  public
    constructor Create(const Src1: IEnumeratorImpl<T1>; const Src2: IEnumeratorImpl<T2>);

    // Enumerator
    function GetCurrent: Tuple<T1, T2>;
    function MoveNext: Boolean;
  end;

  TZipLongestEnumerator<T1, T2> = class(TInterfacedObject, IEnumeratorImpl<Tuple<T1, T2>>)
  private
    FSrc1: IEnumeratorImpl<T1>;
    FSrc2: IEnumeratorImpl<T2>;
    FSrc1Done: boolean;
    FSrc2Done: boolean;
  public
    constructor Create(const Src1: IEnumeratorImpl<T1>; const Src2: IEnumeratorImpl<T2>);

    // Enumerator
    function GetCurrent: Tuple<T1, T2>;
    function MoveNext: Boolean;
  end;

  TZipEnumerable<T1, T2> = class(TInterfacedObject, IEnumerableImpl<Tuple<T1, T2>>)
  private
    FSrc1: IEnumerableImpl<T1>;
    FSrc2: IEnumerableImpl<T2>;
    FLongest: boolean;
  public
    constructor Create(const Src1: IEnumerableImpl<T1>; const Src2: IEnumerableImpl<T2>; const Longest: boolean);

    // Enumerable
    function HasCount: boolean;
    function GetCount: NativeInt;
    function GetEnumerator: IEnumeratorImpl<Tuple<T1, T2>>;
  end;

implementation

{ TZipEnumerator<T1, T2> }

constructor TZipEnumerator<T1, T2>.Create(const Src1: IEnumeratorImpl<T1>; const Src2: IEnumeratorImpl<T2>);
begin
  inherited Create;

  FSrc1 := Src1;
  FSrc2 := Src2;
end;

function TZipEnumerator<T1, T2>.GetCurrent: Tuple<T1, T2>;
begin
  Tuple<T1, T2>.Make(FSrc1.Current, FSrc2.Current, result);
end;

function TZipEnumerator<T1, T2>.MoveNext: Boolean;
begin
  result := FSrc1.MoveNext;
  // exploit boolean shortcut
  result := result and FSrc2.MoveNext;
end;

{ TZipLongestEnumerator<T1, T2> }

constructor TZipLongestEnumerator<T1, T2>.Create(const Src1: IEnumeratorImpl<T1>; const Src2: IEnumeratorImpl<T2>);
begin
  inherited Create;

  FSrc1 := Src1;
  FSrc2 := Src2;
end;

function TZipLongestEnumerator<T1, T2>.GetCurrent: Tuple<T1, T2>;
begin
  if (not FSrc1Done) and (not FSrc2Done) then
    Tuple<T1, T2>.Make(FSrc1.Current, FSrc2.Current, result)
  else if FSrc1Done and (not FSrc2Done) then
    Tuple<T1, T2>.Make(Default(T1), FSrc2.Current, result)
  else if (not FSrc1Done) and FSrc2Done then
    Tuple<T1, T2>.Make(FSrc1.Current, Default(T2), result)
  else
    Assert(False, 'TZipLongestEnumerator.GetCurrent called past end');
end;

function TZipLongestEnumerator<T1, T2>.MoveNext: Boolean;
begin
  // exploit boolean shortcut
  FSrc1Done := FSrc1Done or (not FSrc1.MoveNext);
  FSrc2Done := FSrc2Done or (not FSrc2.MoveNext);

  result := not (FSrc1Done and FSrc2Done);
end;

{ TZipEnumerable<T1, T2> }

constructor TZipEnumerable<T1, T2>.Create(const Src1: IEnumerableImpl<T1>; const Src2: IEnumerableImpl<T2>; const Longest: boolean);
begin
  inherited Create;

  FSrc1 := Src1;
  FSrc2 := Src2;
end;

function TZipEnumerable<T1, T2>.GetCount: NativeInt;
begin
  Assert(False, 'Not implemented');
end;

function TZipEnumerable<T1, T2>.GetEnumerator: IEnumeratorImpl<Tuple<T1, T2>>;
var
  srcEnumerator1: IEnumeratorImpl<T1>;
  srcEnumerator2: IEnumeratorImpl<T2>;
begin
  srcEnumerator1 := FSrc1.GetEnumerator();
  srcEnumerator2 := FSrc2.GetEnumerator();

  if FLongest then
    result := TZipLongestEnumerator<T1,T2>.Create(srcEnumerator1, srcEnumerator2)
  else
    result := TZipEnumerator<T1,T2>.Create(srcEnumerator1, srcEnumerator2);
end;

function TZipEnumerable<T1, T2>.HasCount: boolean;
begin
  result := False;
end;

end.
