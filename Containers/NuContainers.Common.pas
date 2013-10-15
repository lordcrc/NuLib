unit NuContainers.Common;

interface

type
  IEqualityComparer<T> = interface
    function Equals(const Left, Right: T): Boolean;
    function GetHashCode(const Value: T): UInt32;
  end;

  EqualityComparison<T> = reference to function(const Left, Right: T): Boolean;

  HashFunction<T> = reference to function(const Value: T): UInt32;

implementation

end.
