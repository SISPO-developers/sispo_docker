# sispo_docker 

Some useful commands, explanation comes later

UCAC4 files need to be downloaded separately. 


'''

docker build -t dockerfile .

sudo docker run --name WALTERWHITE -dit dockerfile

sudo docker exec -it WALTERWHITE /bin/bash

sudo docker rm -f WALTERWHITE

sudo docker run -v /home/rokka/WRKDIR/sispo/data/UCAC4:/app/sispo/data/UCAC4 --name WALTERWHITE -dit dockerfile

LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2 python


sudo docker run -v /home/rokka/WRKDIR/sispo_docker/sispo/data/:/app/sispo/data/ -v /home/rokka/WRKDIR/sispo_docker/sispo/sispo/:/app/sispo/sispo/ --name WALTERWHITE -dit dockerfile

'''
