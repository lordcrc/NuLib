unit NuLib.Algorithms.Test;

interface

procedure RunTests;

implementation

uses
  WinAPI.Windows,
  System.SysUtils,
  System.Generics.Defaults,
  System.Generics.Collections,
  NuLib.Algorithms;

procedure Test1;
var
  src, s1, s2: TArray<integer>;
  i, e: integer;
begin
  SetLength(src, 10001);
  //SetLength(src, 7);

  RandSeed := 101;
  for i := 0 to High(src) do
    src[i] := Random(Length(src) div 2);

  s1 := Copy(src);
  TArray.Sort<integer>(s1);

  s2 := Copy(src);
  Alg.Sort<integer>(s2);

  e := 0;
  for i := 0 to High(src) do
  begin
    if s1[i] = s2[i] then
      continue;

    e := e + 1;
    WriteLn(Format('%5d: %6d <> %6d', [i, s1[i], s2[i]]));
  end;

  if e = 0 then
  begin
    WriteLn('Equal');
  end;
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

type
  TRec = record
    key, value: integer;
  end;

procedure Test2;
var
  cmp: System.Generics.Defaults.IComparer<TRec>;
  s: TArray<TRec>;
  i, e: integer;
begin
  SetLength(s, 10001);

  RandSeed := 101;
  for i := 0 to High(s) do
  begin
    s[i].key := i;
    s[i].value := Random(Length(s) div 3);
  end;

  cmp := TDelegatedComparer<TRec>.Create(
      function (const Left, Right: TRec): integer
      begin
        result := Right.value - Left.value;
      end
    );

  //TArray.Sort<TRec>(s, cmp); // not stable
  Alg.Sort<TRec>(s, cmp);

  e := 0;
  for i := 1 to High(s) do
  begin
    if s[i-1].value <> s[i].value then
      continue;

    if s[i-1].key < s[i].key then
      continue;

    e := e + 1;
  end;

  if (e = 0) then
    WriteLn('Stable')
  else
    WriteLn('NOT STABLE');
end;

procedure Test3;
type
  IntType = int64;
var
  src, s1, s2: TArray<IntType>;
  i, e: integer;
  t1, t2: double;
begin
  SetLength(src, (1 shl 24) - 1);

  RandSeed := 101;
  for i := 0 to High(src) do
    src[i] := Random(Length(src) shr 4);

  WriteLn('Timing integers...');

  s1 := Copy(src);
  t1 := ExecTime(
      procedure
      begin
        TArray.Sort<IntType>(s1);
      end
    );
  WriteLn(Format('Reference: %5.3f', [t1]));

  s2 := Copy(src);
  t2 := ExecTime(
      procedure
      begin
        Alg.Sort<IntType>(s2);
      end
    );
  WriteLn(Format('Alg.Sort: %5.3f', [t2]));

  e := 0;
  for i := 0 to High(src) do
  begin
    if s1[i] = s2[i] then
      continue;

    e := e + 1;
  end;

  if e <> 0 then
  begin
    WriteLn('NOT EQUAL');
    exit;
  end;
end;

procedure Test4;
var
  src, s1, s2: TArray<string>;
  i, e: integer;
  t1, t2: double;
begin
  SetLength(src, (1 shl 21) - 1);

  RandSeed := 101;
  for i := 0 to High(src) do
    src[i] := IntToStr(Random(Length(src) shr 4));

  WriteLn('Timing strings...');

  s1 := Copy(src);
  t1 := ExecTime(
      procedure
      begin
        TArray.Sort<string>(s1);
      end
    );
  WriteLn(Format('Reference: %5.3f', [t1]));

  s2 := Copy(src);
  t2 := ExecTime(
      procedure
      begin
        Alg.Sort<string>(s2);
      end
    );
  WriteLn(Format('Alg.Sort: %5.3f', [t2]));

  e := 0;
  for i := 0 to High(src) do
  begin
    if s1[i] = s2[i] then
      continue;

    e := e + 1;
  end;

  if e <> 0 then
  begin
    WriteLn('NOT EQUAL');
    exit;
  end;
end;

procedure Test5;
type
  TStruct = record
    key: integer;
    value: string;
    payload: array[0..15] of UInt8;
  end;
var
  src, s1, s2: TArray<TStruct>;
  cmp: System.Generics.Defaults.IComparer<TStruct>;
  i, e: integer;
  t1, t2: double;
begin
  SetLength(src, (1 shl 21) - 1);

  RandSeed := 101;
  for i := 0 to High(src) do
  begin
    src[i].key := Random(Length(src) shr 4);
    src[i].value := IntToStr(src[i].key);
  end;

  cmp := TDelegatedComparer<TStruct>.Create(
      function (const Left, Right: TStruct): integer
      begin
        result := Right.key - Left.key;
      end
    );

  WriteLn('Timing struct...');

  s1 := Copy(src);
  t1 := ExecTime(
      procedure
      begin
        TArray.Sort<TStruct>(s1);
      end
    );
  WriteLn(Format('Reference: %5.3f', [t1]));

  s2 := Copy(src);
  t2 := ExecTime(
      procedure
      begin
        Alg.Sort<TStruct>(s2);
      end
    );
  WriteLn(Format('Alg.Sort: %5.3f', [t2]));

  e := 0;
  for i := 0 to High(src) do
  begin
    if s1[i].key = s2[i].key then
      continue;

    e := e + 1;
  end;

  if e <> 0 then
  begin
    WriteLn('NOT EQUAL');
    exit;
  end;
end;
procedure RunTests;
begin
  Test1;
  Test2;
  Test3;
  Test4;
  Test5;
end;

end.
