#!/bin/sh

rm -rf coverage_html_*

./coverage.sh fk1
./coverage.sh ik1
./coverage.sh ik2
./coverage.sh ik3
./coverage.sh ik4
./coverage.sh ik5
./coverage.sh ik6

rm -rf generated
rm -rf compiled
