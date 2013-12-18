unit NuLib.Functional.Detail;

interface

type
  IEnumeratorImpl<T> = interface
    function GetCurrent: T;
    function MoveNext: Boolean;

    property Current: T read GetCurrent;
  end;

  IEnumerableImpl<T> = interface
    function GetEnumerator: IEnumeratorImpl<T>;
  end;


implementation

end.
