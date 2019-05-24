#!/bin/sh

WD=`pwd`

ilk-generator.sh --kindsl tests/models/ur5/ur5-kul.kindsl \
                 --query tests/sample-queries/query-ur5-sample.yaml \
                 --output-dir /tmp/kin-gen/ilk

ilk-compiler.sh -b eigen /tmp/kin-gen/ilk /tmp/kin-gen/cpp

cd /tmp/kin-gen/cpp && rm -rf build && mkdir build && cd build && cmake ..
make -j4 && sudo make install
if [ $? != 0 ]
then
    echo "Failed to build or install the generated C++ code; did you build and install the Eigen backend of the ilk-compiler?"
    exit 1
fi

cd $WD/taste-gen && cp /tmp/kin-gen/cpp/metadata.yml .
eval `luarocks path`
./GenerateTasteBlock.lua
