#!/bin/sh

export PYTHONPATH="$PYTHONPATH:$KIN_GEN_ROOT/robot-model-tools:$KIN_GEN_ROOT/ilk-generator"

$KIN_GEN_ROOT/ilk-generator/ilkgen.py $@

