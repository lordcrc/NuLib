unit NuLib.Functional.Test;

interface

procedure RunTests;

implementation

uses
  System.Classes,
  System.SysUtils,
  System.StrUtils,
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

    for s in src.Filter(pred) do
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

    src := Enumerable<string>.Wrap(sl);

    acc :=
      function(const acc: integer; const s: string): integer
      begin
        result := acc + StrToInt('$' + s);
      end;

    res := src.Aggregate<integer>(0, acc);

    WriteLn('12558 = ', res);
  finally
    src := nil;
    sl.Free;
  end;
end;

procedure RunTests;
begin
  Test1;
  Test2;
end;

end.
