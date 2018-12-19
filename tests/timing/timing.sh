#!/bin/sh

rm -rf generated

rm -rf compiled 

TIMING_ROOT=$KIN_GEN_ROOT/tests/timing
SAMPLE_QUERIES=$KIN_GEN_ROOT/tests/sample-queries

cd $KIN_GEN_ROOT
./ilk-generator.sh --robot $KIN_GEN_ROOT/tests/models/ur5/ur5-kul.kindsl --query $SAMPLE_QUERIES/sample_"$1"/model/ur5.dtdsl --output-dir $TIMING_ROOT/generated

cd $KIN_GEN_ROOT/ilk-compiler
./ilk-compiler.lua -b eigen --indir $TIMING_ROOT/generated --outdir $TIMING_ROOT/compiled


cd $TIMING_ROOT/compiled


make ur5_"$1"_timing

./ur5_"$1"_timing $2 $3 >$TIMING_ROOT/report/"$1".txt
