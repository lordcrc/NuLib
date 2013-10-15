program NuContainerTest;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  WinApi.Windows,
  System.SysUtils,
  NuContainers in 'NuContainers.pas',
  NuContainers.Common in 'NuContainers.Common.pas',
  NuContainers.Detail in 'NuContainers.Detail.pas',
  NuContainers.Test in 'NuContainers.Test.pas',
  NuContainers.Detail.OpenAddressingInline in 'NuContainers.Detail.OpenAddressingInline.pas',
  NuContainers.Detail.OpenAddressingSeparate in 'NuContainers.Detail.OpenAddressingSeparate.pas';

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
