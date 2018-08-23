#!/bin/sh

REALROOT="$KIN_GEN_ROOT/ilk-generator/building/0build"

CP=`find $REALROOT/lib/ -name '*.jar' | tr '\n' ':'`

java -Dlog4j.configuration=file:$REALROOT/log4j.cfg -cp "$CP":$REALROOT/bin/ eu.esrocos.kul.Main "$@"
