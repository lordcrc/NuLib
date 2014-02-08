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
    function HasCount: boolean;
    function GetCount: NativeInt;

    function GetEnumerator: IEnumeratorImpl<T>;

    property Count: NativeInt read GetCount;
  end;

  IOrderedEnumerableImpl<T> = interface(IEnumerableImpl<T>)
    function Instance: TObject; // necessary hack
  end;

implementation

end.
