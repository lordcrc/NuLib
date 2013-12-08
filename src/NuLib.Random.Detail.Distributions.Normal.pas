unit NuLib.Random.Detail.Distributions.Normal;

interface

uses
  NuLib.Random.Common;

type
  NormalDistribution = class(TInterfacedObject, FloatRandomDistribution)
  strict private
    FMean: double;
    FSigma: double;
    FUseCached: boolean;
    FR1: double;
    FR2: double;
    FRho: double;
    FRng: FloatRandomEngine;
  public
    constructor Create(const Mean, Sigma: double; const RandomEngine: FloatRandomEngine); overload;

    function Invoke: double;
  end;

implementation

uses
  System.Math;

{ NormalDistribution }

constructor NormalDistribution.Create(const Mean, Sigma: double; const RandomEngine: FloatRandomEngine);
begin
  inherited Create;

  FMean := Mean;
  FSigma := Sigma;
  FRng := RandomEngine;
  FUseCached := False;
end;

function NormalDistribution.Invoke: double;
var
  theta: double;
begin
  // Based on Box-Muller transformation
  if FUseCached then
  begin
    FUseCached := False;
    theta := System.Cos(2.0 * System.Pi * FR2);
  end
  else
  begin
    FR1 := FRng();
    FR2 := FRng();

    // Box-Muller requires U1 \in (0, 1], so use 1-r1 instead
    FRho := System.Sqrt(-2.0 * System.Ln(1.0 - FR1));
    theta := System.Sin(2.0 * System.Pi * FR2);
  end;

  result := FRho * theta * FSigma + FMean;
end;

end.
