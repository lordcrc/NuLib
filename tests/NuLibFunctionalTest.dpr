program NuLibFunctionalTest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  NuLib.Functional.Test in 'NuLib.Functional.Test.pas',
  NuLib.Functional in '..\src\NuLib.Functional.pas',
  NuLib.Functional.Common in '..\src\NuLib.Functional.Common.pas',
  NuLib.Functional.Detail in '..\src\NuLib.Functional.Detail.pas',
  NuLib.Functional.Detail.EnumerableWrapper in '..\src\NuLib.Functional.Detail.EnumerableWrapper.pas',
  NuLib.Functional.Detail.Filter in '..\src\NuLib.Functional.Detail.Filter.pas',
  NuLib.Functional.Detail.Aggregate in '..\src\NuLib.Functional.Detail.Aggregate.pas';

begin
  try
    RunTests;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  ReadLn;
end.
