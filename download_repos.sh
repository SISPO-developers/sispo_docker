#!/bin/bash

#Container has ubuntu so users who build the container using Windows may have
#problems with CLRF (line endings are different in unix and windows)
#In order to avoid conversion from CLRF to RF while building core.autocrlf=false is enforced.
#Better solution is to just bite the bullet and do the conversion

#Download sispo and create and some necessary folders used during the simulation
function download_sispo {
    git clone https://github.com/YgabrielsY/sispo.git --config core.autocrlf=false
    mkdir -p ./sispo/data/results
    mkdir -p ./sispo/data/UCAC4  
}

download_sispo
