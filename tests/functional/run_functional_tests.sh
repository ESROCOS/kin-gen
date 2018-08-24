#!/bin/sh

rm -rf generated

rm -rf compiled

rm -rf report

FUNCTIONAL_ROOT=$KIN_GEN_ROOT/tests/functional
SAMPLE_QUERIES=$KIN_GEN_ROOT/tests/sample-queries

cd $KIN_GEN_ROOT
./ilk-generator.sh --robot $SAMPLE_QUERIES/sample_all/model/ur5.kindsl --query $SAMPLE_QUERIES/sample_all/model/ur5.dtdsl --output-dir $FUNCTIONAL_ROOT/generated

cd $KIN_GEN_ROOT/ilk-compiler
./ilk-compiler.lua -b eigen --indir $FUNCTIONAL_ROOT/generated --outdir $FUNCTIONAL_ROOT/compiled

cd $FUNCTIONAL_ROOT/compiled
make tests

cp $SAMPLE_QUERIES/sample_all/fk-dataset.zip $FUNCTIONAL_ROOT/compiled/
unzip fk-dataset.zip

mkdir $FUNCTIONAL_ROOT/report

./ur5_fk1_test fk-dataset >$FUNCTIONAL_ROOT/report/fk1.txt
./ur5_ik1_test >$FUNCTIONAL_ROOT/report/ik1.txt
./ur5_ik2_test >$FUNCTIONAL_ROOT/report/ik2.txt

rm -rf $FUNCTIONAL_ROOT/compiled
rm -rf $FUNCTIONAL_ROOT/generated
