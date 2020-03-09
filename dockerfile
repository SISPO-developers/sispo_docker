#References: 
#CONDA in docker: https://medium.com/@chadlagore/conda-environments-with-docker-82cdc9d25754
#https://github.com/r-pad/model_renderer


#Select parent image 
FROM continuumio/miniconda3

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


#Create directory for apps
RUN mkdir app

#Copy blender. We could also "git clone" but I don't think it is a good idea to let the
#the docker to clone the repo each time the image is build due to the small changes
#in the remote repo. The changes in the folder will cause the blender to be build again.
COPY ./blender ./app/blender

#compile blender bpy
COPY ./build_blender.sh /app/build_blender.sh
RUN /bin/bash /app/build_blender.sh

#Set the number of threads available for "make" (default: 4)
RUN cd /app/blender/build/ && make -j4 install

####Below this line do not make changes unless you want to invoke the blender build process again



#Copy sispo
COPY ./sispo ./app/sispo



##These are not workign currently
#RUN pip --no-cache-dir install OpenEXR
#RUN cd /app/sispo/ && python setup.py install
