unit NuLib.Functional.Detail.Map;

interface

uses
  NuLib.Functional.Common,
  NuLib.Functional.Detail;

type
  TMapImpl<T, R> = class(TInterfacedObject, IEnumerableImpl<R>, IEnumeratorImpl<R>)
  private
    FSrc: IEnumerableImpl<T>;
    FSrcEnumerator: IEnumeratorImpl<T>;
    FFunc: Func<T, R>;
  public
    constructor Create(const Src: IEnumerableImpl<T>; const F: Func<T, R>);

    // Enumerator
    function GetCurrent: R;
    function MoveNext: Boolean;

    // Enumerable
    function HasCount: boolean;
    function GetCount: NativeInt;
    function GetEnumerator: IEnumeratorImpl<R>;
  end;

implementation

{ TMapImpl<T, R> }

constructor TMapImpl<T, R>.Create(const Src: IEnumerableImpl<T>; const F: Func<T, R>);
begin
  inherited Create;

  FSrc := Src;
  FFunc := F;
end;

function TMapImpl<T, R>.GetCount: NativeInt;
begin
  Assert(False, 'Not implemented');
end;

function TMapImpl<T, R>.GetCurrent: R;
begin
  result := FFunc(FSrcEnumerator.Current);
end;

function TMapImpl<T, R>.GetEnumerator: IEnumeratorImpl<R>;
begin
  FSrcEnumerator := FSrc.GetEnumerator();
  result := Self;
end;

function TMapImpl<T, R>.HasCount: boolean;
begin
  result := False;
end;

function TMapImpl<T, R>.MoveNext: Boolean;
begin
  result := FSrcEnumerator.MoveNext;
end;

end.
