#!/usr/bin/env lua

utils = require('utils')
local ansicolors = require('ansicolors')
local vlog  = require('vlog')

helpers = require('helpers')
common = require('common')
makefile_generator = require('makefile_generator')
gen_uc_wrapper = require('usercode_wrapper_generator')
gen_user_init_bash = require('user_init_bash_generator')
config_reader = require('read_config')





---
-- Program enters here
-----------------------------------
local opttab=utils.proc_args(arg)

if opttab['-h'] then usage(); os.exit(1) end

--[[ List of the information needed
     * outdir
     * name of the function block name
     * interface type (s[poradic], [p]rotected or [u]nprotected)
     * list of solvers implemented in generated library
--]] 

config = config_reader.read_config("config.yml")

globals = { robot_name=config.robot_name }



outdir = config.output_directory
taste_fnc_block = config.block_name
interface = string.sub(config.interface_type,1,1)
sporadic = interface == 's'
solver_filename = config.solver_filename
solver_functions = config.solver_functions
model_constants = config.model_constants

local metadata = config_reader.read_config("metadata.yml")
local _, meta_first = next(metadata)
metadata.robot_name = meta_first.ops.robot_name


-- Create glue-code folder
os.execute('mkdir -p '..outdir..'/'..taste_fnc_block)
os.execute('mkdir -p '..outdir..'/'..taste_fnc_block..'/rmtool')

-- create taste-mockup.h

-- create user-code

local bridgeHeaderFileName = taste_fnc_block..'-bridge.h'
local blockOutDir = outdir..'/'..taste_fnc_block
local staticConversionsHeaderFileName = 'static_conversions.h'

metadata.static_conversions_header = staticConversionsHeaderFileName

local content = ""
content = gen_uc_wrapper.gen_uc_wrapper_header(taste_fnc_block, solver_functions, metadata)
helpers.write_out_file(blockOutDir..'/rmtool/', bridgeHeaderFileName, content)

content = gen_uc_wrapper.gen_uc_wrapper_source(taste_fnc_block, solver_functions, solver_filename, model_constants, metadata)
helpers.write_out_file(blockOutDir..'/rmtool/', taste_fnc_block..'-bridge.cc', content)

os.execute('cp type_conversions/'..staticConversionsHeaderFileName..' '.. blockOutDir..'/rmtool/')

-- Then copying the header...
os.execute('cp '..blockOutDir..'/rmtool/'..taste_fnc_block..'-bridge.h '..outdir..'/'..taste_fnc_block..'/')

-- create makefile
content = makefile_generator.gen_rmtool_makefile(taste_fnc_block)
helpers.write_out_file(blockOutDir..'/rmtool/', 'Makefile', content)
-- create testing

-- generate bash script
content = gen_user_init_bash.gen_user_init_bash(taste_fnc_block, config)
helpers.write_out_file(outdir..'/', 'user_init_pre.sh', content)


  
