#!/bin/sh

#if [ $# -eq 0 ]
#  then
#    echo "Error. No arguments supplied"
#    exit
#fi

dir_gen="output"

mkdir -p $dir_gen

 in_kindsl="../models/ur5/ur5-kul.kindsl"
  out_urdf="$dir_gen/ur5-kul.kindsl.urdf"
   in_urdf="../models/ur5/ur5-gmv.urdf"
out_kindsl="$dir_gen/ur5-gmv.urdf.kindsl"

urdf2kindsl="../../urdf2kindsl/urdf2kindsl.py"

# Conversions

echo "Converting $in_kindsl to URDF and back ..."
ilk-generator.sh --robot-model $in_kindsl --gen-urdf "$out_urdf"
$urdf2kindsl "$out_urdf" -o "$out_urdf.kindsl"

echo "Converting $in_urdf to KinDSL and back ..."
$urdf2kindsl $in_urdf -o "$out_kindsl"
ilk-generator.sh --robot-model "$out_kindsl" --gen-urdf "$out_kindsl.urdf"


# Some checks

echo "Generating diff between $in_kindsl and $out_urdf.kindsl ..."
cp ../utils/diff-style.css $dir_gen
../utils/diff2html.py --style-sheet diff-style.css $in_kindsl "$out_urdf.kindsl" > $dir_gen/kindsl_diff.html

echo "Checking kinematics of $in_urdf and $out_kindsl.urdf ..."
pos1=`$urdf2kindsl --link-origin wrist_3_link $in_urdf`
pos2=`$urdf2kindsl --link-origin wrist_3_link $out_kindsl.urdf`
echo "Position of wrist_3_link in model $in_urdf : $pos1" > $dir_gen/urdf_pos
echo "Position of wrist_3_link in model $out_kindsl.urdf : $pos2" >> $dir_gen/urdf_pos

echo ""
echo "... done. Please check the results in the $dir_gen folder"

