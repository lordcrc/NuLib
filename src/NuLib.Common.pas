unit NuLib.Common;

interface

uses
  System.Generics.Defaults;

type
  IComparer<T> = interface
    function Compare(const Left, Right: T): integer;
  end;

  ComparisonFunction<T> = reference to function(const Left, Right: T): integer;

  ComparerWrapper<T> = class(TInterfacedObject, IComparer<T>)
  private
    type
      TCompareMethod = function(const Left, Right: T): integer of object;
  private
    FIntfRef: System.Generics.Defaults.IComparer<T>;
    FCmp: TCompareMethod;
  public
    constructor Create(const Comparer: System.Generics.Defaults.IComparer<T>);

    function Compare(const Left, Right: T): integer;
  end;

  Comparer<T> = record
  public
    class function Default: NuLib.Common.IComparer<T>; static;
  end;

  DelegatedComparer<T> = class(TInterfacedObject, IComparer<T>)
  private
    FComparisonFunc: ComparisonFunction<T>;

    function Compare(const Left, Right: T): integer; reintroduce;
  public
    constructor Create(const ComparisonFunc: ComparisonFunction<T>);
  end;

  Tuple<T1, T2> = record
    V1: T1;
    V2: T2;

    class function Create(const V1: T1; const V2: T2): Tuple<T1, T2>; inline; static;
    class procedure Make(const V1: T1; const V2: T2; out Res: Tuple<T1, T2>); inline; static;
  end;

  Tuple<T1, T2, T3> = record
    V1: T1;
    V2: T2;
    V3: T3;

    class function Create(const V1: T1; const V2: T2; const V3: T3): Tuple<T1, T2, T3>; inline; static;
    class procedure Make(const V1: T1; const V2: T2; const V3: T3; out Res: Tuple<T1, T2, T3>); inline; static;
  end;

  Tuple<T1, T2, T3, T4> = record
    V1: T1;
    V2: T2;
    V3: T3;
    V4: T4;

    class function Create(const V1: T1; const V2: T2; const V3: T3; const V4: T4): Tuple<T1, T2, T3, T4>; inline; static;
    class procedure Make(const V1: T1; const V2: T2; const V3: T3; const V4: T4; out Res: Tuple<T1, T2, T3, T4>); inline; static;
  end;

  Tuple<T1, T2, T3, T4, T5> = record
    V1: T1;
    V2: T2;
    V3: T3;
    V4: T4;
    V5: T5;

    class function Create(const V1: T1; const V2: T2; const V3: T3; const V4: T4; const V5: T5): Tuple<T1, T2, T3, T4, T5>; inline; static;
    class procedure Make(const V1: T1; const V2: T2; const V3: T3; const V4: T4; const V5: T5; out Res: Tuple<T1, T2, T3, T4, T5>); inline; static;
  end;

implementation

uses
  NuLib.Detail;

{ ComparerWrapper<T> }

function ComparerWrapper<T>.Compare(const Left, Right: T): integer;
begin
  result := FCmp(Left, Right);
end;

constructor ComparerWrapper<T>.Create(const Comparer: System.Generics.Defaults.IComparer<T>);
begin
  inherited Create;

  FIntfRef := Comparer;

  IntRefToMethPtr(FIntfRef, FCmp, 3);
end;

{ Comparer<T> }

class function Comparer<T>.Default: NuLib.Common.IComparer<T>;
var
  i: System.Generics.Defaults.IComparer<T>;
begin
  i := System.Generics.Defaults.TComparer<T>.Default;
  result := ComparerWrapper<T>.Create(i);
end;

{ DelegatedComparer<T> }

function DelegatedComparer<T>.Compare(const Left, Right: T): integer;
begin
  result := FComparisonFunc(Left, Right);
end;

constructor DelegatedComparer<T>.Create(const ComparisonFunc: ComparisonFunction<T>);
begin
  inherited Create;
  FComparisonFunc := ComparisonFunc;
end;

{ Tuple<T1, T2> }

class function Tuple<T1, T2>.Create(const V1: T1; const V2: T2): Tuple<T1, T2>;
begin
  result.V1 := V1;
  result.V2 := V2;
end;

class procedure Tuple<T1, T2>.Make(const V1: T1; const V2: T2; out Res: Tuple<T1, T2>);
begin
  Res.V1 := V1;
  Res.V2 := V2;
end;

{ Tuple<T1, T2, T3> }

class function Tuple<T1, T2, T3>.Create(const V1: T1; const V2: T2; const V3: T3): Tuple<T1, T2, T3>;
begin
  result.V1 := V1;
  result.V2 := V2;
  result.V3 := V3;
end;

class procedure Tuple<T1, T2, T3>.Make(const V1: T1; const V2: T2; const V3: T3; out Res: Tuple<T1, T2, T3>);
begin
  Res.V1 := V1;
  Res.V2 := V2;
  Res.V3 := V3;
end;

{ Tuple<T1, T2, T3, T4> }

class function Tuple<T1, T2, T3, T4>.Create(const V1: T1; const V2: T2; const V3: T3;
  const V4: T4): Tuple<T1, T2, T3, T4>;
begin
  result.V1 := V1;
  result.V2 := V2;
  result.V3 := V3;
  result.V4 := V4;
end;

class procedure Tuple<T1, T2, T3, T4>.Make(const V1: T1; const V2: T2; const V3: T3; const V4: T4;
  out Res: Tuple<T1, T2, T3, T4>);
begin
  Res.V1 := V1;
  Res.V2 := V2;
  Res.V3 := V3;
  Res.V4 := V4;
end;

{ Tuple<T1, T2, T3, T4, T5> }

class function Tuple<T1, T2, T3, T4, T5>.Create(const V1: T1; const V2: T2; const V3: T3; const V4: T4;
  const V5: T5): Tuple<T1, T2, T3, T4, T5>;
begin
  result.V1 := V1;
  result.V2 := V2;
  result.V3 := V3;
  result.V4 := V4;
  result.V5 := V5;
end;

class procedure Tuple<T1, T2, T3, T4, T5>.Make(const V1: T1; const V2: T2; const V3: T3; const V4: T4; const V5: T5;
  out Res: Tuple<T1, T2, T3, T4, T5>);
begin
  Res.V1 := V1;
  Res.V2 := V2;
  Res.V3 := V3;
  Res.V4 := V4;
  Res.V5 := V5;
end;

end.
