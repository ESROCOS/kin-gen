#!/bin/sh

if [ $# -eq 0 ]
  then
    echo "Error. No arguments supplied"
    exit
fi

STARTDIR=`pwd`


 ROB=$1
URDF="`basename $ROB`.urdf"

ilk-generator.sh --robot-model $ROB --gen-urdf $URDF

../../urdf2kindsl/urdf2kindsl.py $URDF -o "$URDF.kindsl"


