program NuLibAlgorithmsTest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  NuLib.Algorithms.Test in 'NuLib.Algorithms.Test.pas',
  NuLib.Algorithms in '..\src\NuLib.Algorithms.pas',
  NuLib.Algorithms.Detail in '..\src\NuLib.Algorithms.Detail.pas',
  NuLib.Algorithms.Detail.MergeSort in '..\src\NuLib.Algorithms.Detail.MergeSort.pas',
  NuLib.Common in '..\src\NuLib.Common.pas';

begin
  try
    RunTests;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  ReadLn;
end.
