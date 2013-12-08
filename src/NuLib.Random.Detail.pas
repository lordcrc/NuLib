unit NuLib.Random.Detail;

interface

uses
  NuLib.Random.Common;

function DefaultSeedProvider: TArray<UInt32>;
function SeedOrDefaultProvider(const Seed: SeedProvider): SeedProvider;

implementation

uses
  WinApi.Windows, System.SysUtils, System.DateUtils;

function DefaultSeedProvider: TArray<UInt32>;
var
  p: ^UInt32;
  x1, x2, x3, x4: UInt32;
  t1, t2: Int64;
begin
  // mix a few sources
  x1 := UInt32(NativeInt(@DefaultSeedProvider) and $ffffffff);

  QueryPerformanceCounter(t1);
  Sleep(1);
  QueryPerformanceCounter(t2);
  x2 := (t2-t1) and $ffffffff;
  x3 := UInt32(GetTickCount());

  p := nil;
  try
    p := GetMemory(sizeof(UInt32));
    x4 := UInt32(NativeInt(p) and $ffffffff);
  finally
    FreeMem(p);
  end;

  SetLength(result, 1);
  result[0] := x1 xor x2 xor x3 xor x4;
end;

function SeedOrDefaultProvider(const Seed: SeedProvider): SeedProvider;
begin
  if Assigned(Seed) then
    result := Seed
  else
    result := DefaultSeedProvider;
end;

end.
