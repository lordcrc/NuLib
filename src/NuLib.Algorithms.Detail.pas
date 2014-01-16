unit NuLib.Algorithms.Detail;

interface

uses
  System.Generics.Defaults;

type
  Sort<T> = record
    class procedure Sort(var Items: array of T; const Comparer: System.Generics.Defaults.IComparer<T>); static;
  end;

function IsNativeType(const TypInfo: pointer): boolean;

implementation

uses
  TypInfo,
  NuLib.Algorithms.Detail.MergeSort;

function IsNativeType(const TypInfo: pointer): boolean;
begin
  result := PTypeInfo(TypInfo)^.Kind in [tkInteger, tkChar, tkFloat, tkInt64, tkPointer];
end;

{ Sort<T> }

class procedure Sort<T>.Sort(var Items: array of T; const Comparer: System.Generics.Defaults.IComparer<T>);
begin
  if IsNativeType(TypeInfo(T)) then
//  if false then
    NuLib.Algorithms.Detail.MergeSort.SortImpl<T>.Sort(Items, Comparer)
  else
    NuLib.Algorithms.Detail.MergeSort.SortImplMove<T>.Sort(Items, Comparer);
end;

end.
