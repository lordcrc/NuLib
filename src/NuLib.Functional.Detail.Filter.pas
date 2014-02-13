unit NuLib.Functional.Detail.Filter;

interface

uses
  NuLib.Functional.Common,
  NuLib.Functional.Detail;

type
  TFilterEnumerator<T> = class(TInterfacedObject, IEnumeratorImpl<T>)
  private
    FSrc: IEnumeratorImpl<T>;
    FPredicate: Predicate<T>;
  public
    constructor Create(const Src: IEnumeratorImpl<T>; const Predicate: Predicate<T>);

    function GetCurrent: T;
    function MoveNext: Boolean;
  end;

  TFilterEnumerable<T> = class(TInterfacedObject, IEnumerableImpl<T>)
  private
    FSrc: IEnumerableImpl<T>;
    FPredicate: Predicate<T>;
  public
    constructor Create(const Src: IEnumerableImpl<T>; const Predicate: Predicate<T>);

    function HasCount: boolean;
    function GetCount: NativeInt;
    function GetEnumerator: IEnumeratorImpl<T>;
  end;

implementation

{ TFilterEnumerator<T> }

constructor TFilterEnumerator<T>.Create(const Src: IEnumeratorImpl<T>; const Predicate: Predicate<T>);
begin
  inherited Create;

  FSrc := Src;
  FPredicate := Predicate;
end;

function TFilterEnumerator<T>.GetCurrent: T;
begin
  result := FSrc.Current;
end;

function TFilterEnumerator<T>.MoveNext: Boolean;
begin
  result := false;

  while FSrc.MoveNext do
  begin
    result := FPredicate(FSrc.Current);
    if result then
      break;
  end;
end;

{ TFilterEnumerable<T> }

constructor TFilterEnumerable<T>.Create(const Src: IEnumerableImpl<T>; const Predicate: Predicate<T>);
begin
  inherited Create;

  FSrc := Src;
  FPredicate := Predicate;
end;

function TFilterEnumerable<T>.GetCount: NativeInt;
begin
  Assert(False, 'Not implemented');
end;

function TFilterEnumerable<T>.GetEnumerator: IEnumeratorImpl<T>;
var
  srcEnumerator: IEnumeratorImpl<T>;
begin
  srcEnumerator := FSrc.GetEnumerator();
  result := TFilterEnumerator<T>.Create(srcEnumerator, FPredicate);
end;

function TFilterEnumerable<T>.HasCount: boolean;
begin
  result := False;
end;

end.
