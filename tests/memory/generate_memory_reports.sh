#!/bin/sh

rm -rf report
mkdir report
./memory.sh fk1
./memory.sh ik1
./memory.sh ik2
./memory.sh ik3
./memory.sh ik4
./memory.sh ik5
./memory.sh ik6

rm -rf generated
rm -rf compiled
