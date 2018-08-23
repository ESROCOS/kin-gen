#!/bin/sh

#if [ $# -eq 0 ]
#  then
#    echo "Error. No arguments supplied"
#    exit
#fi

dir_gen="gen"

mkdir -p $dir_gen

 in_kindsl="input/ur5.kindsl"
  out_urdf="$dir_gen/ur5.kindsl.urdf"
   in_urdf="input/ur5-gmv.urdf"
out_kindsl="$dir_gen/ur5-gmv.urdf.kindsl"

# Convert from KinDSL to URDF and back

ilk-generator.sh --robot-model $in_kindsl --gen-urdf "$out_urdf"
../../urdf2kindsl/urdf2kindsl.py "$out_urdf" -o "$out_urdf.kindsl"

# Convert from URDF to KinDSL and back

../../urdf2kindsl/urdf2kindsl.py $in_urdf -o "$out_kindsl"
ilk-generator.sh --robot-model "$out_kindsl" --gen-urdf "$out_kindsl.urdf"
