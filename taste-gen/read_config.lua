local function read_config(config_filename)
    local filename = config_filename or 'config.yml'
    local yaml = require('yaml')
    local config_file = io.open(filename,'r')
    local str = config_file:read("*all")
    local config = yaml.load(str)
    return config
end

local M = {}
M.read_config = read_config
return M