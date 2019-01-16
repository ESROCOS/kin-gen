local dconv  = require('dproto-conv-gen')
local dprotofile =  'type_conversions/dproto/types.dproto'
local asn_files = {
  'type_conversions/asn/taste-types.asn',
  'type_conversions/asn/taste-extended.asn',
  'type_conversions/asn/userdefs-base.asn',
  'type_conversions/asn/mybase.asn'
}
local asn = require('asn1_types')

local ddr_models = {}
ddr_models.asn_files = asn_files

dconv.init_runtime(dprotofile,ddr_models)


local function runDConv(from_type, to_type)
    local g,e = dconv.convert(from_type, to_type)
    if not g then errmsg('Error during type conversion: '..tostring(e)); os.exit(1); end;
    local str = dconv.CaptureOutput()
    return g, str
end


function generate_transformation_code(from_type, from_name, to_type, to_name)
    if (from_type == 'asn1SccBase_JointState' or to_type == 'asn1SccBase_JointState') then
        -- workaround for dconv not supporting JoinState conversions
        return 'joint_state_conversion('..from_name..','..to_name..'); '
    end
    local code = {}

    if from_type==asn.types.orientation.original then
        table.insert(code, "internal::Quaternion __or;")
        local g, str = runDConv(from_type, "QuaternionTemp")
        g(str, from_name..'', '__or.data')
        table.insert(code, tostring(str) )
        g, str = runDConv("QuaternionTemp", to_type)
        g(str, '__or', to_name)
        table.insert(code, tostring(str) )
        return table.concat(code, "\n")
    end
    if to_type==asn.types.orientation.original then
        table.insert(code, "internal::Quaternion __or;")
        local g, str = runDConv(from_type, "QuaternionTemp")
        g(str, from_name..'', '__or')
        table.insert(code, tostring(str) )
        g, str = runDConv("QuaternionTemp", to_type)
        g(str, '__or.data', to_name)
        table.insert(code, tostring(str) )
        return table.concat(code, "\n")
    end

    local g, str = runDConv(from_type, to_type)
    g(str, from_name..'', to_name..'')
    return tostring(str)
end


local M = {}
M.generate_transformation_code = generate_transformation_code
return M

