unit openhmd;

{$IFDEF FPC}
  {$MODE DELPHI}
{$ENDIF}

interface

uses
  ctypes, dynlibs;

const
  // Maximum length of a string, including termination, in OpenHMD.
  OHMD_STR_SIZE = 256;

type
  // Return status codes, used for all functions that can return an error.
  ohmd_status = (
    // OHMD_S_USER_RESERVED and below can be used for user purposes, such as errors within ohmd wrappers, etc.
    OHMD_S_USER_RESERVED = -16384,
    OHMD_S_INVALID_OPERATION = -4,
    OHMD_S_UNSUPPORTED = -3,
    OHMD_S_INVALID_PARAMETER = -2,
    OHMD_S_UNKNOWN_ERROR = -1,
    OHMC_S_OK = 0
  );

  // A collection of string value information types, used for getting information with ohmd_list_gets().
  ohmd_string_value = (
    OHMD_VENDOR = 0,
    OHMD_PRODUCT = 1,
    OHMD_PATH = 2
  );

  // A collection of string descriptions, used for getting strings with ohmd_gets().
  ohmd_string_description = (
    OHMD_GLSL_DISTORTION_VERT_SRC = 0,
    OHMD_GLSL_DISTORTION_FRAG_SRC = 1,
    OHMD_GLSL_330_DISTORTION_VERT_SRC = 2,
    OHMD_GLSL_330_DISTORTION_FRAG_SRC = 3,
    OHMD_GLSL_ES_DISTORTION_VERT_SRC = 4,
    OHMD_GLSL_ES_DISTORTION_FRAG_SRC = 5
  );

  // Standard controls. Note that this is not an index into the control state.
  // Use OHMD_CONTROL_TYPES to determine what function a control serves at a given index.
  ohmd_control_hint = (
    OHMD_GENERIC        = 0,
    OHMD_TRIGGER        = 1,
    OHMD_TRIGGER_CLICK  = 2,
    OHMD_SQUEEZE        = 3,
    OHMD_MENU           = 4,
    OHMD_HOME           = 5,
    OHMD_ANALOG_X       = 6,
    OHMD_ANALOG_Y       = 7,
    OHMD_ANALOG_PRESS   = 8,
    OHMD_BUTTON_A       = 9,
    OHMD_BUTTON_B       = 10,
    OHMD_BUTTON_X       = 11,
    OHMD_BUTTON_Y       = 12,
    OHMD_VOLUME_PLUS    = 13,
    OHMD_VOLUME_MINUS   = 14,
    OHMD_MIC_MUTE       = 15
  );

  // Control type. Indicates whether controls are digital or analog. */
  ohmd_control_type = (
    OHMD_DIGITAL = 0,
    OHMD_ANALOG = 1
  );

  // A collection of float value information types, used for getting and setting information with
  //  ohmd_device_getf() and ohmd_device_setf().
  ohmd_float_value = (
    // float[4] (get): Absolute rotation of the device, in space, as a quaternion (x, y, z, w). */
    OHMD_ROTATION_QUAT                    =  1,

    // float[16] (get): A "ready to use" OpenGL style 4x4 matrix with a modelview matrix for the
    // left eye of the HMD.
    OHMD_LEFT_EYE_GL_MODELVIEW_MATRIX     =  2,
    // float[16] (get): A "ready to use" OpenGL style 4x4 matrix with a modelview matrix for the
    //  right eye of the HMD.
    OHMD_RIGHT_EYE_GL_MODELVIEW_MATRIX    =  3,

    // float[16] (get): A "ready to use" OpenGL style 4x4 matrix with a projection matrix for the
    //    left eye of the HMD.
    OHMD_LEFT_EYE_GL_PROJECTION_MATRIX    =  4,
    // float[16] (get): A "ready to use" OpenGL style 4x4 matrix with a projection matrix for the
    // right eye of the HMD.
    OHMD_RIGHT_EYE_GL_PROJECTION_MATRIX   =  5,

    // float[3] (get): A 3-D vector representing the absolute position of the device, in space.
    OHMD_POSITION_VECTOR                  =  6,

    // float[1] (get): Physical width of the device screen in metres.
    OHMD_SCREEN_HORIZONTAL_SIZE           =  7,
    // float[1] (get): Physical height of the device screen in metres.
    OHMD_SCREEN_VERTICAL_SIZE             =  8,

    // float[1] (get): Physical separation of the device lenses in metres.
    OHMD_LENS_HORIZONTAL_SEPARATION       =  9,
    // float[1] (get): Physical vertical position of the lenses in metres.
    OHMD_LENS_VERTICAL_POSITION           = 10,

    // float[1] (get): Physical field of view for the left eye in degrees.
    OHMD_LEFT_EYE_FOV                     = 11,
    // float[1] (get): Physical display aspect ratio for the left eye screen.
    OHMD_LEFT_EYE_ASPECT_RATIO            = 12,
    // float[1] (get): Physical field of view for the left right in degrees.
    OHMD_RIGHT_EYE_FOV                    = 13,
    // float[1] (get): Physical display aspect ratio for the right eye screen.
    OHMD_RIGHT_EYE_ASPECT_RATIO           = 14,

    // float[1] (get, set): Physical interpupillary distance of the user in metres.
    OHMD_EYE_IPD                          = 15,

    // float[1] (get, set): Z-far value for the projection matrix calculations (i.e. drawing distance).
    OHMD_PROJECTION_ZFAR                  = 16,
    // float[1] (get, set): Z-near value for the projection matrix calculations (i.e. close clipping distance).
    OHMD_PROJECTION_ZNEAR                 = 17,

    // float[6] (get): Device specific distortion value.
    OHMD_DISTORTION_K                     = 18,

      {
    * float[10] (set): Perform sensor fusion on values from external sensors.
    *
    * Values are: dt (time since last update in seconds) X, Y, Z gyro, X, Y, Z accelerometer and X, Y, Z magnetometer.
    * }
    OHMD_EXTERNAL_SENSOR_FUSION           = 19,

    // float[4] (get): Universal shader distortion coefficients (PanoTools model <a,b,c,d>.
    OHMD_UNIVERSAL_DISTORTION_K           = 20,

    // float[3] (get): Universal shader aberration coefficients (post warp scaling <r,g,b>.
    OHMD_UNIVERSAL_ABERRATION_K           = 21,

    // float[OHMD_CONTROL_COUNT] (get): Get the state of the device's controls. */
    OHMD_CONTROLS_STATE                = 22
  );

  // A collection of int value information types used for getting information with ohmd_device_geti().
  ohmd_int_value = (
    // int[1] (get, ohmd_geti()): Physical horizontal resolution of the device screen.
    OHMD_SCREEN_HORIZONTAL_RESOLUTION     =  0,
    // int[1] (get, ohmd_geti()): Physical vertical resolution of the device screen.
    OHMD_SCREEN_VERTICAL_RESOLUTION       =  1,

    // int[1] (get, ohmd_geti()/ohmd_list_geti()): Gets the class of the device. See: ohmd_device_class.
    OHMD_DEVICE_CLASS                     =  2,
    // int[1] (get, ohmd_geti()/ohmd_list_geti()): Gets the flags of the device. See: ohmd_device_flags.
    OHMD_DEVICE_FLAGS                     =  3,

    // int[1] (get, ohmd_geti()): Get the number of analog and digital controls of the device.
    OHMD_CONTROL_COUNT                    =  4,

    // int[OHMD_CONTROL_COUNT] (get, ohmd_geti()): Get what function controls serve.
    OHMD_CONTROLS_HINTS   		          =  5,

    // int[OHMD_CONTROL_COUNT] (get, ohmd_geti()): Get whether controls are digital or analog.
    OHMD_CONTROLS_TYPES                   =  6
  );

  // A collection of data information types used for setting information with ohmd_set_data().
  ohmd_data_value = (
    // void* (set): Set void* data for use in the internal drivers.
    OHMD_DRIVER_DATA		= 0,
      {
    * ohmd_device_properties* (set):
    * Set the device properties based on the ohmd_device_properties struct for use in the internal drivers.
    *
    * This can be used to fill in information about the device internally, such as Android, or for setting profiles.
    *}
    OHMD_DRIVER_PROPERTIES	= 1
  );

  ohmd_int_settings = (
    // int[1] (set, default: 1): Set this to 0 to prevent OpenHMD from creating background threads to do automatic device ticking.
    // Call ohmd_update(); must be called frequently, at least 10 times per second, if the background threads are disabled.
    OHMD_IDS_AUTOMATIC_UPDATE = 0
  );

  // Device classes.
  ohmd_device_class_ = (
    // HMD device.
    OHMD_DEVICE_CLASS_HMD        = 0,
    // Controller device.
    OHMD_DEVICE_CLASS_CONTROLLER = 1,
    // Generic tracker device.
    OHMD_DEVICE_CLASS_GENERIC_TRACKER = 2
  );

  // Device flags.
  ohmd_device_flags_ = (
    // Device is a null (dummy) device.
    OHMD_DEVICE_FLAGS_NULL_DEVICE         = 1,
    OHMD_DEVICE_FLAGS_POSITIONAL_TRACKING = 2,
    OHMD_DEVICE_FLAGS_ROTATIONAL_TRACKING = 4,
    OHMD_DEVICE_FLAGS_LEFT_CONTROLLER     = 8,
    OHMD_DEVICE_FLAGS_RIGHT_CONTROLLER    = 16
  );

  Pohmd_context = pointer;
  Pohmd_device = pointer;
  Pohmd_device_settings = pointer;

