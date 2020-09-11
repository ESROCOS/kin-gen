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
kindsl2urdf="rmtool.sh exp -f urdf"

# Conversions

echo "Converting $in_kindsl to URDF and back ..."
$kindsl2urdf -o  $out_urdf          $in_kindsl
$urdf2kindsl -o "$out_urdf.kindsl"  $out_urdf

echo "Converting $in_urdf to KinDSL and back ..."
$urdf2kindsl -o "$out_kindsl"      $in_urdf
$kindsl2urdf -o "$out_kindsl.urdf" $out_kindsl


# Some checks

echo "Generating diff between $in_kindsl and $out_urdf.kindsl ..."
cp ../utils/diff-style.css $dir_gen
../utils/diff2html.py --style-sheet diff-style.css $in_kindsl "$out_urdf.kindsl" > $dir_gen/kindsl_diff.html

echo "Checking kinematics of $in_urdf and $out_kindsl.urdf ..."
pos1=`$urdf2kindsl --link-origin wrist_3 $in_urdf`
pos2=`$urdf2kindsl --link-origin wrist_3 $out_kindsl.urdf`
echo "Position of wrist_3_link in model $in_urdf : $pos1" > $dir_gen/urdf_pos
echo "Position of wrist_3_link in model $out_kindsl.urdf : $pos2" >> $dir_gen/urdf_pos

echo ""
echo "... done. Please check the results in the $dir_gen folder"

