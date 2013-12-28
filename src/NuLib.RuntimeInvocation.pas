unit NuLib.RuntimeInvocation;

interface

uses
  System.TypInfo;

type
  RIFunc<R> = reference to function(const Instance): R;

type
  RIConstructor<TObj: class> = record
    class function Func<R>(const MethodName: string): RIFunc<R>; static;
    class function PropGetter<R>(const PropertyName: string): RIFunc<R>; static;
  end;

  RIConstructor = record
    class function Func<R>(const TypInfo: PTypeInfo; const MethodName: string): RIFunc<R>; static;
    class function PropGetter<R>(const TypInfo: PTypeInfo; const PropertyName: string): RIFunc<R>; static;
  end;

implementation

uses
  System.SysUtils,
  System.Rtti,
  NuLib.RuntimeInvocation.Detail;

{ RIConstructor<TObj> }

class function RIConstructor<TObj>.Func<R>(const MethodName: string): RIFunc<R>;
begin
  result := RIConstructor.Func<R>(TypeInfo(TObj), MethodName);
end;

class function RIConstructor<TObj>.PropGetter<R>(const PropertyName: string): RIFunc<R>;
begin
  result := RIConstructor.PropGetter<R>(TypeInfo(TObj), PropertyName);
end;

{ RIConstructor }

class function RIConstructor.Func<R>(const TypInfo: PTypeInfo; const MethodName: string): RIFunc<R>;
var
  ctx: TRttiContext;
  typ: TRttiType;
  cls: TClass;
  m: TRttiMethod;
  isFunction: boolean;
  codeAddress: pointer;
  virtualIndex: integer;
  getCodeAddress: MethodCodeAddressFunc;
begin
  ctx := TRttiContext.Create;
  typ := ctx.GetType(TypInfo);

  if not Assigned(typ) then
    raise EArgumentException.Create('No RTTI found ("' + GetTypeName(TypInfo) + '")');

  m := typ.GetMethod(MethodName);

  if not Assigned(m) then
    raise EArgumentException.Create('No RTTI found ("' + GetTypeName(TypInfo) + '")');

  isFunction := m.MethodKind = mkFunction;

  if not (isFunction) then
    raise EArgumentException.Create('Method "' + MethodName + '" is not a function');

  virtualIndex := m.VirtualIndex;
  case m.DispatchKind of
    dkInterface: begin
      getCodeAddress :=
        function (const Instance): pointer
        begin
          result := PPVtable(Instance)^[virtualIndex];
        end;
    end;
    dkVtable: begin
      getCodeAddress :=
        function (const Instance): pointer
        var
          cls: TClass;
        begin
          cls := TObject(Instance).ClassType;
          result := PVtable(cls)^[virtualIndex];
        end;
    end;
    dkDynamic: begin
      getCodeAddress :=
        function (const Instance): pointer
        var
          cls: TClass;
        begin
          cls := TObject(Instance).ClassType;
          result := GetDynaMethod(cls, virtualIndex);
        end;
    end;
  else
    codeAddress := m.CodeAddress;
    if (codeAddress = nil) or (PPointer(codeAddress)^ = nil) then
      raise EArgumentException.Create('No RTTI found for "' + MethodName + '"');

    getCodeAddress :=
      function (const Instance): pointer
      begin
        result := codeAddress;
      end;
  end;

  case m.CallingConvention of
    ccReg:
      result :=
        function(const Instance): R
        var
          fm: TMethod;
          f: ImplFuncReg<R>;
        begin
          fm.Code := getCodeAddress(Instance);
          fm.Data := pointer(Instance);
          f := ImplFuncReg<R>(fm);
          result := f();
        end;
    ccCdecl:
      result :=
        function(const Instance): R
        var
          fm: TMethod;
          f: ImplFuncCdecl<R>;
        begin
          fm.Code := getCodeAddress(Instance);
          fm.Data := pointer(Instance);
          f := ImplFuncCdecl<R>(fm);
          result := f();
        end;
    ccPascal:
      result :=
        function(const Instance): R
        var
          fm: TMethod;
          f: ImplFuncPascal<R>;
        begin
          fm.Code := getCodeAddress(Instance);
          fm.Data := pointer(Instance);
          f := ImplFuncPascal<R>(fm);
          result := f();
        end;
    ccStdCall:
      result :=
        function(const Instance): R
        var
          fm: TMethod;
          f: ImplFuncStdCall<R>;
        begin
          fm.Code := getCodeAddress(Instance);
          fm.Data := pointer(Instance);
          f := ImplFuncStdCall<R>(fm);
          result := f();
        end;
    ccSafeCall:
      result :=
        function(const Instance): R
        var
          fm: TMethod;
          f: ImplFuncSafeCall<R>;
        begin
          fm.Code := getCodeAddress(Instance);
          fm.Data := pointer(Instance);
          f := ImplFuncSafeCall<R>(fm);
          result := f();
        end;
  end;
end;

class function RIConstructor.PropGetter<R>(const TypInfo: PTypeInfo; const PropertyName: string): RIFunc<R>;
var
  ctx: TRttiContext;
  typ: TRttiType;
  p: TRttiProperty;
  ip: TRttiInstanceProperty;
  m: TRttiMethod;
  getter: pointer;
  codeAddress: pointer;
  index: integer;
begin
  ctx := TRttiContext.Create;
  typ := ctx.GetType(TypInfo);

  if not Assigned(typ) then
    raise EArgumentException.Create('No RTTI found ("' + GetTypeName(TypInfo) + '")');

  if (typ.TypeKind = tkInterface) then
  begin
    m := typ.GetMethod('Get' + PropertyName); // assume name of getters
    Assert(Assigned(m), 'Invalid interface property');

    result := Func<R>(TypInfo, 'Get' + PropertyName);
  end
  else if (typ.TypeKind = tkClass) then
  begin
    p := typ.GetProperty(PropertyName);
    Assert(p is TRttiInstanceProperty, 'Property is not TRttiInstanceProperty');

    ip := TRttiInstanceProperty(p);

    getter := ip.PropInfo^.GetProc;
    if (IntPtr(getter) and PROPSLOT_MASK) = PROPSLOT_FIELD then
    begin
      result :=
        function(const Instance): R
        var
          f: Helper<R>.Ptr;
        begin
          f := Helper<R>.Ptr(PByte(Instance) + (UIntPtr(getter) and (not PROPSLOT_MASK)));
          result := f^;
        end;
    end
    else
    begin
      if ip.PropInfo^.Index = Low(ip.PropInfo^.Index) then
      begin
        // not indexed
        result :=
          function(const Instance): R
          var
            gm: TMethod;
            g: ImplFuncReg<R>;
          begin
            gm.Code := GetPropCodeAddress(Instance, getter);
            gm.Data := pointer(Instance);
            g := ImplPropGet<R>(gm);
            result := g();
          end;
      end
      else
      begin
        index := ip.PropInfo^.Index;
        // indexed
        result :=
          function(const Instance): R
          var
            gm: TMethod;
            g: ImplPropGetIdx<R>;
          begin
            gm.Code := GetPropCodeAddress(Instance, getter);
            gm.Data := pointer(Instance);
            g := ImplPropGetIdx<R>(gm);
            result := g(index);
          end;
      end;
    end;
  end
  else
    Assert(false, 'Invalid type');
end;

end.
