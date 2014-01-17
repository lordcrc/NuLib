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

end.
