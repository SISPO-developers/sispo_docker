#References: 
#CONDA in docker: https://medium.com/@chadlagore/conda-environments-with-docker-82cdc9d25754
#https://github.com/r-pad/model_renderer

#Select parent image 
FROM continuumio/miniconda3


ENV THREADS=4


#Make the conda environment to work in the docker image
ADD environment.yml /tmp/environment.yml
RUN conda env create -f /tmp/environment.yml

#Install some necessary dependencies for the blender and remove 
RUN apt-get update && apt-get install -y nano gcc g++ cmake gawk cmake cmake-curses-gui \
                      build-essential libjpeg-dev libpng-dev libtiff-dev \
                      git libfreetype6-dev libx11-dev flex bison libtbb-dev \
                      libxxf86vm-dev libxcursor-dev libxi-dev wget libsqlite3-dev \
                      libxrandr-dev libxinerama-dev libbz2-dev libncurses5-dev \
                      libssl-dev liblzma-dev libreadline-dev libopenal-dev \
                      libglew-dev yasm libtheora-dev libvorbis-dev libogg-dev \
                      libsdl1.2-dev libfftw3-dev patch bzip2 libxml2-dev \
                      libtinyxml-dev libjemalloc-dev libjpeg-dev libopenimageio-dev \
                      libopencolorio-dev libopenexr-dev libsndfile1-dev libx264-dev \
                      autotools-dev libtool m4 automake cmake libblkid-dev \
                      e2fslibs-dev libaudit-dev libavformat-dev ffmpeg libavdevice-dev \
                      libswscale-dev libalut-dev libalut0 libmp3lame-dev libspnav-dev \
                      libspnav0 libboost-all-dev &&  rm -rf /var/lib/apt/lists/*

# Pull the environment name out of the environment.yml
RUN echo "source activate $(head -1 /tmp/environment.yml | cut -d' ' -f2)" > ~/.bashrc
ENV PATH /opt/conda/envs/$(head -1 /tmp/environment.yml | cut -d' ' -f2)/bin:$PATH

ENV PYENV=/opt/conda/envs/myenv
ENV PYVERSION=3.7


#Create directory for apps
RUN mkdir app

#Copy blender. We could also "git clone" but I don't think it is a good idea to let the
#the docker to clone the repo each time the image is build due to the small changes
#in the remote repo. The changes in the folder will cause the blender to be build again.
COPY ./blender ./app/blender

#compile blender bpy
RUN cd app/blender/build && cmake -DCMAKE_INSTALL_PREFIX=$PYENV/lib/python$PYVERSION/site-packages \
    -DWITH_PYTHON_INSTALL=OFF \
    -DWITH_PYTHON_MODULE=ON \
    -DPYTHON_ROOT_DIR=$PYENV/bin \
    -DPYTHON_SITE_PACKAGES=$PYENV/lib/python$PYVERSION/site-packages \
    -DPYTHON_INCLUDE_DIR="$PYENV/include/python${PYVERSION}m" \
    -DPYTHON_LIBRARY="$PYENV/lib/libpython${PYVERSION}m.so" \
    -DPYTHON_VERSION=$PYVERSION \
    -DWITH_INSTALL_PORTABLE=OFF \
    -DWITH_CYCLES_EMBREE=OFF \
    -DWITH_CYCLES=ON \
    -DWITH_CYCLES_DEVICE_CUDA=OFF \
    -DWITH_OPENSUBDIV=ON \
    -DWITH_OPENAL=OFF \
    -DWITH_CODEC_AVI=OFF \
    -DWITH_MOD_OCEANSIM=OFF \
    -DWITH_CODEC_FFMPEG=OFF \
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
    -DCMAKE_BUILD_TYPE:STRING=Release ..


#Set the number of threads available for "make" (default: 4)
RUN cd /app/blender/build/ && make -j$THREADS install

####Above this line do not make changes unless you want to invoke the blender build process again






#add preloading for jemalloc
#blender uses jemalloc, we could compile blender without jemalloc, but jemalloc
#offers better memory management (python and blender can cause memory fragmentation)
RUN echo "alias python=\"LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2 python\"" >> /root/.bashrc





