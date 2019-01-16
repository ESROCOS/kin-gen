local ilk_keywords = require('keywords')
local asn1_types = require('asn1_types')
local constants = require('constants')
local transformations = require('transformations_generator')
local variables = require('variable_names')


local function generate_inputs(metadata)
    local result_decl = ''
    local result_call = ''
    if metadata.ops.type == ilk_keywords.solver_type.forward then
        result_decl = 'const '.. asn1_types.joint_state ..' *'..variables.input.joint_state
        result_call = variables.input.joint_state
    elseif metadata.ops.type == ilk_keywords.solver_type.inverse then
        if metadata.ops.ik.kind == ilk_keywords.op_argument.inverse_kinematics.kind.position then
            result_decl = 'const '.. asn1_types.vector_3d ..' *'..variables.input.position..', const '.. asn1_types.rot_m_t ..'*'..variables.input.orientation..', ' .. asn1_types.joint_state ..'*'..variables.input.guess
            result_call = variables.input.position..', '..variables.input.orientation..', '..variables.input.guess
        elseif metadata.ops.ik.kind == ilk_keywords.op_argument.inverse_kinematics.kind.velocity then
            result_decl = 'const '.. asn1_types.joint_state.. ' *'..variables.input.q..', const '.. asn1_types.vector_3d ..' *'..variables.input.vector
            result_call = variables.input.q..', '..variables.input.vector
        end
    end
    return result_decl, result_call
end



local function generate_outputs(metadata, external)
    local result_decl = ''
    local result_call = ''
    local result_init = ''
    local result_para = ''
    local para_prefix = ''
    local external = external or false
    if external then
        para_prefix = '*'
    end
    if metadata.type == ilk_keywords.solver_type.forward then
        local counter = 0
        for i,v in pairs(metadata.ops.outputs) do
            if v.otype == 'pose' then
                counter = counter + 1
                result_decl = result_decl.. asn1_types.pose ..' '..variables.output.outval..counter..'; '
                result_para = result_para.. asn1_types.pose ..' '..para_prefix..''..variables.output.outval..counter..','
                result_init = result_init.. asn1_types.init.pose ..'('..variables.output.outval..counter..'); '
                result_call = result_call..''..variables.output.outval..counter..','
            end
        end
        result_para = result_para:sub(1, -2)
        result_call = result_call:sub(1, -2)
    elseif metadata.type == ilk_keywords.solver_type.inverse then
        if metadata.ops.ik.kind == ilk_keywords.op_argument.inverse_kinematics.kind.position then
            result_decl = asn1_types.joint_state ..' '..variables.output.q_ik..';'
            result_para = asn1_types.joint_state ..' *'..variables.output.q_ik
            result_init = asn1_types.init.joint_state .. '('..variables.output.q_ik..');'
            result_call = variables.output.q_ik
        elseif metadata.ops.ik.kind == ilk_keywords.op_argument.inverse_kinematics.kind.velocity then
            result_decl = asn1_types.joint_state.. ' '..variables.output.qd_ik..';'
            result_para = asn1_types.joint_state.. ' *'..variables.output.qd_ik
            result_init = asn1_types.init.joint_state .. '('..variables.output.qd_ik..');'
            result_call = variables.output.qd_ik
        end
    end
    return result_decl, result_init, result_call, result_para
end


local function generate_solver_signatures(metadata)
    local result_decl = ''
    local result_call = ''
    local robot_name = metadata.ops.robot_name
    local input_transformations = ''   -- asn to kul
    local output_transformations = ''  -- kul to asn
    result_call = result_call .. constants.mc_variable .. ','
    if metadata.ops.type == ilk_keywords.solver_type.forward then
        result_decl = result_decl .. robot_name..'::'..constants.input_type..' '..variables.internal.input..'; '
        result_call = result_call .. ''..variables.internal.input..','
        input_transformations = input_transformations..
                generate_transformation_code(asn1_types.joint_state, variables.input.joint_state, constants.input_type, variables.internal.input)
        local counter = 0
        for i,v in pairs(metadata.ops.outputs) do
            if v.otype == 'pose' then
                counter = counter + 1
                result_decl = result_decl .. constants.backend_namespace..'::'..constants.pose_type..' '..variables.internal.output..''..counter..'; '
                result_call = result_call .. ''..variables.internal.output..''..counter..','
