local function gen_user_init_bash(target, config)
  local ok, res = utils.preproc([[
echo -e "\033[0;36m====== RM-TOOL:: generating support library  ======\e[0;39m"
cd $(target)
if [ ! -d "dataview" ]; then
    echo -e "\033[0;36mERROR: Please copy the dataview directory (generated by TASTE) into the $(target) directory. It is required to build the solver bridge.\e[0;39m"
    exit 1
fi
cd rmtool
make
ORCHESTRATOR_OPTIONS+=" -e x86_partition:`pwd`"
ORCHESTRATOR_OPTIONS+=" -l x86_partition:`pwd`/$(config.bridge_library_name)"
cd ..
cd ..
echo -e "\e[36m====== RM-TOOL:: support library generated in kinblock/rmtool ======\e[39m"
ORCHESTRATOR_OPTIONS+=" -l x86_partition:$(config.solver_library_location)$(config.solver_library_name)"
ORCHESTRATOR_OPTIONS+=" -l x86_partition:/usr/local/lib/libilkeigenbackend.so"
]], { table=table,
  target=target, config=config
})  
  if not ok then error(res) end
  return res
end

local M = {}
M.gen_user_init_bash = gen_user_init_bash
return M
