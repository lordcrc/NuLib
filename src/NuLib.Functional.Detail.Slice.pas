unit NuLib.Functional.Detail.Slice;

interface

uses
  NuLib.Functional.Common,
  NuLib.Functional.Detail;

type
  TSliceEnumerator<T> = class(TInterfacedObject, IEnumeratorImpl<T>)
  private
    FSrc: IEnumeratorImpl<T>;
    FCurIdx: NativeInt;
    FStart: NativeInt;
    FStop: NativeInt;
    FStep: NativeInt;
  public
    constructor Create(const Src: IEnumeratorImpl<T>; const Start, Stop, Step: NativeInt);

    // Enumerator
    function GetCurrent: T;
    function MoveNext: Boolean;
  end;

  TSliceEnumerable<T> = class(TInterfacedObject, IEnumerableImpl<T>)
  private
    FSrc: IEnumerableImpl<T>;
    FStart: NativeInt;
    FStop: NativeInt;
    FStep: NativeInt;
  public
    constructor Create(const Src: IEnumerableImpl<T>; const Start, Stop, Step: NativeInt);

    // Enumerable
    function HasCount: boolean;
    function GetCount: NativeInt;
    function GetEnumerator: IEnumeratorImpl<T>;
  end;

implementation

{ TSliceEnumerator<T> }

constructor TSliceEnumerator<T>.Create(const Src: IEnumeratorImpl<T>; const Start, Stop, Step: NativeInt);
begin
  inherited Create;

  FSrc := Src;
  FStart := Start;
  FStop := Stop;
  FStep := Step;
  FCurIdx := -1;
end;

function TSliceEnumerator<T>.GetCurrent: T;
begin
  result := FSrc.Current;
end;

function TSliceEnumerator<T>.MoveNext: Boolean;
var
  nextIdx: NativeInt;
begin
  result := false;

  if (FCurIdx < FStart) then
    nextIdx := FStart
  else
    nextIdx := FCurIdx + FStep;

  // stop < 0 ==> no stopping
  if (FStop >= 0) and (nextIdx >= FStop) then
    exit;

  while (FCurIdx < nextIdx) do
  begin
    result := FSrc.MoveNext;
    if not result then
      exit;

    FCurIdx := FCurIdx + 1;
  end;
end;

{ TSliceEnumerable<T> }

constructor TSliceEnumerable<T>.Create(const Src: IEnumerableImpl<T>; const Start, Stop, Step: NativeInt);
begin
  inherited Create;

  FSrc := Src;
  FStart := Start;
  FStop := Stop;
  FStep := Step;
end;

function TSliceEnumerable<T>.GetCount: NativeInt;
begin
  // TODO - implement logic if source enumerator has count
  Assert(False, 'Not implemented');
end;

function TSliceEnumerable<T>.GetEnumerator: IEnumeratorImpl<T>;
var
  srcEnumerator: IEnumeratorImpl<T>;
begin
  srcEnumerator := FSrc.GetEnumerator();
  result := TSliceEnumerator<T>.Create(srcEnumerator, FStart, FStop, FStep);
end;

function TSliceEnumerable<T>.HasCount: boolean;
begin
  // TODO - implement logic if source enumerator has count
  result := False;
end;

end.
