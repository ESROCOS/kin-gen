#!/bin/sh

WD=`pwd`
ILKGEN_DIR=$WD/generated
CPPGEN_DIR=$WD/compiled
REPORT_DIR=$WD/report

rm -rf $ILKGEN_DIR
rm -rf $CPPGEN_DIR
rm -rf $REPORT_DIR

FUNCTIONAL_ROOT=$KIN_GEN_ROOT/tests/functional
SAMPLE_QUERIES=$KIN_GEN_ROOT/tests/sample-queries

cd $KIN_GEN_ROOT
./ilk-generator.sh --kindsl  $KIN_GEN_ROOT/tests/models/ur5/ur5-kul.kindsl --query $SAMPLE_QUERIES/query-ur5-sample.yaml --output-dir $ILKGEN_DIR
if [ $? != 0 ]
then
    echo "The ilk-generator failed, aborting"
    exit 1
else
    echo "The ILK-Generator ran successfully"
fi

cd $KIN_GEN_ROOT
./ilk-compiler.sh -b eigen $ILKGEN_DIR/ $CPPGEN_DIR/
if [ $? != 0 ]
then
    echo "The ilk-compiler failed, aborting"
    exit 1
else
    echo "The ILK-Compiler ran successfully"
fi

cd $CPPGEN_DIR
rm -rf build && mkdir build && cd build && cmake -DBuildTests=ON ..
make -j4


mkdir $REPORT_DIR

./fk1-cmp $SAMPLE_QUERIES/fk-dataset > $REPORT_DIR/fk1.txt
./ik1-fk-consistency > $REPORT_DIR/ik1.txt
./ik2-fk-consistency > $REPORT_DIR/ik2.txt


