unit NuLib.Functional.Detail.Aggregate;

interface

uses
  NuLib.Functional.Common,
  NuLib.Functional.Detail;

type
  AggregateImpl = record
    class function Compute<T>(const Src: IEnumerableImpl<T>; const AccumulateFunc: Func<T, T, T>): T; overload; static;
    class function Compute<T, TAccumulate>(const Src: IEnumerableImpl<T>; const InitialValue: TAccumulate; const AccumulateFunc: Func<TAccumulate, T, TAccumulate>): TAccumulate; overload; static;
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

class function AggregateImpl.Compute<T>(const Src: IEnumerableImpl<T>; const AccumulateFunc: Func<T, T, T>): T;
var
  initial: boolean;
  v: T;
begin
  result := Default(T);

  initial := true;
  for v in Src do
  begin
    if initial then
      result := v
    else
      result := AccumulateFunc(result, v);
    initial := false;
  end;
end;

end.
