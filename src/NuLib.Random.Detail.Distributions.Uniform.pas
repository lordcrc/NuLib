unit NuLib.Random.Detail.Distributions.Uniform;

interface

uses
  NuLib.Random.Common;

type
  UniformInt32Distribution = class(TInterfacedObject, Int32RandomDistribution)
  strict private
    FMinValue: Int32;
    FMaxValue: Int32;
    FDelta: UInt32;
    FFullRange: boolean;
    FRng: UInt32RandomEngine;
  public
    constructor Create(const MinValue, MaxValue: Int32; const RandomEngine: UInt32RandomEngine); overload;

    function Invoke: Int32;
  end;

implementation

{ UniformInt32Distribution }

constructor UniformInt32Distribution.Create(const MinValue, MaxValue: Int32; const RandomEngine: UInt32RandomEngine);
begin
  inherited Create;
  Assert(MinValue < MaxValue, 'Invalid range in UniformIntDistribution');

  FMinValue := MinValue;
  FMaxValue := MaxValue;
  FDelta := (FMaxValue - FMinValue) + 1;
  if (FDelta = 0) then
    FFullRange := True; // delta = 2^32

  FRng := RandomEngine;
end;

function UniformInt32Distribution.Invoke: Int32;
var
  v: UInt32;
begin
  v := FRng();
  if (FFullRange) then
  begin
    result := Int32(v);
    exit;
  end;

  v := v mod FDelta;
  result := FMinValue + Int32(v);
end;

end.
