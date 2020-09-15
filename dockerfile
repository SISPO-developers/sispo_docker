#Select parent image 
FROM nvidia/cuda:11.0-devel-ubuntu20.04

#how many threads are used to build with make
ENV THREADS=4

#supported cuda version (https://developer.nvidia.com/cuda-gpus)
ENV CUDA_VERSION=sm_61
#cmake will set this off if cuda is not found
ENV USE_CUDA=ON


#Set up Conda environment and python
ARG CONDA="Miniconda3-py37_4.8.3-Linux-x86_64.sh"
ARG CONDAREPO="https://repo.anaconda.com/miniconda/"$CONDA

ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"

RUN apt-get update \
	&& apt-get install -y wget \
	&& rm -rf /var/lib/apt/lists/*

RUN wget $CONDAREPO \
	&& bash $CONDA -b \
	&& rm -f $CONDA 


#Install some necessary dependencies for the blender and remove 
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y nano gcc g++ cmake gawk cmake cmake-curses-gui \
                      build-essential libjpeg-dev libpng-dev libtiff-dev \
                      git libfreetype6-dev libx11-dev flex bison libtbb-dev \
                      libxxf86vm-dev libxcursor-dev libxi-dev wget libsqlite3-dev \
                      libxrandr-dev libxinerama-dev libbz2-dev libncurses5-dev \
                      libssl-dev liblzma-dev libreadline-dev libopenal-dev \
                      libglew-dev yasm libtheora-dev libogg-dev \
                      libsdl1.2-dev libfftw3-dev patch bzip2 libxml2-dev \
                      libtinyxml-dev libjemalloc-dev libopenimageio-dev \
                      libopencolorio-dev libopenexr-dev libsndfile1-dev libx264-dev \
                      autotools-dev libtool m4 automake cmake libblkid-dev \
                      e2fslibs-dev libaudit-dev libavformat-dev ffmpeg libavdevice-dev \
                      libswscale-dev libalut-dev libalut0 libspnav-dev \
                      libspnav0 libboost-all-dev libpcl-dev libcgal-dev libeigen3-dev \
                      liblapack-dev  libflann-dev libceres-dev tzdata\
                      &&  rm -rf /var/lib/apt/lists/*
					

RUN apt-get update && apt-get -y install libopencv-dev &&  rm -rf /var/lib/apt/lists/*
RUN apt-get autoremove

#Create directory for apps
RUN mkdir app

#prepare for the compiling 
RUN cd app && git clone https://github.com/blender/blender.git
RUN cd /app/blender && git checkout blender-v2.82-release \
    && mkdir build \
    && git submodule update --init --recursive \
    && git submodule foreach git checkout master \
    && git submodule foreach git pull --rebase origin master 
	
#install dependencies, nice but takes forever
#RUN /bin/bash /app/blender/build_files/build_environment/install_deps.sh

ENV CONDA_ENV=/root/miniconda3/
ENV PYVERSION=3.7
ENV USE_CUDA=OFF
#compile blender bpy
RUN cd app/blender/build && cmake .. \
    -DWITH_PYTHON_INSTALL=OFF \
    -DWITH_PYTHON_MODULE=ON \
    -DWITH_INSTALL_PORTABLE=OFF \
    -DWITH_CYCLES_EMBREE=OFF \
    -DWITH_CYCLES=ON \
    -DWITH_CYCLES_DEVICE_CUDA=$USE_CUDA \
    -DWITH_CYCLES_CUDA_BINARIES=$USE_CUDA \
    -DCYCLES_CUDA_BINARIES_ARCH=$CUDA_VERSION \
    -DWITH_OPENSUBDIV=ON \
    -DWITH_OPENAL=OFF \
    -DWITH_CODEC_AVI=OFF \
    -DWITH_MOD_OCEANSIM=OFF \
    -DWITH_CODEC_FFMPEG=OFF \
    -DWITH_QUADRIFLOW=OFF \
    -DWITH_SYSTEM_GLEW=OFF \
    -DWITH_FFTW3=ON \
    -DWITH_INTERNATIONAL=OFF \
    -DWITH_BULLET=OFF \
    -DWITH_IK_SOLVER=OFF \
    -DWITH_IK_ITASC=OFF \
    -DWITH_PYTHON_INSTALL_NUMPY=OFF \
    -DWITH_MOD_FLUID=OFF \
    -DWITH_AUDASPACE=OFF \
    -DWITH_OPENCOLORIO=ON \
    -DPYTHON_ROOT_DIR=$CONDA_ENV/bin \
    -DPYTHON_SITE_PACKAGES=$CONDA_ENV/lib/python$PYVERSION/site-packages \
    -DPYTHON_INCLUDE_DIR="$CONDA_ENV/include/python${PYVERSION}m" \
    -DPYTHON_LIBRARY="$CONDA_ENV/lib/libpython${PYVERSION}m.so" \
    -DCMAKE_INSTALL_PREFIX=$CONDA_ENV/lib/python$PYVERSION/site-packages \
    -DPYTHON_VERSION=$PYVERSION \
    -DCMAKE_BUILD_TYPE:STRING=Release

#make and install
RUN cd /app/blender/build/ && make -j$THREADS install


#compile & install openMVG
ENV OPENMVG_PATH=/app/sispo/software/openMVG/build_openMVG
RUN mkdir -p $OPENMVG_PATH
RUN cd /app && git clone --recursive https://github.com/openMVG/openMVG.git

RUN cd /app/openMVG && mkdir build && cd build && \
        cmake 	../src/ \ 
            -DCMAKE_INSTALL_PREFIX=$OPENMVG_PATH/install \
            -DINCLUDE_INSTALL_DIR=$OPENMVG_PATH/install/include \
            -DPYTHON_EXECUTABLE=$PYENV/bin/python 

RUN cd /app/openMVG/build/ && make install -j$THREADS


#download & compile & install openMVS
ENV OPENMVS_PATH=/app/sispo/software/openMVS/build_openMVS
RUN mkdir -p $OPENMVS_PATH

RUN cd /app/ && git clone https://github.com/cdcseacave/openMVS.git
RUN cd /app/ && git clone https://github.com/cdcseacave/VCG.git
RUN mkdir /app/openMVS/build -p && cd /app/openMVS/build &&\
    cmake .. -DCMAKE_BUILD_TYPE=Release \
            -DVCG_DIR=/app/VCG/ \
            -DCMAKE_INSTALL_PREFIX=$OPENMVS_PATH/install \
            -DOpenMVS_USE_CUDA=OFF \
            -DOpenMVS_USE_BREAKPAD=OFF 

#Don't try to compile with multiple threads. Crashes the compilation eventually,
#Been there, done that, and wasted my precious life
RUN cd /app/openMVS/build/ && make install

RUN cd /app/ && git clone https://github.com/Bill-Gray/star_cats.git
RUN cd /app/star_cats/ && make

#Copy sispo
COPY ./sispo /app/sispo

#install sispo
ENV SISPO_CATALOG_PATH=/app/sispo/software/star_cats/build_star_cats
RUN mkdir -p $SISPO_CATALOG_PATH
RUN cp /app/star_cats/cmcrange $SISPO_CATALOG_PATH/
RUN cp /app/star_cats/cmc_xvt $SISPO_CATALOG_PATH/
RUN cp /app/star_cats/extr_cmc $SISPO_CATALOG_PATH/
RUN cp /app/star_cats/u4test $SISPO_CATALOG_PATH/

RUN conda install -c conda-forge orekit 
RUN cd /app/sispo && python setup.py install

#BPY was build using jemalloc so it needs to be preloaded when calling it
RUN echo 'alias python="LD_PRELOAD=/lib/x86_64-linux-gnu/libjemalloc.so.2 python"' >> ~/.bashrc  

