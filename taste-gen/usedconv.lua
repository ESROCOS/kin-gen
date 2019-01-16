local asn1_types = require('asn1_types')
local constants = require('constants')
local dconv  = require('dproto-conv-gen')
local dprotofile =  'type_conversions/dproto/types.dproto'
local asn_files = {
  'type_conversions/asn/taste-types.asn',
  'type_conversions/asn/taste-extended.asn',
  'type_conversions/asn/userdefs-base.asn',
  'type_conversions/asn/mybase.asn'
}

local ddr_models = {}
ddr_models.asn_files = asn_files

dconv.init_runtime(dprotofile,ddr_models)
--constants.orientation_type
local g,e = dconv.convert("QuaternionTemp", "QuaternionTemp2")

if not g then errmsg('Error during type conversion: '..tostring(e)); os.exit(1); end;
local str = dconv.CaptureOutput()
print(str)
g(nil, 'from', 'to')

--print( tostring(str) )