#References: 
#CONDA in docker: https://medium.com/@chadlagore/conda-environments-with-docker-82cdc9d25754
#https://github.com/r-pad/model_renderer

#Select parent image 
FROM nvidia/cuda:10.1-devel-ubuntu18.04


##how many threads are used to build with make
ENV THREADS=4
##supported cuda version (https://developer.nvidia.com/cuda-gpus)
ENV BLENDERCUDAVERSION=sm_61
ENV USECUDA=ON


#https://github.com/ContinuumIO/docker-images/blob/master/miniconda3/debian/Dockerfile
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update --fix-missing && \
    apt-get install -y wget bzip2 ca-certificates libglib2.0-0 libxext6 libsm6 libxrender1 git mercurial subversion && \
    apt-get clean

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc && \
    find /opt/conda/ -follow -type f -name '*.a' -delete && \
    find /opt/conda/ -follow -type f -name '*.js.map' -delete && \
    /opt/conda/bin/conda clean -afy

CMD [ "/bin/bash" ]


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
                      libglew-dev yasm libtheora-dev libogg-dev \
                      libsdl1.2-dev libfftw3-dev patch bzip2 libxml2-dev \
                      libtinyxml-dev libjemalloc-dev libopenimageio-dev \
                      libopencolorio-dev libopenexr-dev libsndfile1-dev libx264-dev \
                      autotools-dev libtool m4 automake cmake libblkid-dev \
                      e2fslibs-dev libaudit-dev libavformat-dev ffmpeg libavdevice-dev \
                      libswscale-dev libalut-dev libalut0 libspnav-dev \
                      libspnav0 libboost-all-dev libpcl-dev libcgal-dev libeigen3-dev \
                      liblapack-dev  libflann-dev libceres-dev \
                      &&  rm -rf /var/lib/apt/lists/*

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

#apply a patch
RUN find /app/blender/intern/cycles/subd/../util/util_param.h -type f -exec sed -i 's/constexpr/const/g' {} \;


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
    -DWITH_CYCLES_DEVICE_CUDA=$USECUDA \
    -DWITH_CYCLES_CUDA_BINARIES=$USECUDA \
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
    -DCYCLES_CUDA_BINARIES_ARCH=$BLENDERCUDAVERSION \
    -DCMAKE_BUILD_TYPE:STRING=Release ..


#Set the number of threads available for "make" (default: 4)
RUN cd /app/blender/build/ && make -j$THREADS install

####Above this line do not make changes unless you want to invoke the blender build process again




#compile & install star_cat
ENV SISPOSOFT=/app/sispo/software/star_cats/build_star_cats
COPY ./star_cats /app/star_cats
RUN cd /app/star_cats && make
RUN mkdir -p $SISPOSOFT
RUN cp /app/star_cats/cmcrange $SISPOSOFT/
RUN cp /app/star_cats/cmc_xvt $SISPOSOFT/
RUN cp /app/star_cats/extr_cmc $SISPOSOFT/





#compile & install openMVS
ENV OPENMVSSOFT=/app/sispo/software/openMVS/build_openMVS
COPY ./VCG /app/VCG
COPY ./openMVS /app/openMVS
RUN mkdir -p $OPENMVSSOFT 







ENV OpenCV_DIR=/opt/conda/envs/myenv/lib/cmake/

RUN cd /app/openMVS && mkdir -p build && cd build && \
         cmake .. \
	-DCMAKE_BUILD_TYPE=Release \
	-DVCG_DIR=/app/VCG/ \
	-DCMAKE_INSTALL_PREFIX=$OPENMVSSOFT/install \
    -DOpenMVS_USE_CUDA=OFF \
    -OpenMVS_USE_BREAKPAD=OFF
        

RUN cd /app/openMVS/build/ && make install -j$THREADS

#compile & install openMVG
ENV OPENMVGSOFT=/app/sispo/software/openMVG/build_openMVG
COPY ./openMVG /app/openMVG
RUN mkdir -p $OPENMVGSOFT

RUN cd /app/openMVG && mkdir build && cd build && \
        cmake 	../src/ \ 
                -DCMAKE_INSTALL_PREFIX=$OPENMVGSOFT/install \
                -DINCLUDE_INSTALL_DIR=$OPENMVGSOFT/install/include \
                -DPYTHON_EXECUTABLE=$PYENV/bin/python 

RUN cd /app/openMVG/build/ && make install -j$THREADS





RUN cp /app/star_cats/cmcrange $SISPOSOFT/
RUN cp /app/star_cats/cmc_xvt $SISPOSOFT/
RUN cp /app/star_cats/extr_cmc $SISPOSOFT/
RUN cp /app/star_cats/u4test $SISPOSOFT/




#Copy sispo
COPY ./sispo /app/sispo

#install sispo
SHELL ["conda", "run", "-n", "myenv", "/bin/bash", "-c"]
RUN cd /app/sispo && python setup.py install






