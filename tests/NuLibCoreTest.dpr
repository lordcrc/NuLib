program NuLibCoreTest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  NuLib.Test in 'NuLib.Test.pas',
  NuLib.Detail in '..\src\NuLib.Detail.pas';

begin
  try
    RunTests;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  ReadLn;
end.
