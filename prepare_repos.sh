#!/bin/bash

CURWRKDIR=pwd

##SISPO
git clone https://github.com/YgabrielsY/sispo.git
mkdir ./sispo/data/results
mkdir ./sispo/data/UCAC4

git clone https://github.com/cdcseacave/openMVS.git openMVS
git clone https://github.com/cdcseacave/VCG.git
git clone --recursive https://github.com/openMVG/openMVG.git
git clone https://github.com/Bill-Gray/star_cats.git



#cd ./sispo/software

#star cats
#mkdir star_cats
#cd star_cats
#git clone https://github.com/Bill-Gray/star_cats.git
#mkdir build_star_cats

#cd $CURWRKDIR





##BLENDER
#git clone https://github.com/blender/blender.git
#cd blender
##prepare for the compiling
#mkdir build
#git submodule update --init --recursive
#git submodule foreach git checkout master
#git submodule foreach git pull --rebase origin master



