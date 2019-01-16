local metadata_interpreter = require('metadata_interpreter')
local constants = require('constants')
local asn1types = require('asn1_types')



local function gen_signature_input(config)
  local ok, res = utils.preproc([[
$(sig.retval) prepare_input_$(sig.fnc_name)(
@for k,input in pairs(sig.input) do
            const $(input)* in$(k),
@end
@for k,output in pairs(sig.output) do
@  if k == #sig.output then
            $(output)& in$(k)t$(close)
@  else
            $(output)& in$(k)t,
@  end
@end

]], {table=table, pairs=pairs, print=print,
  sig=config.sig,
  close = config.close --example, ');' or ') {'
})
  if not ok then error(res) end
  return res
end



local function gen_signature_output(config)
  local ok, res = utils.preproc([[
$(sig.retval) prepare_output_$(sig.fnc_name)(
@for k,input in pairs(sig.input) do
            const $(input)& out$(k)t,
@end
@for k,output in pairs(sig.output) do
@  if k == #sig.output then
            $(output)* out$(k)$(close)
@  else
            $(output)* out$(k),
@  end
@end

]], {table=table, pairs=pairs,
  sig=config.sig,
  close = config.close --');' or ') {'
})
  if not ok then error(res) end
  return res
end

--- -/* All Solvers, ASN1 interface*/
---- int solver_fk_compute(const asn1SccJoints* in1,
---- asn1SccPose* out1);
local function gen_signature_function(solver_function, metadata)
    local decl_input, call_input = metadata_interpreter.generate_inputs(metadata, true)
    local decl_output, init_output, call_output, para_output = metadata_interpreter.generate_outputs(metadata, true)

  local ok, res = utils.preproc([[

int solver_$(function_name)($(decl_input), $(para_output));

]], {table=table, function_name = solver_function.function_name,
      in_n = solver_function.function_input,
      out_n = solver_function.function_output,
      decl_input = decl_input,
      para_output = para_output
})
  if not ok then error(res) end
  return res
end



local function gen_uc_wrapper_header_includes()
  local ok, res = utils.preproc([[

#include "../dataview/dataview-uniq.h"

]],{table=table})
  if not ok then error(res) end
  return res
end


local function gen_model_constants(model_constants, metadata)
    local robot_name = metadata.robot_name
    local mc_decl = robot_name..'::'..constants.mc_config..' '..constants.mc_variable..';'
    local orientation_type = constants.backend_namespace..'::'..constants.orientation_type
    local joint_state_type = robot_name..'::'..constants.input_type
    local ok, res = utils.preproc([[

$(mc_decl)

void load_model_constants() {
    $(model_constants)
}

void joint_state_conversion(const $(asn1types.joint_state) *asn, $(joint_state_type) &q) {
    for(unsigned int i=0; i<$(robot_name)::dofs_count; i++) {
        q(i) = asn[i].position;
    }
}


void joint_state_conversion(const $(joint_state_type) &q, $(asn1types.joint_state) *asn) {
    for(unsigned int i=0; i<$(robot_name)::dofs_count; i++) {
        asn[i].position = q(i);
    }
}

]], {table=table, model_constants = model_constants, mc_decl = mc_decl, robot_name = robot_name,
        asn1types = asn1types, orientation_type = orientation_type, joint_state_type = joint_state_type
})
  if not ok then error(res) end
  return res
end

local function gen_source_function_call(solver_function, metadata, robot_name)
    local decl_input, call_input = metadata_interpreter.generate_inputs(metadata, true)
    local decl_output, init_output, call_output, para_output = metadata_interpreter.generate_outputs(metadata, true)
    local decl_signatures, call_signatures, asn_to_kul, kul_to_asn = metadata_interpreter.generate_solver_signatures(metadata, true)
--    local asn_to_kul = '// TODO: CONVERT FROM ASN1 TO SOLVER INPUT'
--    local kul_to_asn = '// TODO: CONVERT SOLVER OUTPUT TO ASN1'

  local ok, res = utils.preproc([[


int solver_$(function_name)($(decl_input), $(para_output)) {
  $(decl_signatures)
  $(asn_to_kul_transformations)
  $(robot_name)::$(function_name)($(call_signatures));
  $(kul_to_asn_transformations)
  return 0;
}

]], {table=table, function_name = solver_function.function_name,
      in_n = solver_function.function_input,
      out_n = solver_function.function_output,
      decl_signatures = decl_signatures,
      decl_input = decl_input,
      decl_output = decl_output,
      para_output = para_output,
      call_signatures = call_signatures,
      robot_name = robot_name,
      asn_to_kul_transformations = asn_to_kul,
      kul_to_asn_transformations = kul_to_asn,
})
  if not ok then error(res) end
  return res
end



local function gen_pragma_header_open(config)
  local ok, res = utils.preproc([[

#ifndef $(prefix:upper())_H_$(pragma_filename:upper())$(suffix:upper())
#define $(prefix:upper())_H_$(pragma_filename:upper())$(suffix:upper())

#ifdef __cplusplus
extern "C" {
#endif

]],{table=table, 
  pragma_filename = config.filename,
  prefix          = config.prefix or '__',
  suffix          = config.suffix or '__'
})
    if not ok then error(res) end
    return res
end



local function gen_pragma_header_close(config)
  local ok, res = utils.preproc([[

#ifdef __cplusplus
}
#endif

#endif // $(prefix:upper())_H_$(pragma_filename:upper())$(suffix:upper())

]],{table=table, 
  pragma_filename = config.filename,
  prefix          = config.prefix or '__',
  suffix          = config.suffix or '__'
})
  if not ok then error(res) end
  return res
end


                                    
local function gen_decl_inputs(config)
  --local fd = config.fd
  local content = "/* ALL PREPARE INPUT PER SOLVER */\n"
  for i,v in pairs(config.signatures) do
    local signature_content = gen_signature_input({fd=fd,close=');',sig=v})
    content = content .. signature_content
  end
  return content
end



local function gen_decl_outputs(config)
  local fd = config.fd
  local content = "/* ALL PREPARE OUTPUT PER SOLVER */\n"
  for i,v in pairs(config.signatures) do
    local signature_content = gen_signature_output({fd=fd,close=');',sig=v})
    content = content .. signature_content
  end
  return content
end



local function gen_source_processing_calls(solver_function)

    local preprocessing_signature = gen_decl_inputs({
      signatures = {
        { retval='int', fnc_name=solver_function.function_name,
          input={ 'asn1SccJoints'}, output={'joint_state'}
        }
      },
      close = ') {'
    })
    local preprocessing_code = solver_function.function_input_prepare .. '}'

    local postprocessing_signature = gen_decl_outputs({
      signatures = {
        { retval='int', fnc_name=solver_function.function_name,
          input={ 'asn1SccJoints'}, output={'joint_state'}
        }
      },
      close = ') {'
    })
    local postprocessing_code = solver_function.function_output_prepare .. '}'
    return preprocessing_signature..preprocessing_code..postprocessing_signature..postprocessing_code
end



local function gen_uc_wrapper_header_impl(targetblock, function_list, solver_filename)
  local c = {
    author  = 'Enea Scioni',
    license = 'BSD2-clause',
    what    = [[
    This header file is part of the user-code that
    implements a Taste function block component generated
    with the ESROCOS robot modeling tool.
    Do not include this file in the Taste function block,
    internal use  only.
]]
}
  local filecomment_content = gen_filecomment(c)
  local header_open_content = gen_pragma_header_open({
    prefix   = '__rm_tool',
    filename = targetblock..'_user_code_impl'})
  local solverheaders_content = gen_include_solverheaders({
   solverlist = {solver_filename}
  })

  local decl_inputs_content = ''
  for i,fun in pairs(function_list) do
    local content = gen_decl_inputs({
      signatures = {
        { retval='int', fnc_name=fun.function_name,
          input={ 'asn1SccJoints'}, output={'joint_state'}
        }
      },
      close = ');'
    })
    decl_inputs_content = decl_inputs_content..content
  end

  local decl_outputs_content = ''
  for i,fun in pairs(function_list) do
    local content = gen_decl_outputs({
      signatures = {
        { retval='int', fnc_name=fun.function_name,
          input={ 'asn1SccJoints'}, output={'joint_state'}
        }
      },
      close = ');'
    })
    decl_outputs_content = decl_outputs_content..content
  end

  local header_close_content = gen_pragma_header_close({
    prefix   = '__rm_tool',
    filename=targetblock..'_user_code_impl'})
  return filecomment_content..header_open_content..solverheaders_content..decl_inputs_content..decl_outputs_content..header_close_content
end


-- @path: where to put things
-- @targetblock: target block name
local function gen_uc_wrapper_source(targetblock, function_list, solver_filename, model_constants, metadata)
  local c = {
    author  = '',
    license = 'BSD 2-clause',
    what    = [[
    This source file is part of the user-code that
    implements a Taste function block component generated
    with the ESROCOS robot modeling tool.
]]
}
  local comment_content = gen_filecomment(c)

  local ok, includes = utils.preproc([[
#include <$(solverIPath)>
#include "$(static_conversions_header)"
#include "$(fblock_name)-bridge.h"
]],
{table = table,
 solverIPath = solver_include_path( {prefix='kingen', robot_name=globals.robot_name, solver_filename=solver_filename} ),
 static_conversions_header = metadata.static_conversions_header,
 fblock_name = targetblock })
  if not ok then error(includes) end

  local constants_content = gen_model_constants(model_constants, metadata)
  local functions_content = ''
  for i,fun in pairs(function_list) do
      local processing_content = ''
      --local processing_content = gen_source_processing_calls(fun, metadata[fun.function_name])
      local function_content = gen_source_function_call(fun, metadata[fun.function_name], metadata.robot_name)
      functions_content = functions_content..processing_content..function_content
  end
  return comment_content..includes..'\n'..constants_content..functions_content
end



local function gen_load_model_constants_header()
      local ok, res = utils.preproc([[

/* ONLY declarations of functions used in the taste-usercode here */
/* Initialize model constants */
void load_model_constants();

]],{table=table})
  if not ok then error(res) end
  return res
end

local function gen_uc_wrapper_header(targetblock, function_list, metadata)
  local c = {
    author  = '',
    license = 'BSD 2-clause',
    what    = [[
    This header file is part of the user-code that
    implements a Taste function block component generated
    with the ESROCOS robot modeling tool.
]]
}
    local filecomment_content = gen_filecomment(c)
    local header_open_content = gen_pragma_header_open({
        prefix   = '__rm_tool',
        filename = targetblock..'_user_code_impl'})
    local includes_content = gen_uc_wrapper_header_includes(c)
    local typedefs = asn1types.typedefsBlock()
    local load_model_constants_content = gen_load_model_constants_header()
    local functions_content = ''
    for i,fun in pairs(function_list) do
      local content = gen_signature_function(fun, metadata[fun.function_name])
      functions_content = functions_content..content
    end
    local header_close_content = gen_pragma_header_close({
    prefix   = '__rm_tool',
    filename=targetblock..'_user_code_impl'})

    return filecomment_content..header_open_content..includes_content..typedefs..'\n'..load_model_constants_content..functions_content..header_close_content
end




local M = {}
M.gen_uc_wrapper_header_impl = gen_uc_wrapper_header_impl
M.gen_uc_wrapper_source = gen_uc_wrapper_source
M.gen_uc_wrapper_header = gen_uc_wrapper_header
return M
