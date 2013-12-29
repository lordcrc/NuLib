unit NuLib.Functional.Test;

interface

procedure RunTests;

implementation

uses
  System.Classes,
  System.SysUtils,
  System.StrUtils,
  Spring.Collections,
  NuLib.Functional.Common,
  NuLib.Functional;

procedure Test1;
var
  sl: TStringList;
  src: Enumerable<string>;
  s: string;
  pred: Predicate<string>;
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

    for s in Functional.Filter<string>(pred, src) do
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

procedure RunTests;
begin
  Test1;
  Test2;
  Test3;
  Test4;
end;

end.
