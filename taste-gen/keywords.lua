local M = {}

local ops = {}
ops.compose = 'compose'
ops.output = 'output'
ops.model_constant = 'model_const'
ops.joint_local = 'model_T_joint_local'
ops.jacobian_poi = 'geom-jacobian'
ops.jacobian_compute = 'GJac-col'
ops.inverse_kinematics = 'ik'

local joint_types = {}
joint_types.prismatic = 'prismatic'
joint_types.revolute = 'revolute'

local oparguments = {}

local oparguments_joint_local = {}
oparguments_joint_local.joint_type = 'jtype'
oparguments_joint_local.direction = 'dir'
oparguments_joint_local.name = 'name'
oparguments_joint_local.input = 'input'
oparguments.joint_local = oparguments_joint_local

local oparguments_inverse_kinematics = {}
local kind = {}
kind.velocity = 'vel'
kind.position = 'pos'
oparguments_inverse_kinematics.kind = kind
local vectors = {}
vectors.linear = 'linear'
vectors.angular = 'angular'
vectors.pose = 'pose'
oparguments_inverse_kinematics.vector = vectors
oparguments.inverse_kinematics = oparguments_inverse_kinematics

local solver_types = {}
solver_types.forward = 'forward'
solver_types.inverse = 'inverse'

local configuration = {}
configuration.solver_id = 'solverid'
configuration.solver_type = 'solver_type'
configuration.robot_name = 'robot_name'

M.op = ops
M.joint_type = joint_types
M.op_argument = oparguments
M.configuration = configuration
M.solver_type = solver_types

return M