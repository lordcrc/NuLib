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

    function Aggregate<TAccumulate>(const InitialValue: TAccumulate; const AccumulateFunc: Func<TAccumulate, T, TAccumulate>): TAccumulate;

    ///	<summary>
    ///	  Filters a sequence based on the supplied predicate.
    ///	</summary>
    ///	<param name="Predicate">
    ///	  Predicate to test each element in the sequence.
    ///	</param>
    ///	<returns>
    ///	  Returns a sequence containing the elements of the source sequence for
    ///	  which the predicate returned true.
    ///	</returns>
    function Filter(const Predicate: Predicate<T>): Enumerable<T>;


    ///	<summary>
    ///	  Wraps an enumerable object, that is an object which can be used in
    ///	  for..in.
    ///	</summary>
    ///	<typeparam name="E">
    ///	  Type of the enumerable object.
    ///	</typeparam>
    ///	<param name="EnumerableObj">
    ///	  Instance of the enumerable object.
    ///	</param>
    ///	<remarks>
    ///	  <para>
    ///	    The wrapper keeps a reference to the supplied enumerable object.
    ///	    Thus the returned Enumerable&lt;T&gt; instance should not be used
    ///	    after the wrapped object is destroyed.
    ///	  </para>
    ///	  <para>
    ///	    Nil the Enumerable&lt;T&gt; instance to release this reference.
    ///	  </para>
    ///	</remarks>
    class function Wrap<E: class>(const EnumerableObj: E): Enumerable<T>; static;

    ///	<summary>
    ///	  <para>
    ///	    Used to assign nil to the enumerable instance, freeing internal
    ///	    references such as to wrapped objects.
    ///	  </para>
    ///	  <para>
    ///	    Other uses are internal only.
    ///	  </para>
    ///	</summary>
    ///	<param name="EnumerableImpl">
    ///	  Pass nil.
    ///	</param>
    ///	<returns>
    ///	  An enumerable instance with no associated implementation. Do not use
    ///	  the returned instance.
    ///	</returns>
    class operator Implicit(const EnumerableImpl: NuLib.Functional.Detail.IEnumerableImpl<T>): Enumerable<T>;

    function GetEnumerator: Enumerator<T>; inline;
  end;

implementation

uses
  System.SysUtils,
  NuLib.Functional.Detail.EnumerableWrapper,
  NuLib.Functional.Detail.Filter,
  NuLib.Functional.Detail.Aggregate;

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

function Enumerable<T>.Aggregate<TAccumulate>(const InitialValue: TAccumulate;
  const AccumulateFunc: Func<TAccumulate, T, TAccumulate>): TAccumulate;
begin
  result := AggregateImpl.Compute<T, TAccumulate>(FImpl, InitialValue, AccumulateFunc);
end;

function Enumerable<T>.Filter(const Predicate: Predicate<T>): Enumerable<T>;
begin
  result := TFilterImpl<T>.Create(FImpl, Predicate);
end;

function Enumerable<T>.GetEnumerator: Enumerator<T>;
begin
  result := Enumerator<T>.Create(FImpl.GetEnumerator());
end;

class operator Enumerable<T>.Implicit(const EnumerableImpl: NuLib.Functional.Detail.IEnumerableImpl<T>): Enumerable<T>;
begin
  result.FImpl := EnumerableImpl;
end;

class function Enumerable<T>.Wrap<E>(const EnumerableObj: E): Enumerable<T>;
begin
  result := TEnumerableWrapper<E, T>.Create(EnumerableObj);
end;

end.
