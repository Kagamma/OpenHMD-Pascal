program simple;

{$MODE DELPHI}

uses
  Classes, SysUtils, OpenHMD;

const
  DEVICE_CLASS: array[0..3] of string = ('HMD', 'Controller', 'Generic Tracker', 'Unknown');

function YesNo(Q: integer): string;
begin
  if Q <> 0 then
    Result := 'Yes'
  else
    Result := 'No';
end;

procedure InfoI(Hmd: Pohmd_device; Name: string; Len: integer; Val: ohmd_int_value);
var
  iv: array[0..15] of integer;
  i: integer;
begin
  ohmd_device_geti(Hmd, Val, @iv[0]);
  Write('  ', Name, ': ');
  for i := 0 to Len-1 do
    Write(iv[i]);
  Writeln;
end;

procedure InfoF(Hmd: Pohmd_device; Name: string; Len: integer; Val: ohmd_float_value);
var
  iv: array[0..15] of single;
  i: integer;
begin
  ohmd_device_getf(Hmd, Val, @iv[0]);
  Write('  ', Name, ': ');
  for i := 0 to Len-1 do
    Write(iv[i]:0:6, '  ');
  Writeln;
end;

var
  i,
  Major, Minor, Patch,
  NumDevices,
  DeviceClass, DeviceFLags: integer;
  CtX: Pohmd_context;
  Hmd: Pohmd_device;
  IVals: array[0..1] of integer;

begin
  if not ohmd_load then
  begin
    Writeln('OpenHMD driver not found!');
    exit;
  end;
  ohmd_get_version(@Major, @Minor, @Patch);
  Writeln('Version: ', Major, '.', Minor, '.', Patch);
  Ctx := ohmd_ctx_create;
  NumDevices := ohmd_ctx_probe(Ctx);
  if NumDevices < 0 then
  begin
    Writeln('Failed to probe devices:', ohmd_ctx_get_error(Ctx));
    exit;
  end;
  Writeln('Number of devices: ', NumDevices);
  for i := 0 to NumDevices-1 do
  begin
    ohmd_list_geti(Ctx, i, OHMD_DEVICE_CLASS, @DeviceClass);
    ohmd_list_geti(Ctx, i, OHMD_DEVICE_FLAGS, @DeviceFlags);
    Writeln('Device #', i);
    Writeln('  Vendor: ', ohmd_list_gets(Ctx, i, OHMD_VENDOR));
    Writeln('  Product: ', ohmd_list_gets(Ctx, i, OHMD_PRODUCT));
    Writeln('  Path: ', ohmd_list_gets(Ctx, i, OHMD_PATH));
    if DeviceClass > integer(OHMD_DEVICE_CLASS_GENERIC_TRACKER) then
      DeviceClass := 3;
    Writeln('  Class: ', DEVICE_CLASS[DeviceClass]);
    Writeln('  Flags: ', ohmd_list_gets(Ctx, i, OHMD_PATH));
    Writeln('    Null device: ', YesNo(DeviceFlags and integer(OHMD_DEVICE_FLAGS_NULL_DEVICE)));
    Writeln('    Rotational tracking: ', YesNo(DeviceFlags and integer(OHMD_DEVICE_FLAGS_ROTATIONAL_TRACKING)));
    Writeln('    Positional tracking: ', YesNo(DeviceFlags and integer(OHMD_DEVICE_FLAGS_POSITIONAL_TRACKING)));
    Writeln('    Left controller: ', YesNo(DeviceFlags and integer(OHMD_DEVICE_FLAGS_LEFT_CONTROLLER)));
    Writeln('    Right controller: ', YesNo(DeviceFlags and integer(OHMD_DEVICE_FLAGS_RIGHT_CONTROLLER)));
  end;
  Writeln('Opening device #0');
  Hmd := ohmd_list_open_device(Ctx, 0);
  if Hmd = nil then
  begin
    Writeln('Failed to open device: ', ohmd_ctx_get_error(Ctx));
    exit;
  end;
  ohmd_device_geti(Hmd, OHMD_SCREEN_HORIZONTAL_RESOLUTION, @Ivals[0]);
  ohmd_device_geti(Hmd, OHMD_SCREEN_VERTICAL_RESOLUTION, @Ivals[1]);
  Writeln('  Resolution: ', Ivals[0], ' x ', Ivals[1]);
  InfoF(Hmd, 'H size', 1, OHMD_SCREEN_HORIZONTAL_SIZE);
  InfoF(Hmd, 'V size', 1, OHMD_SCREEN_VERTICAL_SIZE);
  InfoF(Hmd, 'Lens separation', 1, OHMD_LENS_HORIZONTAL_SEPARATION);
  InfoF(Hmd, 'Lens vcenter', 1, OHMD_LENS_VERTICAL_POSITION);
  InfoF(Hmd, 'Left eye FOV', 1, OHMD_LEFT_EYE_FOV);
  InfoF(Hmd, 'Right eye FOV', 1, OHMD_RIGHT_EYE_FOV);
  InfoF(Hmd, 'Left eye aspect', 1, OHMD_LEFT_EYE_ASPECT_RATIO);
  InfoF(Hmd, 'Right eye aspect', 1, OHMD_RIGHT_EYE_ASPECT_RATIO);
  InfoF(Hmd, 'Distortion k', 1, OHMD_DISTORTION_K);
  InfoI(Hmd, 'Control count', 1, OHMD_CONTROL_COUNT);
  for i := 0 to 9999 do
  begin
    ohmd_ctx_update(ctx);
    InfoF(Hmd, 'Rotation quat: ', 4, OHMD_ROTATION_QUAT);
    InfoF(Hmd, 'Position vec : ', 3, OHMD_POSITION_VECTOR);
    Writeln;
    ohmd_sleep(0.01);
  end;
  ohmd_ctx_destroy(Ctx);
end.
