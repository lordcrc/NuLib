unit NuLib.RuntimeInvocation.Test;

interface

procedure RunTests;

implementation

uses
  System.SysUtils, NuLib.RuntimeInvocation;

type
  TWidget = class
  private
    FId: string;
    function GetId: string;
  public
    constructor Create(const Id: string);
    function WidgetType: string; virtual; abstract;

    property Id: string read GetId;
  end;

  TRoundWidget = class(TWidget)
    constructor Create(const Id: string);
    function WidgetType: string; override;
  end;

{ TWidget }

constructor TWidget.Create(const Id: string);
begin
  inherited Create;

  FId := Id;
end;

function TWidget.GetId: string;
begin
  result := FId;
end;

{ TRoundWidget }

constructor TRoundWidget.Create(const Id: string);
begin
  inherited;
end;

function TRoundWidget.WidgetType: string;
begin
  result := 'Round';
end;

procedure Test1;
var
  widget: TWidget;
  f: RIFunc<string>;
  id, wt: string;
begin
  widget := nil;
  try
    widget := TRoundWidget.Create('42');

    f := RIConstructor<TWidget>.PropGetter<string>('Id');
    id := f(widget);
    WriteLn(id);

    f := RIConstructor.Func<string>(TypeInfo(TWidget), 'WidgetType');
    wt := f(widget);
    WriteLn(wt);
  finally
    widget.Free;
  end;
end;

procedure RunTests;
begin
  Test1;
end;

end.
