unit NuLib.Random;

interface

uses
  NuLib.Random.Common;

type
  ///	<summary>
  ///	  Provides seeding entropy for a RandomEngine. The seed must be at least one
  ///	  UInt32 long.
  ///	</summary>
  ///	<returns>
  ///	  Array containing the seed bits. Must be at least one element long.
  ///	</returns>
  ///	<remarks>
  ///	  Some RandomEngine implementations benefit from a larger number of seed
  ///	  bits.
  ///	</remarks>
  SeedProvider = NuLib.Random.Common.SeedProvider;

  ///	<summary>
  ///	  Uniform RandomEngine which returns a random floating-point number for
  ///	  each invocation.
  ///	</summary>
  FloatRandomEngine = NuLib.Random.Common.FloatRandomEngine;

  ///	<summary>
  ///	  Uniform RandomEngine which returns a random UInt32 number for each
  ///	  invocation.
  ///	</summary>
  UInt32RandomEngine = NuLib.Random.Common.UInt32RandomEngine;

  FloatRandomDistribution = NuLib.Random.Common.FloatRandomDistribution;
  Int32RandomDistribution = NuLib.Random.Common.Int32RandomDistribution;
  UInt32RandomDistribution = NuLib.Random.Common.UInt32RandomDistribution;

///	<summary>
///	  Returns a 32bit Linear Shift Register (LSR) RandomEngine, initialized by
///	  the supplied Seed provider.
///	</summary>
///	<param name="Seed">
///	  Seed provider or nil to use default seed provider.
///	</param>
///	<remarks>
///	  Period: 2^32-1
///	</remarks>
function LSR32Engine(const Seed: SeedProvider = nil): UInt32RandomEngine;

function UniformDistribution(const MinValue, MaxValue: double; const RandomEngine: FloatRandomEngine): FloatRandomDistribution; overload;
function UniformDistribution(const MinValue, MaxValue: double; const RandomEngine: UInt32RandomEngine): FloatRandomDistribution; overload;
function UniformDistribution(const MinValue, MaxValue: Int32; const RandomEngine: FloatRandomEngine): Int32RandomDistribution; overload;
function UniformDistribution(const MinValue, MaxValue: Int32; const RandomEngine: UInt32RandomEngine): Int32RandomDistribution; overload;

function NormalDistribution(const Mean, Sigma: double; const RandomEngine: FloatRandomEngine): FloatRandomDistribution; overload;
function NormalDistribution(const Mean, Sigma: double; const RandomEngine: UInt32RandomEngine): FloatRandomDistribution; overload;
function NormalDistribution(const RandomEngine: FloatRandomEngine): FloatRandomDistribution; overload;
function NormalDistribution(const RandomEngine: UInt32RandomEngine): FloatRandomDistribution; overload;

implementation

uses
  NuLib.Random.Detail.Engines,
  NuLib.Random.Detail.Engines.LinearShiftRegister,
  NuLib.Random.Detail.Distributions,
  NuLib.Random.Detail.Distributions.Uniform,
  NuLib.Random.Detail.Distributions.Normal;

function LSR32Engine(const Seed: SeedProvider): UInt32RandomEngine;
begin
  result := NuLib.Random.Detail.Engines.LinearShiftRegister.LinearShiftRegister32BitEngine.Create(Seed);
end;

function UniformDistribution(const MinValue, MaxValue: double; const RandomEngine: FloatRandomEngine): FloatRandomDistribution;
begin

end;

function UniformDistribution(const MinValue, MaxValue: double; const RandomEngine: UInt32RandomEngine): FloatRandomDistribution;
begin

end;

function UniformDistribution(const MinValue, MaxValue: Int32; const RandomEngine: FloatRandomEngine): Int32RandomDistribution;
begin
  result := UniformDistribution(MinValue, MaxValue, FloatToUInt32Engine(RandomEngine));
end;

function UniformDistribution(const MinValue, MaxValue: Int32; const RandomEngine: UInt32RandomEngine): Int32RandomDistribution;
begin
  result := NuLib.Random.Detail.Distributions.Uniform.UniformInt32Distribution.Create(MinValue, MaxValue, RandomEngine);
end;

function NormalDistribution(const Mean, Sigma: double; const RandomEngine: FloatRandomEngine): FloatRandomDistribution;
begin
  result := NuLib.Random.Detail.Distributions.Normal.NormalDistribution.Create(Mean, Sigma, RandomEngine);
end;

function NormalDistribution(const Mean, Sigma: double; const RandomEngine: UInt32RandomEngine): FloatRandomDistribution;
begin
  result := NormalDistribution(Mean, Sigma, UInt32ToFloatEngine(RandomEngine));
end;

function NormalDistribution(const RandomEngine: FloatRandomEngine): FloatRandomDistribution;
begin
  result := NormalDistribution(0, 1, RandomEngine);
end;

function NormalDistribution(const RandomEngine: UInt32RandomEngine): FloatRandomDistribution;
begin
  result := NormalDistribution(0, 1, RandomEngine);
end;

end.
