program NuLibContainerTest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  WinApi.Windows,
  System.SysUtils,
  NuLib.Containers.Common in '..\src\NuLib.Containers.Common.pas',
  NuLib.Containers.Detail.OpenAddressingInline in '..\src\NuLib.Containers.Detail.OpenAddressingInline.pas',
  NuLib.Containers.Detail.OpenAddressingSeparate in '..\src\NuLib.Containers.Detail.OpenAddressingSeparate.pas',
  NuLib.Containers.Detail in '..\src\NuLib.Containers.Detail.pas',
  NuLib.Containers in '..\src\NuLib.Containers.pas',
  NuLib.Containers.Test in 'NuLib.Containers.Test.pas',
  NuLib.Common in '..\src\NuLib.Common.pas';

begin
  try
    RunTests;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
//  if IsDebuggerPresent then
  begin
    WriteLn('...');
    ReadLn;
  end;
end.
