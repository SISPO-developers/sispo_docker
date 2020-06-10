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

#Copy sispo
COPY ./sispo /app/sispo

#install sispo
SHELL ["conda", "run", "-n", "myenv", "/bin/bash", "-c"]
RUN cd /app/sispo && python setup.py install






