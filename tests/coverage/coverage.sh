#!/bin/sh

rm -rf generated

rm -rf compiled

COVERAGE_ROOT=$KIN_GEN_ROOT/tests/coverage
SAMPLE_QUERIES=$KIN_GEN_ROOT/tests/sample-queries

cd $KIN_GEN_ROOT
./ilk-generator.sh --robot $SAMPLE_QUERIES/sample_"$1"/model/ur5.kindsl --query $SAMPLE_QUERIES/sample_"$1"/model/ur5.dtdsl --output-dir $COVERAGE_ROOT/generated

cd $KIN_GEN_ROOT/ilk-compiler
./ilk-compiler.lua -b eigen --indir $COVERAGE_ROOT/generated --outdir $COVERAGE_ROOT/compiled

cd $COVERAGE_ROOT/compiled
make ur5_"$1"_timing_dbg

./ur5_"$1"_timing_dbg 1 1

gcov --relative-only ur5_"$1"_timing.cpp
lcov --no-external -t "blah" -o ur5_"$1"_timing.info -c -d `pwd` -d `pwd`
genhtml -o ../coverage_html_"$1"/ ur5_"$1"_timing.info

