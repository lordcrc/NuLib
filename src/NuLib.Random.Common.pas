unit NuLib.Random.Common;

interface

type
  SeedProvider = reference to function(): TArray<UInt32>;

type
  FloatRandomEngine = reference to function(): double;
  UInt32RandomEngine = reference to function(): UInt32;

type
  FloatRandomDistribution = reference to function(): double;
  Int32RandomDistribution = reference to function(): Int32;
  UInt32RandomDistribution = reference to function(): UInt32;

implementation

end.
