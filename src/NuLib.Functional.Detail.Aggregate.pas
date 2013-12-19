unit NuLib.Functional.Detail.Aggregate;

interface

uses
  NuLib.Functional.Common,
  NuLib.Functional.Detail;

type
  AggregateImpl = record
    class function Compute<T, TAccumulate>(const Src: IEnumerableImpl<T>; const InitialValue: TAccumulate; const AccumulateFunc: Func<TAccumulate, T, TAccumulate>): TAccumulate; static;
  end;

implementation

{ AggregateImpl }

class function AggregateImpl.Compute<T, TAccumulate>(const Src: IEnumerableImpl<T>; const InitialValue: TAccumulate;
  const AccumulateFunc: Func<TAccumulate, T, TAccumulate>): TAccumulate;
var
  v: T;
begin
  result := InitialValue;

  for v in Src do
  begin
    result := AccumulateFunc(result, v);
  end;
end;

end.
