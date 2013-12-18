unit NuLib.Functional.Test;

interface

procedure RunTests;

implementation

uses
  Classes,
  NuLib.Functional;

procedure Test1;
var
  sl: TStringList;
  src: Enumerable<string>;
  s: string;
begin
  sl := nil;
  try
    sl := TStringList.Create;
    sl.Add('aaa');
    sl.Add('bbb');
    sl.Add('ccc');

    src := Enumerable<string>.Wrap(sl);

    for s in src do
    begin
      WriteLn(s);
    end;
  finally
    sl.Free;
  end;
end;

procedure RunTests;
begin
  Test1;
end;

end.