var
  ohmd_ctx_create: function: Pohmd_context; cdecl;
  ohmd_ctx_destroy: procedure(ctx: Pohmd_context); cdecl;
  ohmd_ctx_get_error: function(ctx: Pohmd_context): pchar; cdecl;
  ohmd_ctx_update: procedure(ctx: Pohmd_context); cdecl;
  ohmd_ctx_probe: function(ctx: Pohmd_context): cint; cdecl;
  ohmd_gets: function(typ: ohmd_string_description; const ret: pchar): cint; cdecl;
  ohmd_list_gets: function(ctx: Pohmd_context; index: cint; typ: ohmd_string_value): pchar; cdecl;
  ohmd_list_geti: function(ctx: Pohmd_context; index: cint; typ: ohmd_int_value; ret: pcint): cint; cdecl;
  ohmd_list_open_device: function(ctx: Pohmd_context; index: cint): Pohmd_device; cdecl;
  ohmd_list_open_device_s: function(ctx: Pohmd_context; index: cint; settings: Pohmd_device_settings): Pohmd_device; cdecl;
  ohmd_device_settings_seti: function(settings: Pohmd_device_settings; key: ohmd_int_settings; const val: pcint): ohmd_status; cdecl;
  ohmd_device_settings_create: function(ctx: Pohmd_context): Pohmd_device_settings; cdecl;
  ohmd_device_settings_destroy: procedure(settings: Pohmd_device_settings); cdecl;
  ohmd_close_device: function(device: Pohmd_device): cint; cdecl;
  ohmd_device_getf: function(device: Pohmd_device; typ: ohmd_float_value; ret: pcfloat): cint; cdecl;
  ohmd_device_setf: function(device: Pohmd_device; typ: ohmd_float_value; const val: pcfloat): cint; cdecl;
  ohmd_device_geti: function(device: Pohmd_device; typ: ohmd_int_value; ret: pcint): cint; cdecl;
  ohmd_device_seti: function(device: Pohmd_device; typ: ohmd_int_value; const val: pcint): cint; cdecl;
  ohmd_device_set_data: function(device: Pohmd_device; typ: ohmd_data_value; const val: pointer): cint; cdecl;
  ohmd_get_version: procedure(major, minor, patch: pcint); cdecl;
  ohmd_require_version: function(major, minor, patch: cint): ohmd_status; cdecl;
  ohmd_sleep: procedure(time: double); cdecl;

