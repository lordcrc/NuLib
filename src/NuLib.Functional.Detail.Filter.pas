unit NuLib.Functional.Detail.Filter;

interface

uses
  NuLib.Functional.Common,
  NuLib.Functional.Detail;

type
  TFilterImpl<T> = class(TInterfacedObject, IEnumerableImpl<T>, IEnumeratorImpl<T>)
  private
    FSrc: IEnumerableImpl<T>;
    FSrcEnumerator: IEnumeratorImpl<T>;
    FPredicate: Predicate<T>;
  public
    constructor Create(const Src: IEnumerableImpl<T>; const Predicate: Predicate<T>);

    // Enumerator
    function GetCurrent: T;
    function MoveNext: Boolean;

    // Enumerable
    function GetEnumerator: IEnumeratorImpl<T>;
  end;

implementation

{ TFilterImpl<T> }

constructor TFilterImpl<T>.Create(const Src: IEnumerableImpl<T>; const Predicate: Predicate<T>);
begin
  inherited Create;

  FSrc := Src;
  FPredicate := Predicate;
end;

function TFilterImpl<T>.GetCurrent: T;
begin
  result := FSrcEnumerator.Current;
end;

function TFilterImpl<T>.GetEnumerator: IEnumeratorImpl<T>;
begin
  FSrcEnumerator := FSrc.GetEnumerator();
  result := Self;
end;

function TFilterImpl<T>.MoveNext: Boolean;
begin
  result := false;

  while FSrcEnumerator.MoveNext do
  begin
    result := FPredicate(FSrcEnumerator.Current);
    if result then
      break;
  end;
end;

end.
