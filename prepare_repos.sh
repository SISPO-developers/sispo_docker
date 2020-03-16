#!/bin/bash

CURWRKDIR=pwd


#Download sispo and create and some necessary folders used during the simulation
function download_sispo {
    git clone https://github.com/YgabrielsY/sispo.git
    mkdir -p ./sispo/data/results
    mkdir -p ./sispo/data/UCAC4  
}


#Download blender and and some dependencies
function download_blender {
    git clone https://github.com/blender/blender.git
    
    cd blender
    git checkout blender-v2.82-release
    #prepare for the compiling
    mkdir build
    git submodule update --init --recursive
    git submodule foreach git checkout master
    git submodule foreach git pull --rebase origin master
    cd ..
}


#Download star_cats
function download_star_cats {
    git clone https://github.com/Bill-Gray/star_cats.git
    mkdir -p ./sispo/software/star_cats/build_star_cats
}


#Download openmvg and dependencies
function download_openmvg {
    git clone https://github.com/cdcseacave/VCG.git
    git clone --recursive https://github.com/openMVG/openMVG.git
}


function download_openmvs {
    git clone https://github.com/cdcseacave/openMVS.git openMVS
}


download_sispo
git clone git@github.com:thvaisa/DES.git
git clone git@github.com:thvaisa/DKE.git
download_openmvs
download_openmvg
download_star_cats
download_blender










