unit NuLib.Functional.Common;

interface

type
  Predicate<T> = reference to function(const Arg: T): boolean;

  Func<R> = reference to function(): R;
  Func<TArg1, R> = reference to function(const Arg1: TArg1): R;
  Func<TArg1, TArg2, R> = reference to function(const Arg1: TArg1; const Arg2: TArg2): R;

implementation

end.
