unit NuLib.Functional;

interface

uses
  NuLib.Functional.Common,
  NuLib.Functional.Detail;

type
  Enumerator<T> = record
  strict private
    FImpl: NuLib.Functional.Detail.IEnumeratorImpl<T>;
    function GetCurrent: T; inline;
  private
    class function Create(const Impl: NuLib.Functional.Detail.IEnumeratorImpl<T>): Enumerator<T>; static;
  public
    function MoveNext: Boolean; inline;
    property Current: T read GetCurrent;
  end;

  Enumerable<T> = record
  strict private
    FImpl: NuLib.Functional.Detail.IEnumerableImpl<T>;
  public
    procedure Dispose;

    function GetEnumerator: Enumerator<T>; inline;

    class function Wrap<E: class>(const EnumerableObj: E): Enumerable<T>; static;
  end;

implementation

uses
  System.SysUtils,
  NuLib.Functional.Detail.EnumerableWrapper;

{ Enumerator<T> }

class function Enumerator<T>.Create(const Impl: NuLib.Functional.Detail.IEnumeratorImpl<T>): Enumerator<T>;
begin
  result.FImpl := Impl;
end;

function Enumerator<T>.GetCurrent: T;
begin
  result := FImpl.Current;
end;

function Enumerator<T>.MoveNext: Boolean;
begin
  result := FImpl.MoveNext;
end;

{ Enumerable<T> }

procedure Enumerable<T>.Dispose;
begin
  FImpl := nil;
end;

function Enumerable<T>.GetEnumerator: Enumerator<T>;
begin
  result := Enumerator<T>.Create(FImpl.GetEnumerator());
end;

class function Enumerable<T>.Wrap<E>(const EnumerableObj: E): Enumerable<T>;
begin
  result.FImpl := TEnumerableWrapper<E, T>.Create(EnumerableObj);
end;

end.
