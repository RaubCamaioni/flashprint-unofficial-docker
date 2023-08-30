## Unofficial Dockerfile for FlashPrint5+
Improved software compatability (docker runner).  
Issolated installation, easy uninstall with "docker image rm FlashPrint5"  
Security concerns running closed binary software on home systems.  

- Improved security  
    - File system issolation  
    - Network issolation  
    - Permissions restriction  
- Improved software compatability
    - As off 8/30/2023 FlashPrint installer not working on Windows11
    - Installation dependencies and install automated

Pre-built avaiable at: https://hub.docker.com/r/raubcamaioni/flashprint-unofficial

## Quick Start
pull latest docker  
```
docker pull raubcamaioni/flashprint-unofficial
```
run docker
```
docker run -it --rm \
    -e DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $(pwd):/models:rw \
    raubcamaioni/flashprint-unofficial
```

## Choosing FlashPrint Version
Copy a Linux install url from https://www.flashforge.com/download-center/63  
and pass to docker build as build argument.

Defaults to FlashPoint 5.7.1 if build-arg not given.  
```
docker build --build-arg FLASHPRINT_URL="https://en.fss.flashforge.com/10000/software/d9f30e5fad8a33e09039a2ceb0a96dc0.zip" -t flashprint .
```

## Mount/Config/GUI
You will need to mount a local folder/file with 3D files for printing.  
You will also need to mount X11 forwarding for the FlashPrint GUI.  

For versions newer than 5.X.X (6.x.x not released at current time 8/30/2023)  
You might need to change the mounting locations to .FlashPrint<major_version_number>.  
No guarantees this docker build will continue to work after version 5. (It should)  

Configuration are saved at: /home/flashprint/.FlashPrint5  
Note: The version could change the configuration file location.  

The below command will mount to the home directory.  
Mount persistent configuration directory at ~/.FlashPrint (Optional).  

Ensure the mounted directories have permission to read and write.  
Otherwise, configs will not be saved.  

A ~/models directory is also mounted.  

```
docker run -it --rm \
    -e DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $HOME/models:/models:rw \
    -v $HOME/.FlashPrint5:/home/flashprint/.FlashPrint5:rw \
    flashprint
```

Alternative command to mount current working directory to /models  
```
docker run -it --rm \
    -e DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $(pwd):/models:rw \
    flashprint
```

## WIFI Hotspot (Recommended)  
Keep 3D printer isolated from home network by using Hotspot provided by machine.    


## Increased Network Security (Optional: Linux only)
Limit the network access of the docker container.  
Only allow access to 3D printer.  
Improves security running docker on machine with multiple interfaces.  

Create seperate bridge network  
```
docker network create flashprint-jail
docker network ls | grep flashprint-jail
ac3d95d059c2   flashprint-jail   bridge    local
```

Add iptables rules to network.  
10.10.100.254 is default hotspot ip for Adventure 3.  
```
iptables -I DOCKER-USER -i br-ac3d95d059c2 -j DROP
iptables -I DOCKER-USER -i br-ac3d95d059c2 -d 10.10.100.254 -j ACCEPT
```

Launch with the following command.  
```
docker run -it --rm \
    --network=flashprint-jail \
    -e DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v $HOME/models:/models:rw \
    -v $HOME/.FlashPrint5:/home/flashprint/.FlashPrint5:rw \
    flashprint
```

You can leave the network bridge configuration indefinitely.  
Docker system prune will clean it up automatically.  
To manually remove  
```
docker network rm flashprint-jail
```
