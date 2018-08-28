#!/bin/sh

eval `luarocks path`
export LUA_PATH="$LUA_PATH;$KIN_GEN_ROOT/ilk-compiler/?.lua"
$KIN_GEN_ROOT/ilk-compiler/ilk-compiler.lua "$@"
