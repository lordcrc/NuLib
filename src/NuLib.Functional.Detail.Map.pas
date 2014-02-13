unit NuLib.Functional.Detail.Map;

interface

uses
  NuLib.Functional.Common,
  NuLib.Functional.Detail;

type
  TMapEnumerator<T, R> = class(TInterfacedObject, IEnumeratorImpl<R>)
  private
    FSrc: IEnumeratorImpl<T>;
    FFunc: Func<T, R>;
  public
    constructor Create(const Src: IEnumeratorImpl<T>; const F: Func<T, R>);

    function GetCurrent: R;
    function MoveNext: Boolean;
  end;

  TMapEnumerable<T, R> = class(TInterfacedObject, IEnumerableImpl<R>)
  private
    FSrc: IEnumerableImpl<T>;
    FFunc: Func<T, R>;
  public
    constructor Create(const Src: IEnumerableImpl<T>; const F: Func<T, R>);

    function HasCount: boolean;
    function GetCount: NativeInt;
    function GetEnumerator: IEnumeratorImpl<R>;
  end;

implementation

{ TMapEnumerator<T, R> }

constructor TMapEnumerator<T, R>.Create(const Src: IEnumeratorImpl<T>; const F: Func<T, R>);
begin
  inherited Create;

  FSrc := Src;
  FFunc := F;
end;

function TMapEnumerator<T, R>.GetCurrent: R;
begin
  result := FFunc(FSrc.Current);
end;

function TMapEnumerator<T, R>.MoveNext: Boolean;
begin
  result := FSrc.MoveNext;
end;

{ TMapEnumerable<T, R> }

constructor TMapEnumerable<T, R>.Create(const Src: IEnumerableImpl<T>; const F: Func<T, R>);
begin
  inherited Create;

  FSrc := Src;
  FFunc := F;
end;

function TMapEnumerable<T, R>.GetCount: NativeInt;
begin
  result := FSrc.Count;
end;

function TMapEnumerable<T, R>.GetEnumerator: IEnumeratorImpl<R>;
var
  srcEnumerator: IEnumeratorImpl<T>;
begin
  srcEnumerator := FSrc.GetEnumerator();
  result := TMapEnumerator<T,R>.Create(srcEnumerator, FFunc);
end;

function TMapEnumerable<T, R>.HasCount: boolean;
begin
  result := FSrc.HasCount;
end;

end.
