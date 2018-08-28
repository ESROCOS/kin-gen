#!/bin/sh

rm -rf generated

rm -rf compiled

MEMORY_ROOT=$KIN_GEN_ROOT/tests/memory
SAMPLE_QUERIES=$KIN_GEN_ROOT/tests/sample-queries

cd $KIN_GEN_ROOT
./ilk-generator.sh --robot $KIN_GEN_ROOT/tests/models/ur5/ur5-kul.kindsl --query $SAMPLE_QUERIES/sample_"$1"/model/ur5.dtdsl --output-dir $MEMORY_ROOT/generated

cd $KIN_GEN_ROOT/ilk-compiler
./ilk-compiler.lua -b eigen --indir $MEMORY_ROOT/generated --outdir $MEMORY_ROOT/compiled

cd $MEMORY_ROOT/compiled
make ur5_"$1"_timing_dbg

valgrind --leak-check=yes --log-file=$MEMORY_ROOT/report/"$1".txt ./ur5_"$1"_timing_dbg 1 1

