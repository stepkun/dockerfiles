# dockerfiles

## Directory vulcanexus
Docker images with Vulcanexus.<br>
Vulcanexus is an All-in-One ROS2 tool set. See  https://vulcanexus.org

### Targets:
Available targets are:
- run = image to run applications based on Vulcanexus
- dev = basic development image without Vulcanexus desktop and simulation tools
- sim = development image including all Vulcanexus simulation tools
- full = development image including all Vulcanexus desktop and simulation tools

All targets include the necessary ROS2 packages.<br>

### Build & Push:
To build them all, run script "build" in this directory.<br>
To build and push them all, run script "deploy" in this directory.<br>
Please change DOCKER_ID in script to your Docker ID<br>
<br>
For a local build without pushing there is the script "local".<br>
Please change DOCKER_ID in script to your Docker ID<br>
**Do not** push local build images, as these will overwrite and destroy the multiplatform images built by "deploy".<br>
<br>
To build an individual target locally use
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

### Run:
Ready to use images can be found in dockerID=stepkun<br>
To run a container from one of the images use on Linux:
```
docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix --name <name> stepkun/vulcanexus:<ros-distro>-<target>
```
On Windows:
```
docker run -it -e DISPLAY=$DISPLAY -v \\\\wsl.localhost\\Ubuntu\\mnt\\wslg:/tmp --name <name> stepkun/vulcanexus:<ros-distro>-<target>
```
An additional shell can be started with
```
docker exec -it <name> bash
```
