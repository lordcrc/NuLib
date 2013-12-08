unit NuLib.Random.Detail.Engines.LinearShiftRegister;

interface

uses
  NuLib.Random.Common;

type
  LinearShiftRegister32BitEngine = class(TInterfacedObject, UInt32RandomEngine)
  strict private
    FState: UInt32;
  public
    constructor Create(const Seed: SeedProvider);

    function Invoke(): UInt32;
  end;

implementation

uses
  NuLib.Random.Detail;

{ LinearShiftRegister32BitEngine }

constructor LinearShiftRegister32BitEngine.Create(const Seed: SeedProvider);
var
  s, v: UInt32;
  sp: SeedProvider;
begin
  inherited Create;

  s := 0;
  sp := SeedOrDefaultProvider(Seed);
  for v in sp() do
  begin
    s := s xor v;
  end;

  // invalid states
  if (s = 0) or ((not s) = 0) then
    s := 1;

  FState := s;
end;

function LinearShiftRegister32BitEngine.Invoke(): UInt32;
const
  Taps =
    (UInt32(1) shl 31) or
    (UInt32(1) shl 21) or
    (UInt32(1) shl 1) or
    (UInt32(1) shl 0);
begin
  FState := not ((FState shr 1) xor ((-(FState and 1)) and Taps));
  result := FState;
end;

end.