function ohmd_load: boolean;

implementation

function ohmd_load: boolean;
var
  Lib: TLibHandle= dynlibs.NilHandle;
begin
  {$IFDEF WINDOWS}
  Lib := LoadLibrary('openhmd.dll');
  {$ELSE}
  Lib := LoadLibrary('libopenhmd.so');
  {$ENDIF}
  if Lib = dynlibs.NilHandle then
  begin
    exit;
    Result := false;
  end;
  ohmd_ctx_create := GetProcedureAddress(Lib, 'ohmd_ctx_create');
  ohmd_ctx_destroy := GetProcedureAddress(Lib, 'ohmd_ctx_destroy');
  ohmd_ctx_get_error := GetProcedureAddress(Lib, 'ohmd_ctx_get_error');
  ohmd_ctx_update := GetProcedureAddress(Lib, 'ohmd_ctx_update');
  ohmd_ctx_probe := GetProcedureAddress(Lib, 'ohmd_ctx_probe');
  ohmd_gets := GetProcedureAddress(Lib, 'ohmd_gets');
  ohmd_list_gets := GetProcedureAddress(Lib, 'ohmd_list_gets');
  ohmd_list_geti := GetProcedureAddress(Lib, 'ohmd_list_geti');
  ohmd_list_open_device := GetProcedureAddress(Lib, 'ohmd_list_open_device');
  ohmd_list_open_device_s := GetProcedureAddress(Lib, 'ohmd_list_open_device_s');
  ohmd_device_settings_seti := GetProcedureAddress(Lib, 'ohmd_device_settings_seti');
  ohmd_device_settings_create := GetProcedureAddress(Lib, 'ohmd_device_settings_create');
  ohmd_device_settings_destroy := GetProcedureAddress(Lib, 'ohmd_device_settings_destroy');
  ohmd_close_device := GetProcedureAddress(Lib, 'ohmd_close_device');
  ohmd_device_getf := GetProcedureAddress(Lib, 'ohmd_device_getf');
  ohmd_device_setf := GetProcedureAddress(Lib, 'ohmd_device_setf');
  ohmd_device_geti := GetProcedureAddress(Lib, 'ohmd_device_geti');
  ohmd_device_seti := GetProcedureAddress(Lib, 'ohmd_device_seti');
  ohmd_device_set_data := GetProcedureAddress(Lib, 'ohmd_device_set_data');
  ohmd_get_version := GetProcedureAddress(Lib, 'ohmd_get_version');
  ohmd_require_version := GetProcedureAddress(Lib, 'ohmd_require_version');
  ohmd_sleep := GetProcedureAddress(Lib, 'ohmd_sleep');
  Result := true;
end;

end.
