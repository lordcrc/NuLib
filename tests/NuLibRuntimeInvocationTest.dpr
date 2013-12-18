program NuLibRuntimeInvocationTest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  NuLib.RuntimeInvocation in '..\src\NuLib.RuntimeInvocation.pas',
  NuLib.RuntimeInvocation.Detail in '..\src\NuLib.RuntimeInvocation.Detail.pas',
  NuLib.RuntimeInvocation.Test in 'NuLib.RuntimeInvocation.Test.pas';

begin
  try
    RunTests;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  ReadLn;
end.
