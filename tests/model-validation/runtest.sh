#!/bin/sh

ilkgen="ilk-generator.sh --gen-urdf /dev/null --robot-model"

echo "Trying ../models/cmm/robot.kindsl ..."
$ilkgen ../models/cmm/robot.kindsl
echo ""
echo ""

echo "Trying ../models/malformed/cmm-typo.kindsl ..."
$ilkgen ../models/malformed/cmm-typo.kindsl
echo ""
echo ""

echo "Trying ../models/malformed/cmm-numbering.kindsl ..."
$ilkgen ../models/malformed/cmm-numbering.kindsl
echo ""
echo ""

echo "Trying ../models/malformed/cmm-disconnected.kindsl ..."
$ilkgen ../models/malformed/cmm-disconnected.kindsl
echo ""
echo ""

