#!/bin/sh

eval `luarocks path`
LUA_PATH="$LUA_PATH;$KIN_GEN_ROOT/ilk-compiler/lua/?.lua" \
$KIN_GEN_ROOT/ilk-compiler/lua/ilk-compiler.lua "$@"
