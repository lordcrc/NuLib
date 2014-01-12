unit NuLib.Algorithms.Detail.MergeSort;

interface

uses
  System.Generics.Defaults;

type
  SortImpl<T> = record
  private
    type
      TCompareFunc = function(const Left, Right: T): integer of object;
      TItemsArray = array[0..0] of T;
      PItemsArray = ^TItemsArray;
  private
    Items: PItemsArray;
    Temp: PItemsArray;
    Compare: TCompareFunc;
    procedure InsertionSort(const L, R: NativeInt);
    procedure SplitAndMerge(const L, R: NativeInt);
  public
    class procedure Sort(var Items: array of T; const Comparer: System.Generics.Defaults.IComparer<T>); static;
  end;

implementation

uses
  NuLib.Detail;

{ SortImpl<T> }

procedure SortImpl<T>.InsertionSort(const L, R: NativeInt);
var
  i, j: integer;
  pL, p0, p1: ^T;
  temp: T;
begin
  pL := @Items^[L];
  for i := L+1 to R-1 do
  begin
    temp := Items^[i];
    p1 := @Items^[i];
    while (NativeUInt(p1) > NativeUInt(pL)) do
    begin
      p0 := p1;
      dec(p0);

      if (Compare(p0^, temp) <= 0) then
        break;

      p1^ := p0^;
      p1 := p0;
    end;
    if (p1 <> @Items^[i]) then
      p1^ := temp;
  end;
end;

class procedure SortImpl<T>.Sort(var Items: array of T; const Comparer: System.Generics.Defaults.IComparer<T>);
var
  temp: TArray<T>;
  cmp: TCompareFunc;
  impl: SortImpl<T>;
begin
  SetLength(temp, Length(Items));

  IntRefToMethPtr(Comparer, cmp, 3);

  impl.Items := @Items[0];
  impl.Temp := @temp[0];
  impl.Compare := cmp;

  impl.SplitAndMerge(0, Length(Items));
end;

procedure SortImpl<T>.SplitAndMerge(const L, R: NativeInt);
const
  SMALL_CUTOFF = 8;
var
  m: NativeInt;
  i0, i1, j: NativeInt;
  p0, p1, pL, pM, pR: ^T;
begin
  m := (L + R) shr 1;

  if (m - L) > SMALL_CUTOFF then
    SplitAndMerge(L, m)
  else if (m - L) > 1 then
    InsertionSort(L, m);

  if (R - m) > SMALL_CUTOFF then
    SplitAndMerge(m, R)
  else if (R - m) > 1 then
    InsertionSort(m, R);

  // merge into Temp
  //i0 := L;
  //i1 := M;
  pL := @Items^[L];
  pM := @Items^[m];
  pR := @Items^[R];

  p0 := pL;
  p1 := pM;

  for j := L to R-1 do
  begin
    //if (i0 < M) and ((i1 >= R) or (Comparer.Compare(Items[i0], Items[i1]) <= 0)) then
    if (NativeUInt(p0) < NativeUInt(pM)) and ((NativeUInt(p1) >= NativeUInt(pR)) or (Compare(p0^, p1^) <= 0)) then
    begin
      Temp^[j] := p0^;
      inc(p0);
    end
    else
    begin
      Temp^[j] := p1^;
      inc(p1);
    end;
  end;

  // copy back to Items
  for j := L to R-1 do
    Items^[j] := Temp^[j];
end;

end.
