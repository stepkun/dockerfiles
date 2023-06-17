# dockerfiles

## Directory vulcanexus
Docker images with Vulcanexus.<br>
Vulcanexus is an All-in-One ROS2 tool set. See  https://vulcanexus.org

### Targets:
Available targets are:
- run = image to run applications based on Vulcanexus
- dev = basic development image without Vulcanexus desktop tools
- full = development image including all Vulcanexus desktop tools

All targets include the necessary ROS2 packages.<br>

### Build:
To build them all, run script "build" in this directory.<br>
Please change DOCKER_ID in script to your Docker ID<br>
<br>
To build an individual target use
```
docker build \
    --build-arg ROS_DISTRO=<ros-distro> \
    --build-arg UBUNTU_VERSION=<ubuntu-version> \
    --build-arg LANGUAGE=<language-code> \
    --build-arg TIMEZONE=<region/town> \
    --build-arg USERNAME=<username_for_ros-user> \
    --build-arg USER_UID=<ros-user_group-id> \
    --build-arg USER_GID=<ros-user_user-id>"
    --target <target> \
    -t <dockerID>/vulcanexus:humble-<target> -f Dockerfile .
```
There are defaults for the `--build-args` which fit for ROS2 Humble in Europe/Berlin Germany with a ros-user `ros`!

### Push:
To push them all to docker hub, run script "push" in this directory<br>
Please change DOCKER_ID in script to your Docker ID<br>
<br>
To push a single image use
```
docker login<br>
docker push <dockerID>/vulcanexus:humble-<target>
```

### Run:
Ready to use images can be found in dockerID=stepkun<br>
To run a container from one of the images use
```
docker run -it \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --name <name> <dockerID>/vulcanexus:humble-<target>
```
An additional shell can be started with
```
docker exec -it <name> su ros
```
