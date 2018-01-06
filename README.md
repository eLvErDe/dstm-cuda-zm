# nvidia-docker image for DSTM's CUDA Zcash/Zclassic (Equihash) miner (zm)

This image build [DSTM's CUDA Zcash miner] from DSTM's Google Drive.
It requires a CUDA compatible docker implementation so you should probably go
for [nvidia-docker].
It has also been tested successfully on [Mesos] 1.2.1.

## Build images

```
git clone https://github.com/eLvErDe/docker-dstm-cuda-zm
cd docker-dstm-cuda-zm
docker build -t dstm-cuda-zm .
```

## Publish it somewhere

```
docker tag dstm-cuda-zm docker.domain.com/mining/dstm-cuda-zm
docker push docker.domain.com/mining/dstm-cuda-zm
```

## Test it (using dockerhub published image)

```
nvidia-docker pull acecile/dstm-cuda-zm:latest
nvidia-docker run -it --rm acecile/dstm-cuda-zm /root/dstm-zm --help
```

An example command line to mine using miningpoolhub.com on Zclassic (on my account, you can use it to actually mine something for real if you haven't choose your pool yet):
```
nvidia-docker run -it --rm --name dstm-cuda-zm acecile/dstm-cuda-zm /root/dstm-zm --server europe.equihash-hub.miningpoolhub.com --port 20575 --user acecile.catchall --pass x --telemetry=0.0.0.0:4068
```

Ouput will looks like:
```
#  zm 0.5.8
#  GPU0 + GeForce GTX 1070         MB: 8111  PCI: 1:0

#  telemetry server started
#  connected to: europe.equihash-hub.miningpoolhub.com:20575
#  server set difficulty to: 000100000000000000000000...
>  GPU0  61C  Sol/s: 450.6  Sol/W: 2.67  Avg: 450.6  I/s: 241.6  Sh: 0.00   . .   
>  GPU0  65C  Sol/s: 456.2  Sol/W: 2.70  Avg: 453.4  I/s: 239.7  Sh: 0.00   . .   
   GPU0  68C  Sol/s: 432.7  Sol/W: 2.64  Avg: 446.5  I/s: 239.6  Sh: 0.00   . .   
   GPU0  70C  Sol/s: 447.6  Sol/W: 2.63  Avg: 446.8  I/s: 239.2  Sh: 0.00   . .   
#  server set difficulty to: 00016db6db6db6db70000000...
>  GPU0  72C  Sol/s: 451.4  Sol/W: 2.62  Avg: 447.7  I/s: 239.0  Sh: 0.00   . . 
```

## Background job running forever

```
nvidia-docker run -dt --restart=unless-stopped -p 4068:4068 --name dstm-cuda-zm acecile/dstm-cuda-zm /root/dstm-zm --server europe.equihash-hub.miningpoolhub.com --port 20575 --user acecile.catchall --pass x --telemetry=0.0.0.0:4068
```

You can check the output using `docker logs dstm-cuda-zm -f`


## Use it with Mesos/Marathon

Edit `mesos_marathon.json` to replace Zcash/Zclassic mining pool parameter, change application path as well as docker image address (if you dont want to use public docker image provided).
Then simply run (adapt application name here too):

```
curl -X PUT -u marathon\_username:marathon\_password --header 'Content-Type: application/json' "http://marathon.domain.com:8080/v2/apps/mining/dstm-cuda-zm?force=true" -d@./mesos\_marathon.json
```

You can check CUDA usage on the mesos slave (executor host) by running `nvidia-smi` there:

```
Sat Jan  6 19:02:57 2018       
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 384.90                 Driver Version: 384.90                    |
|-------------------------------+----------------------+----------------------+
| GPU  Name        Persistence-M| Bus-Id        Disp.A | Volatile Uncorr. ECC |
| Fan  Temp  Perf  Pwr:Usage/Cap|         Memory-Usage | GPU-Util  Compute M. |
|===============================+======================+======================|
|   0  GeForce GTX 1070    Off  | 00000000:01:00.0  On |                  N/A |
| 71%   73C    P2   175W / 200W |   509MiB /  8111MiB  |    100%      Default |
+-------------------------------+----------------------+----------------------+
                                                                               
+-----------------------------------------------------------------------------+
| Processes:                                                       GPU Memory |
|  GPU       PID   Type   Process name                             Usage      |
|=============================================================================|
|    0     18508      C   /root/dstm-zm                                509MiB |
+-----------------------------------------------------------------------------+
```

[DSTM's CUDA Zcash miner]: https://bitcointalk.org/index.php?topic=2021765.0
[nvidia-docker]: https://github.com/NVIDIA/nvidia-docker
[Mesos]: http://mesos.apache.org/documentation/latest/gpu-support/
