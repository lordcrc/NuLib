program NuLibRandomTest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  WinAPI.Windows,
  System.SysUtils,
  NuLib.Random.Tests in 'NuLib.Random.Tests.pas',
  NuLib.Random in '..\src\NuLib.Random.pas',
  NuLib.Random.Detail in '..\src\NuLib.Random.Detail.pas',
  NuLib.Random.Common in '..\src\NuLib.Random.Common.pas',
  NuLib.Random.Detail.Engines.LinearShiftRegister in '..\src\NuLib.Random.Detail.Engines.LinearShiftRegister.pas',
  NuLib.Random.Detail.Engines in '..\src\NuLib.Random.Detail.Engines.pas',
  NuLib.Random.Detail.Distributions in '..\src\NuLib.Random.Detail.Distributions.pas',
  NuLib.Random.Detail.Distributions.Uniform in '..\src\NuLib.Random.Detail.Distributions.Uniform.pas',
  NuLib.Random.Detail.Distributions.Normal in '..\src\NuLib.Random.Detail.Distributions.Normal.pas';

begin
  try
    RunTests;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
  if IsDebuggerPresent then
  begin
    WriteLn('...');
    ReadLn;
  end;
end.
