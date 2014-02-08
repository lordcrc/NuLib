unit NuLib.Functional.Detail.OrderedEnumerable;

interface

uses
  NuLib.Common,
  NuLib.Functional.Common,
  NuLib.Functional.Detail;

type
  TOrderedEnumerator<T> = class(TInterfacedObject, IEnumeratorImpl<T>)
  private
    FCur: NativeInt;
    FElements: TArray<T>;
  public
    constructor Create(const Elements: TArray<T>);

    function GetCurrent: T;
    function MoveNext: Boolean;
  end;


  TOrderedEnumerable<T> = class(TInterfacedObject, IOrderedEnumerableImpl<T>)
  private
    FSrc: IEnumerableImpl<T>;
    FElementComparer: NuLib.Common.IComparer<T>;
  public
    constructor Create(const Src: IEnumerableImpl<T>);

    procedure AddOrdering<K>(const KeySelector: Func<T, K>; const Comparer: IComparer<K>; Descending: boolean);

    function HasCount: boolean;
    function GetCount: NativeInt;

    function Instance: TObject;
    function GetEnumerator: IEnumeratorImpl<T>;
  end;

implementation

uses
  NuLib.Algorithms;

{ TOrderedEnumerator<T> }

constructor TOrderedEnumerator<T>.Create(const Elements: TArray<T>);
begin
  inherited Create;

  FElements := Elements;
  FCur := -1;
end;

function TOrderedEnumerator<T>.GetCurrent: T;
begin
  result := FElements[FCur];
end;

function TOrderedEnumerator<T>.MoveNext: Boolean;
begin
  result := FCur < Length(FElements);

  if not result then
    exit;

  FCur := FCur + 1;

  result := FCur < Length(FElements);
end;

{ TOrderedEnumerable<T> }

procedure TOrderedEnumerable<T>.AddOrdering<K>(const KeySelector: Func<T, K>; const Comparer: IComparer<K>;
  Descending: boolean);
var
  oldComparer, newComparer: IComparer<T>;
begin
  if Assigned(FElementComparer) then
  begin
    // avoid capture of FElementComparer
    oldComparer := FElementComparer;
    newComparer := DelegatedComparer<T>.Create(
      function(const Left, Right: T): integer
      begin
        result := oldComparer.Compare(Left, Right);
        if result <> 0 then
          exit;
        result := Comparer.Compare(KeySelector(Left), KeySelector(Right));
      end);
  end
  else
  begin
    // no previous ordering, impose one now
    newComparer := DelegatedComparer<T>.Create(
      function(const Left, Right: T): integer
      begin
        result := Comparer.Compare(KeySelector(Left), KeySelector(Right));
      end);
  end;

  FElementComparer := newComparer;
end;

constructor TOrderedEnumerable<T>.Create(const Src: IEnumerableImpl<T>);
begin
  inherited Create;

  FSrc := Src;
end;

function TOrderedEnumerable<T>.GetCount: NativeInt;
begin
  result := FSrc.Count;
end;

function TOrderedEnumerable<T>.GetEnumerator: IEnumeratorImpl<T>;
var
  i: NativeInt;
  elm: T;
  elms: TArray<T>;
begin
  i := 0;

  for elm in FSrc do
  begin
    if i >= Length(elms) then
      SetLength(elms, Length(elms) + 16);
    elms[i] := elm;
    i := i + 1;
  end;
  SetLength(elms, i);

  Alg.Sort<T>(elms, FElementComparer);

  result := TOrderedEnumerator<T>.Create(elms);
end;

function TOrderedEnumerable<T>.HasCount: boolean;
begin
  result := FSrc.HasCount;
end;

function TOrderedEnumerable<T>.Instance: TObject;
begin
  result := Self;
end;

end.
