unit NuLib.Algorithms.Detail.MergeSort;

interface

uses
  System.Generics.Defaults;

type
  MergeSortImpl<T> = record
  private
    class procedure SplitAndMerge(var Items, Temp: array of T; const L, R: NativeInt; const Comparer: System.Generics.Defaults.IComparer<T>); static;
  public
    class procedure Sort(var Items: array of T; const Comparer: System.Generics.Defaults.IComparer<T>); static;
  end;

implementation

{ MergeSortImpl<T> }

class procedure MergeSortImpl<T>.Sort(var Items: array of T; const Comparer: System.Generics.Defaults.IComparer<T>);
var
  temp: TArray<T>;
begin
  SetLength(temp, Length(Items));
  SplitAndMerge(Items, temp, 0, Length(Items), Comparer);
end;

class procedure MergeSortImpl<T>.SplitAndMerge(var Items, Temp: array of T; const L, R: NativeInt;
  const Comparer: System.Generics.Defaults.IComparer<T>);
var
  m: NativeInt;
  i0, i1, j: NativeInt;
  p0, p1, pL, pM, pR: ^T;
begin
  m := (L + R) shr 1;

  if (m - L) > 1 then
    SplitAndMerge(Items, Temp, L, m, Comparer);
  if (R - m) > 1 then
    SplitAndMerge(Items, Temp, m, R, Comparer);

  // merge into Temp
  //i0 := L;
  //i1 := M;
  pL := @Items[L];
  pM := @Items[m];
  pR := @Items[R];

  p0 := pL;
  p1 := pM;

  for j := L to R-1 do
  begin
    //if (i0 < M) and ((i1 >= R) or (Comparer.Compare(Items[i0], Items[i1]) <= 0)) then
    if (NativeUInt(p0) < NativeUInt(pM)) and ((NativeUInt(p1) >= NativeUInt(pR)) or (Comparer.Compare(p0^, p1^) <= 0)) then
    begin
      Temp[j] := p0^;
      inc(p0);
    end
    else
    begin
      Temp[j] := p1^;
      inc(p1);
    end;
  end;

  // copy back to Items
  for j := L to R-1 do
    Items[j] := Temp[j];
end;

end.
