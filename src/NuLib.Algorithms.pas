unit NuLib.Algorithms;

interface

uses
  System.Generics.Defaults;

type
  Alg = record
    class procedure Sort<T>(var Items: array of T; const Comparer: System.Generics.Defaults.IComparer<T>); overload; static;
    class procedure Sort<T>(var Items: array of T); overload; static;
  end;

implementation

uses
  NuLib.Algorithms.Detail,
  NuLib.Algorithms.Detail.MergeSort;

{ Alg }

class procedure Alg.Sort<T>(var Items: array of T; const Comparer: System.Generics.Defaults.IComparer<T>);
begin
  NuLib.Algorithms.Detail.Sort<T>.Sort(Items, Comparer);
end;

class procedure Alg.Sort<T>(var Items: array of T);
begin
  Alg.Sort<T>(Items, System.Generics.Defaults.TComparer<T>.Default);
end;

end.
