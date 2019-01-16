local M = {}

M.input = {}
M.input.joint_state = "IN_joints"
M.input.position = "IN_position"
M.input.orientation = "IN_orientation"
M.input.guess = "IN_guess"
M.input.q = "IN_q"
M.input.vector = "IN_vector"

M.output = {}
M.output.outval = "outval_"
M.output.q_ik = "OUT_q_ik"
M.output.qd_ik = "OUT_qd_ik"


M.internal = {}
M.internal.input = "input"
M.internal.output = "output_"
M.internal.configuration = 'cfg'
M.internal.desired_position = 'desired_position'
M.internal.desired_orientation = 'desired_orientation'
M.internal.q_guess = 'q_guess'
M.internal.q_ik = 'q_ik'
M.internal.debug = 'dbg'
M.internal.q = 'q'
M.internal.vector = 'vector'
M.internal.qd_ik = 'qd_ik'



return M

