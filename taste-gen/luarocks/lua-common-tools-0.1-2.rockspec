package = "lua-common-tools"
version = "0.1-2"
source = {
  url    = "git://github.com/haianos/lua-common-tools",
  branch = "dev"
}
description = {
  summary  = "common Lua script tools",
  detailed = [[
    A collection of useful Lua Script, shared in different projects.
    This (Lua)rock only aid the installation of these.
  ]],
  license = "MIT"
}
dependencies = {
  "lua > 5.1"
}
build = {
  type = "builtin",
  modules = {
    utils      = "utils.lua",
    ansicolors = "ansicolors.lua",
    vlog       = "vlog.lua",
    uoo        = "uoo.lua",
  ['json-rpc'] = "json-rpc.lua"
  }
}
