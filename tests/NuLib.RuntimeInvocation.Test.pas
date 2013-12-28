unit NuLib.RuntimeInvocation.Test;

interface

procedure RunTests;

implementation

uses
  System.SysUtils, NuLib.RuntimeInvocation;

type
  IWidget = interface(IInvokable)
    function GetId: string;
    function WidgetType: string;

    property Id: string read GetId;
  end;

  TWidget = class(TInterfacedObject, IWidget)
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
  iw: IWidget;
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

    iw := TRoundWidget.Create('abc');

    f := RIConstructor.PropGetter<string>(TypeInfo(IWidget), 'Id');
    id := f(iw);
  finally
    widget.Free;
  end;
end;

procedure Test2;
var
  widget: IWidget;
  f: RIFunc<string>;
  id, wt: string;
begin
  widget := TRoundWidget.Create('abc');

  f := RIConstructor.PropGetter<string>(TypeInfo(IWidget), 'Id');
  id := f(widget);
  WriteLn(id);

  f := RIConstructor.Func<string>(TypeInfo(IWidget), 'WidgetType');
  wt := f(widget);
  WriteLn(wt);
end;

procedure RunTests;
begin
  Test1;
  Test2;
end;

end.
