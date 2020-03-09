#!/bin/bash

##SISPO
git clone https://github.com/YgabrielsY/sispo.git
##Let's not bloat the docker image
rm -rf ./sispo/doc ./sispo/.git  

##BLENDER
git clone https://github.com/blender/blender.git
cd blender
##prepare for the compiling
mkdir build
git submodule update --init --recursive
git submodule foreach git checkout master
git submodule foreach git pull --rebase origin master
##Let's not bloat the docker image
rm -rf ./blender/.git/


