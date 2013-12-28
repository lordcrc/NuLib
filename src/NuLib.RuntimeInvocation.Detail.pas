unit NuLib.RuntimeInvocation.Detail;

interface

type
  PPVtable = ^PVtable;
  PVtable = ^TVtable;
  TVtable = array[0..MaxInt div SizeOf(Pointer) - 1] of Pointer;

type
  ImplFuncReg<R> = function(): R of object; register;
  ImplFuncPascal<R> = function(): R of object; pascal;
  ImplFuncCdecl<R> = function(): R of object; cdecl;
  ImplFuncStdCall<R> = function(): R of object; stdcall;
  ImplFuncSafeCall<R> = function(): R of object; safecall;

  ImplPropGet<R> = function(): R of object;
  ImplPropGetIdx<R> = function(Index: integer): R of object;

  MethodCodeAddressFunc = reference to function(const Instance): pointer;

type
  Helper<T> = record
  public
    type
      Ptr = ^T;
  end;

function GetPropCodeAddress(const Instance; Getter: pointer): pointer;

implementation

uses
  System.TypInfo;

function GetPropCodeAddress(const Instance; Getter: pointer): pointer;
begin
  if (IntPtr(Getter) and PROPSLOT_MASK) = PROPSLOT_VIRTUAL then
  begin
    // virtual method, has offset
    result := PPointer(PNativeUInt(Instance)^ + (UIntPtr(Getter) and $ffff))^;
  end
  else
  begin
    // static
    result := Getter;
  end;
end;

end.
