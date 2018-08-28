#!/bin/sh

rm -rf generated

rm -rf compiled

GENERATION_ROOT=$KIN_GEN_ROOT/tests/generation
SAMPLE_QUERIES=$KIN_GEN_ROOT/tests/sample-queries

cd $KIN_GEN_ROOT
./ilk-generator.sh --robot $KIN_GEN_ROOT/tests/models/ur5/ur5-kul.kindsl --query $SAMPLE_QUERIES/sample_all/model/ur5.dtdsl --output-dir $GENERATION_ROOT/generated

cd $KIN_GEN_ROOT/ilk-compiler
./ilk-compiler.lua -b eigen --indir $GENERATION_ROOT/generated --outdir $GENERATION_ROOT/compiled

cd $GENERATION_ROOT/compiled
make tests

cp $SAMPLE_QUERIES/sample_all/fk-dataset.zip $GENERATION_ROOT/compiled/
unzip fk-dataset.zip
rm fk-dataset.zip