--                output_transformations = output_transformations..
--                        transformations.generate_transformation_code(constants.pose_type, variables.internal.output..counter, asn1_types.pose, variables.output.outval..counter)
                output_transformations = output_transformations..
                        transformations.generate_transformation_code(constants.orientation_type, 'kul::eg_get_rotation('..variables.internal.output..counter..')', asn1_types.orientation, '('..variables.output.outval..counter..'->orientation).')
                output_transformations = output_transformations..
                        transformations.generate_transformation_code(constants.position_type, 'kul::eg_get_position('..variables.internal.output..counter..')', asn1_types.position, variables.output.outval..counter..'->position.')

            elseif v.otype == 'jacobian' then
                counter = counter + 1
                result_decl = result_decl .. robot_name..'::'..constants.jacobian_type..' '..variables.internal.output..''..counter..'; '
                result_call = result_call .. ''..variables.internal.output..''..counter..','
                -- as this wrapper does not support returning Jacobians, no transformations are made.
            end
        end
        result_call = result_call:sub(1, -2)
    elseif metadata.ops.type == ilk_keywords.solver_type.inverse then
        if metadata.ops.ik.kind == ilk_keywords.op_argument.inverse_kinematics.kind.position then
            result_decl = result_decl .. constants.backend_namespace..'::'..constants.ik_pos_cfg..' '..variables.internal.configuration..'; '
            result_decl = result_decl .. constants.backend_namespace..'::'..constants.position_type ..' '..variables.internal.desired_position..'; '
            result_decl = result_decl .. constants.backend_namespace..'::'..constants.orientation_type ..' '..variables.internal.desired_orientation..'; '
            result_decl = result_decl .. robot_name ..'::' .. constants.input_type .. ' '..variables.internal.q_guess..'; '
            result_decl = result_decl .. robot_name ..'::' .. constants.input_type .. ' '..variables.internal.q_ik..'; '
            result_decl = result_decl .. constants.backend_namespace .. '::'..constants.ik_pos_dbg..' '..variables.internal.debug..'; '
            result_call = result_call .. ''..variables.internal.configuration..', '..variables.internal.desired_position..', '..variables.internal.desired_orientation..', '..variables.internal.q_guess..', '..variables.internal.q_ik..', '..variables.internal.debug..''
            input_transformations = input_transformations..
                generate_transformation_code(asn1_types.position, variables.input.position..'->', constants.position_type, variables.internal.desired_position)
            input_transformations = input_transformations..
                generate_transformation_code(asn1_types.orientation, '(*'..variables.input.orientation..').', constants.orientation_type, variables.internal.desired_orientation)
            output_transformations = output_transformations..
                    transformations.generate_transformation_code(constants.input_type, variables.internal.q_ik, asn1_types.joint_state, variables.output.q_ik)
        elseif metadata.ops.ik.kind == ilk_keywords.op_argument.inverse_kinematics.kind.velocity then
            result_decl = result_decl .. robot_name .. '::' .. constants.input_type .. ' '..variables.internal.q..'; '
            result_decl = result_decl .. constants.backend_namespace..'::'..constants.velocity_linear_type ..' '..variables.internal.vector..'; '
            result_decl = result_decl .. robot_name .. '::' .. constants.input_type .. ' '..variables.internal.qd_ik..'; '
            result_call = result_call .. ''..variables.internal.q..', '..variables.internal.vector..', '..variables.internal.qd_ik..''
            input_transformations = input_transformations..
                generate_transformation_code(asn1_types.joint_state, variables.input.q, constants.input_type, variables.internal.q)
            output_transformations = output_transformations..
                    transformations.generate_transformation_code(constants.input_type, variables.internal.qd_ik, asn1_types.joint_state, variables.output.qd_ik)
        end
    end
    return result_decl, result_call, input_transformations, output_transformations
end


local M = {}
M.generate_inputs = generate_inputs
M.generate_outputs = generate_outputs
M.generate_solver_signatures = generate_solver_signatures
return M
