local M = {}

M.types = {}
M.types.pose        = {original='asn1SccBase_Pose'           , alias='asn1_t_pose'      }
M.types.joint_state = {original='asn1SccBase_JointState'     , alias='asn1_t_jointstate'}
M.types.vector_3d   = {original='asn1SccWrappers_Vector3d'   , alias='asn1_t_vec3'      }
M.types.orientation = {original='asn1SccWrappers_Quaterniond', alias='asn1_t_quat'      }
M.types.position    = {original='asn1SccWrappers_Vector3d'   , alias='asn1_t_pos3'      }
M.types.rot_m_t     = {original='asn1SccWrappers_Quaterniond', alias='asn1_t_quat'      }

-- these below are for backward compatibility with Pawel's code

M.pose        = M.types.pose       .original
M.joint_state = M.types.joint_state.original
M.vector_3d   = M.types.vector_3d  .original
M.orientation = M.types.orientation.original
M.position    = M.types.position   .original
M.rot_m_t     = M.types.rot_m_t    .original


local sortedTypes = {}
for k,_ in pairs(M.types) do
  table.insert(sortedTypes, k)
end
table.sort(sortedTypes) -- sort the values alphabetically
                        -- but the values here are the keys of the M.types table

local initialize = {}
initialize.pose = 'asn1SccBase_Pose_Initialize'
initialize.joint_state = 'asn1SccBase_JointState_Initialize'


local function typedefsBlock()
  local text = ''
  for i, type in ipairs(sortedTypes) do
    local typedata = M.types[type]
    text = text .. 'typedef ' .. typedata.original .. ' ' .. typedata.alias .. ';\n'
  end
  return text
end

M.init = initialize
M.typedefsBlock = typedefsBlock

return M
