## sispo_docker 

#### Requirements:

CUDA capable GPU. Check other branches for the CPU version of the Sispo docker file. CUDA support for docker won't work with Windows

#### Install Docker:

Docker version 19.0 at least or nvidia-docker, which is not tested.

##### Windows:

You will need to install **Docker for windows** (for <u>Professional</u> etc.) or **Docker Toolbox** (for <u>Home edition</u>). For Docker toolbox follow: https://docs.docker.com/toolbox/toolbox_install_windows/

After the installation is complete: run **Docker QuickStart Terminal** and increase the size of the VM partition (default 10gb is not enough) and specify how many cores you want to give to the VM:

```
docker-machine rm default
docker-machine create -d virtualbox --virtualbox-memory=4096 --virtualbox-cpu-count=2 --virtualbox-disk-size=50000 default
```

https://www.ibm.com/developerworks/community/blogs/jfp/entry/Using_Docker_Machine_On_Windows?lang=en

Restart Docker.

**Hint:** Sometimes the VM process is not killed with the Docker, so you might need to kill it manually from the task manager.

##### Linux:

You are on your own buddy, because I don't remember anymore what I did. The installation was pretty straightforward, so no worry. Just remember to update your GPU drivers.





#### Dependencies:

Download all the necessary repositories:

```bash
bash prepare_repos.sh
```

Modify *"dockerfile"* lines 

`ENV THREADS=4`

`ENV BLENDERCUDAVERSION=sm_61`

to control how many threads are used during the compile process (Windows user need to also modify the VM parameters, see above).

Finally find the CUDA version your GPU supports: https://developer.nvidia.com/cuda-gpus

If GPU is not available, the Blender will be built for CPU only.

If the error message `docker: Error response from daemon: could not select device driver "" with capabilities: [[gpu]].` it might be nessecary to install `nvidia-container-runtime`. A guide can be found here https://collabnix.com/introducing-new-docker-cli-api-support-for-nvidia-gpus-under-docker-engine-19-03-0-beta-release/

##### Build Docker image

Go to the sispo_docker folder (Windows users need to use **Docker QuickStart Terminal** )  and run. 

```
docker build -t dockerfile .
```



##### Run a container

Docker requires absolute paths if you want to sync a local folder with the container (sync with the "-v"). This way you can modify and access files from the container.

```
docker run --gpus=1 -v ABSOLUTE_PATH_TO_SISPO_DATA:/app/sispo/data/ -v ABSOLUTE_PATH_TO_SISPO_FOLDER:/app/sispo/ --name WALTERWHITE -dit dockerfile
```

##### Run a command in a running container

```
docker exec -it WALTERWHITE /bin/bash
```

##### Some useful commands

Remove old image 

```
docker rm -f WALTERWHITE
```

Docker requires a lot of space, so sometimes it is good 

Remove all unused containers, networks, images (both dangling and unreferenced), and optionally, volumes. (include -a to remove everything, but be ready to build the image from the start)

```
docker system prune
```




