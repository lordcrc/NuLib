unit NuLib.Functional.Test;

interface

procedure RunTests;

implementation

uses
  Winapi.Windows,
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  Spring.Collections,
  NuLib.Common,
  NuLib.Algorithms,
  NuLib.Functional.Common,
  NuLib.Functional;

procedure Test1;
var
  sl: TStringList;
  src: Enumerable<string>;
  s: string;
  pred: Predicate<string>;
  res: TArray<string>;
begin
  sl := nil;
  try
    sl := TStringList.Create;
    sl.Add('aaa');
    sl.Add('bbb');
    sl.Add('ccc');

    src := Enumerable<string>.Wrap(sl);

    pred :=
      function(const s: string): boolean
      begin
        result := not StartsText('b', s);
      end;

    res := Functional.Filter<string>(pred, src).ToArray();
    for s in res do
    begin
      WriteLn(s);
    end;
  finally
    src := nil;
    sl.Free;
  end;
end;

procedure Test2;
var
  sl: TStringList;
  src: Enumerable<string>;
  pred: Predicate<string>;
  acc: Func<integer, string, integer>;
  res: integer;
begin
  sl := nil;
  try
    sl := TStringList.Create;
    sl.Add('aaa');
    sl.Add('bbb');
    sl.Add('ccc');
    sl.Add('ddd');

    // wrap stringlist
    src := Enumerable<string>.Wrap(sl);

    // filter predicate
    pred :=
      function(const s: string): boolean
      begin
        result := not StartsText('b', s);
      end;

    // accumulator function
    acc :=
      function(const acc: integer; const s: string): integer
      begin
        result := acc + StrToInt('$' + s);
      end;

    res := Functional.Filter<string>(pred, src).Aggregate<integer>(0, acc);

    WriteLn('9555 = ', res);
  finally
    // release reference to the stringlist
    src := nil;
    sl.Free;
  end;
end;

procedure Test3;
var
  sl: TStringList;
  src: Enumerable<string>;
  f: Func<string, integer>;
  acc: Func<integer, integer, integer>;
  res: integer;
begin
  sl := nil;
  try
    sl := TStringList.Create;
    sl.Add('aaa');
    sl.Add('bbb');
    sl.Add('ccc');
    sl.Add('ddd');

    // wrap stringlist
    src := Enumerable<string>.Wrap(sl);

    // mapping function
    f :=
      function(const s: string): integer
      begin
        result := StrToInt('$' + s);
      end;

    // accumulator function
    acc :=
      function(const acc, v: integer): integer
      begin
        result := acc + v;
      end;

    res := Functional.Map<string, integer>(f, src).Aggregate<integer>(0, acc);

    WriteLn('12558 = ', res);
  finally
    // release reference to the stringlist
    src := nil;
    sl.Free;
  end;
end;

procedure Test4;
var
  list: Spring.Collections.IList<string>;
  src: Enumerable<string>;
  f: Func<string, integer>;
  acc: Func<integer, integer, integer>;
  res: integer;
begin
  list := nil;
  try
    list := Spring.Collections.TCollections.CreateList<string>(['aaa', 'bbb', 'ccc', 'ddd']);

    // wrap list
    src := Enumerable<string>.Wrap(list);

    // mapping function
    f :=
      function(const s: string): integer
      begin
        result := StrToInt('$' + s);
      end;

    // accumulator function
    acc :=
      function(const acc, v: integer): integer
      begin
        result := acc + v;
      end;

    res := Functional.Map<string, integer>(f, src).Aggregate<integer>(0, acc);

    WriteLn('12558 = ', res);
  finally
    // release reference to the list
    src := nil;
  end;
end;

procedure Test5;
var
  sl: TStringList;
  src: Enumerable<string>;
  ordered: Enumerable<string>;
  ks1: Func<string, string>;
  ks2: Func<string, integer>;
  s: string;
begin
  sl := nil;
  try
    sl := TStringList.Create;
    sl.Add('b.1');
    sl.Add('b.3');
    sl.Add('d.5');
    sl.Add('a.1');
    sl.Add('b.2');

    // wrap stringlist
    src := Enumerable<string>.Wrap(sl);

    ks1 :=
      function(const s: string): string
      begin
        result := Copy(s, 1, 1);
      end;
    ks2 :=
      function(const s: string): integer
      begin
        result := StrToInt(Copy(s, 3, 1));
      end;

    ordered := src.OrderBy<string>(ks1).ThenBy<integer>(ks2);

    for s in ordered do
    begin
      WriteLn(s);
    end;
  finally
    // release reference to the stringlist
    src := nil;
    sl.Free;
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

procedure Test6;
var
  sl, slt: TStringList;
  src: Enumerable<string>;
  ordered: Enumerable<string>;
  ks1: Func<string, string>;
  ks2: Func<string, integer>;
  cmp: NuLib.Common.IComparer<string>;
  elms: TArray<string>;
  t1, t2: double;
  i, v1, v2, v3: integer;
begin
  WriteLn;

  sl := nil;
  slt := nil;
  try
    slt := TStringList.Create;

    sl := TStringList.Create;
    RandSeed := 101;
    for i := 0 to 2000001 do
    begin
      v1 := Random(27);
      v2 := Random(27);
      v3 := Random(100);

      sl.Add(chr(ord('a') + v1) + chr(ord('a') + v2) + '.' + Format('%-.2d', [v3]));
    end;

    WriteLn('Sorting...');

    // wrap stringlist
    src := Enumerable<string>.Wrap(sl);

    cmp := DelegatedComparer<string>.Create(
      function (const Left, Right: string): integer
      var
        s1, s2: string;
        i1, i2: integer;
      begin
        s1 := Copy(Left, 1, 2);
        s2 := Copy(Right, 1, 2);

        result := CompareStr(s1, s2);
        if result <> 0 then
          exit;

        i1 := StrToInt(Copy(Left, 4, 2));
        i2 := StrToInt(Copy(Right, 4, 2));

        result := i2 - i1;
      end
    );

    elms := src.ToArray();
    slt.Capacity := sl.Count;
    t1 := ExecTime(
      procedure
      var
        s: string;
      begin
        Alg.Sort<string>(elms, cmp);

        for s in elms do
        begin
          slt.Add(s);
        end;
      end
    );
    slt.Clear;

    ks1 :=
      function(const s: string): string
      begin
        result := Copy(s, 1, 2);
      end;
    ks2 :=
      function(const s: string): integer
      begin
        result := StrToInt(Copy(s, 4, 2));
      end;

    ordered := src.OrderBy<string>(ks1).ThenBy<integer>(ks2);

    slt.Capacity := sl.Count;
    t2 := ExecTime(
      procedure
      var
        s: string;
      begin
        for s in ordered do
        begin
          slt.Add(s);
        end;
      end
    );
    slt.Clear;

    WriteLn(Format('Ref:  %5.3f', [t1]));
    WriteLn(Format('Func: %5.3f', [t2]));
  finally
    // release reference to the stringlist
    src := nil;
    sl.Free;
    slt.Free;
  end;
end;

procedure RunTests;
begin
  Test1;
  Test2;
  Test3;
  Test4;
  Test6;
end;

end.
