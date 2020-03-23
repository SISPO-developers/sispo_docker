## sispo_docker 



##### Dependencies:

Download all the necessary repositories:

```bash
bash prepare_repos.sh
```



##### Install Docker (toolbox or for windows):





##### Build Docker image






Some useful commands, explanation comes later

UCAC4 files need to be downloaded separately. 


Build image

'''

docker build -t dockerfile .

'''





Docker requires absolute paths if you want to sync local folder with the container

'''
sudo docker run -v /home/rokka/WRKDIR/sispo_docker/sispo/data/:/app/sispo/data/ -v /home/rokka/WRKDIR/sispo_docker/sispo/sispo/:/app/sispo/sispo/ --name WALTERWHITE -dit dockerfile
'''


With gpu
'''
sudo docker run --gpus=1 -v /home/rokka/WRKDIR/sispo_docker/sispo/data/:/app/sispo/data/ -v /home/rokka/WRKDIR/sispo_docker/sispo/sispo/:/app/sispo/sispo/ --name WALTERWHITE -dit dockerfile
'''



Run 

'''
sudo docker exec -it WALTERWHITE /bin/bash
'''







Remove
'''
sudo docker rm -f WALTERWHITE
'''




NOTIFICATION:

Python will be preloaded with jemalloc (Does not require any actions. Automatically done)

'''
LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2 python
'''




