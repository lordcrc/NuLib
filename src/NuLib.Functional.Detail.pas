unit NuLib.Functional.Detail;

interface

uses
  NuLib.Containers.Common,
  NuLib.Functional.Common;

type
  IEnumeratorImpl<T> = interface
    function GetCurrent: T;
    function MoveNext: Boolean;

    property Current: T read GetCurrent;
  end;

  IEnumerableImpl<T> = interface
    function GetEnumerator: IEnumeratorImpl<T>;
  end;

  IOrderedEnumerableImpl<T> = interface(IEnumerableImpl<T>)
    function Instance: TObject;
  end;

implementation

end.
