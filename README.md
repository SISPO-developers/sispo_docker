## Sispo Docker

Docker Image is used to deploy Sispo quickly. You only need a computer capable of running Docker (tested on Windows (HOME) and Linux (16.04)), build the image yourself, and run the container.

**Requirements:**

##### Windows:

You will need to install **Docker for Windows** (for Professional etc.) or **Docker Toolbox** (for Home edition). For the Docker toolbox follow: https://docs.docker.com/toolbox/toolbox_install_windows/

After the installation is complete: run **Docker QuickStart Terminal** and increase the size of the VM, virtual machine) partition (default 10gb is not enough) and specify how many cores you want to give to the VM

```
docker-machine rm default
docker-machine create -d virtualbox --virtualbox-memory=4096 --virtualbox-cpu-count=2 --virtualbox-disk-size=50000 default
```

https://www.ibm.com/developerworks/community/blogs/jfp/entry/Using_Docker_Machine_On_Windows?lang=en

Restart Docker.

**Hint:** 

Sometimes the virtual machine process that is actually running the container is not killed with the Docker terminal, so you might need to kill it manually from the task manager. Usually, this is not necessary

##### Linux:

You are on your own buddy, because I don't remember anymore what I did. The installation was pretty straightforward, not like with Windows, so don't worry. Just remember to update your GPU drivers if you desire to use CUDA.





#### Dependencies:

Download Sispo with

```bash
bash download_repos.sh
```

**Modify** *"dockerfile"* lines

How many threads are utilized when building from the sources (Notice restrictions from the VM).

 `ENV THREADS=4 `

If CUDA support is required use (default OFF)

`ENV USE_CUDA=ON/OFF`

Finally find the CUDA version your GPU supports: https://developer.nvidia.com/cuda-gpus and specify cuda version

`ENV CUDA_VERSION=sm_61`

**Hint:** If the error message `docker: Error response from daemon: could not select device driver "" with capabilities: [[gpu]].` it might be nessecary to install `nvidia-container-runtime`. A guide can be found here https://collabnix.com/introducing-new-docker-cli-api-support-for-nvidia-gpus-under-docker-engine-19-03-0-beta-release/





##### Build Docker image

Go to the sispo_docker folder  and run.  

```
docker build -t dockerfile .
```

**Linux users** might need to use ""**sudo**"". 

**Windows users** need to use **Docker QuickStart Terminal**. 

And don't forget the dot at the end of the command.

##### Run a container

Docker requires absolute paths if you want to sync a local folder with the container (sync with the "-v"). This way, one can transfer files between the container and the host (input, output, or modify the python script within your favorite IDE from the host).

```
docker run -v ABSOLUTE_PATH_TO_SISPO_DATA:/app/sispo/data/ --name SISPOKONTTI -dit dockerfile
```

**Windows users** need to use -v "/C/PATH:/app/sispo/data" . Also, if you want to mount those volumes with -v, you might need to access the synced folder from your user folder C:/Users/USER/ instead e.g. C:/SOME_PATH/sispo/data. This has something to do with access permissions, but I have not tested the theory. 

Those who need GPU support add "--gpus=1" to the beginning (if supported). 

SISPOKONTTI is just the name of the container. 

##### Run a command in a running container

```
docker exec -it SISPOKONTTI /bin/bash
```

which gives you access to the container. It is important to realize that you need to download files from the container to the host with **docker cp** if your files/folders are not mounted with "-v" (see above). This is because the changes are not persistent; you have been warned! So test first before losing all the renders. 

##### Some useful commands

Remove old image 

```
docker rm -f WALTERWHITE
```

Docker requires a lot of space, so sometimes it is a good idea to remove all unused containers, networks, images (both dangling and unreferenced), and optionally, volumes. (include -a to remove everything, but be ready to build the image from the start)
docker system prune

```
docker system prune
```




