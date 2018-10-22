#!/bin/sh

rm -rf report
mkdir report

./timing.sh fk1 100 100000
./timing.sh ik1 100 100000
./timing.sh ik2 100 100000
./timing.sh ik3 100 100000
./timing.sh ik4 100 100000
./timing.sh ik5 100 100000
./timing.sh ik6 100 100000

rm -rf generated
rm -rf compiled
