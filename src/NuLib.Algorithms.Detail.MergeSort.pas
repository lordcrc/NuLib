unit NuLib.Algorithms.Detail.MergeSort;

interface

uses
  System.Generics.Defaults;

type
  SortImpl<T> = record
  private
    type
      TCompareFunc = function(const Left, Right: T): integer of object;
  private
    Items: ^T;
    Temp: ^T;
    Compare: TCompareFunc;
    procedure InsertionSort(const L, R: NativeInt);
    procedure SplitAndMerge(const L, R: NativeInt);
  public
    class procedure Sort(var Items: array of T; const Comparer: System.Generics.Defaults.IComparer<T>); static;
  end;

  SortImplMove<T> = record
  private
    type
      TCompareFunc = function(const Left, Right: T): integer of object;
  private
    Items: ^T;
    Temp: ^T;
    Compare: TCompareFunc;
    procedure InsertionSort(const L, R: NativeInt);
    procedure SplitAndMerge(const L, R: NativeInt);
  public
    class procedure Sort(var Items: array of T; const Comparer: System.Generics.Defaults.IComparer<T>); static;
  end;

procedure LocalMove(const Source; var Dest; Count: NativeInt); inline;

implementation

uses
  NuLib.Detail;

{$POINTERMATH ON}

procedure LocalMove(const Source; var Dest; Count: NativeInt); inline;
// Modified version of MoveJOH_PAS_10 from the FastMove library.
// The FastMove library is written by John O'Harrow.
type
  PUInt8 = ^UInt8;
  PUInt16 = ^UInt16;
  PUInt32 = ^UInt32;
  PUInt64 = ^UInt64;
var
  S, D: PUInt8;
begin
  S := PUInt8(@Source);
  D := PUInt8(@Dest);
  if Count = 0 then
    exit;
  if S = D then
    exit;
  case Count of
    1: D[0] := S[0];
    2: PUInt16(D)[0] := PUInt16(S)[0];
    4: PUInt32(D)[0] := PUInt32(S)[0];
    8: PUInt64(D)[0] := PUInt64(S)[0];
    16: begin
      PUInt64(D)[0] := PUInt64(S)[0];
      PUInt64(D)[1] := PUInt64(S)[1];
    end;
  else
    System.Move(Source, Dest, Count);
  end;
end;


{ SortImpl<T> }

procedure SortImpl<T>.InsertionSort(const L, R: NativeInt);
var
  i, j: NativeInt;
  i0, i1: NativeInt;
  temp: T;
begin
  for i := L+1 to R-1 do
  begin
    temp := Items[i];
    //LocalMove(Items[i], Temp[-1], SizeOf(T));
    i1 := i;
    while (i1 > L) do
    begin
      i0 := i1 - 1;

      if (Compare(Items[i0], temp) <= 0) then
      //if (Compare(Items[i0], Temp[-1]) <= 0) then
        break;

      Items[i1] := Items[i0];
      //LocalMove(Items[i0], Items[i1], SizeOf(T));
      i1 := i0;
    end;
    if (i1 <> i) then
      Items[i1] := temp;
      //LocalMove(Temp[-1], Items[i1], SizeOf(T));
  end;
end;

class procedure SortImpl<T>.Sort(var Items: array of T; const Comparer: System.Generics.Defaults.IComparer<T>);
var
  temp: TArray<T>;
  cmp: TCompareFunc;
  impl: SortImpl<T>;
begin
  SetLength(temp, Length(Items)+1);

  IntRefToMethPtr(Comparer, cmp, 3);

  impl.Items := @Items[0];
  impl.Temp := @temp[1];
  impl.Compare := cmp;

  impl.SplitAndMerge(0, Length(Items));

  FillChar(temp[0], SizeOf(T) * Length(temp), 0);
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
  i0 := L;
  i1 := M;

  for j := L to R-1 do
  begin
    if (i0 < M) and ((i1 >= R) or (Compare(Items[i0], Items[i1]) <= 0)) then
    begin
      Temp[j] := Items[i0];
      //LocalMove(Items[i0], Temp[j], SizeOf(T));
      inc(i0);
    end
    else
    begin
      Temp[j] := Items[i1];
      //LocalMove(Items[i1], Temp[j], SizeOf(T));
      inc(i1);
    end;
  end;

  // copy back to Items
//  for j := L to R-1 do
//    Items[j] := Temp[j];
  LocalMove(Temp[L], Items[L], (R-L) * SizeOf(T));
end;

{ SortImplMove<T> }

procedure SortImplMove<T>.InsertionSort(const L, R: NativeInt);
var
  i, j: NativeInt;
  i0, i1: NativeInt;
//  temp: T;
begin
  for i := L+1 to R-1 do
  begin
    //temp := Items[i];
    LocalMove(Items[i], Temp[-1], SizeOf(T));
    i1 := i;
    while (i1 > L) do
    begin
      i0 := i1 - 1;

      //if (Compare(Items[i0], temp) <= 0) then
      if (Compare(Items[i0], Temp[-1]) <= 0) then
        break;

      //Items[i1] := Items[i0];
      LocalMove(Items[i0], Items[i1], SizeOf(T));
      i1 := i0;
    end;
    if (i1 <> i) then
      //Items[i1] := temp;
      LocalMove(Temp[-1], Items[i1], SizeOf(T));
  end;
end;

class procedure SortImplMove<T>.Sort(var Items: array of T; const Comparer: System.Generics.Defaults.IComparer<T>);
var
  temp: TArray<T>;
  cmp: TCompareFunc;
  impl: SortImplMove<T>;
begin
  SetLength(temp, Length(Items)+1);

  IntRefToMethPtr(Comparer, cmp, 3);

  impl.Items := @Items[0];
  impl.Temp := @temp[1];
  impl.Compare := cmp;

  impl.SplitAndMerge(0, Length(Items));

  FillChar(temp[0], SizeOf(T) * Length(temp), 0);
end;

procedure SortImplMove<T>.SplitAndMerge(const L, R: NativeInt);
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
  i0 := L;
  i1 := M;

  for j := L to R-1 do
  begin
    if (i0 < M) and ((i1 >= R) or (Compare(Items[i0], Items[i1]) <= 0)) then
    begin
      //Temp[j] := Items[i0];
      LocalMove(Items[i0], Temp[j], SizeOf(T));
      inc(i0);
    end
    else
    begin
      //Temp[j] := Items[i1];
      LocalMove(Items[i1], Temp[j], SizeOf(T));
      inc(i1);
    end;
  end;

  // copy back to Items
//  for j := L to R-1 do
//    Items[j] := Temp[j];
  LocalMove(Temp[L], Items[L], (R-L) * SizeOf(T));
end;

end.
