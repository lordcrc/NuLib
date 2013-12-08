unit NuLib.Random.Tests;

interface

procedure RunTests;

implementation

uses
  System.Math,
  NuLib.Random;

procedure Test1;
var
  rng: UInt32RandomEngine;
  dist: Int32RandomDistribution;
  hist: array[-10..10] of UInt32;
  i, v, avg: Int32;
  dev: double;
begin
  rng := LSR32Engine();
  dist := UniformDistribution(Low(hist), High(hist), rng);

  FillChar(hist, sizeof(hist), 0);

  for i := 0 to 9999999 do
  begin
    v := dist();
    hist[v] := hist[v] + 1;
  end;

  v := 0;
  for i := Low(hist) to High(hist) do
  begin
    v := v + hist[i];
  end;
  avg := v div (High(hist) - Low(Hist) + 1);

  for i := Low(hist) to High(hist) do
  begin
    dev := (hist[i] - avg) / avg;
    WriteLn(dev);
  end;
end;

procedure Test2;
begin
end;

procedure RunTests;
begin
  Test1;
  Test2;
end;

end.
