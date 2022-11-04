# dockerfiles

## Directory vulcanexus
Create docker images with vulcanexus/ROS2

### build:
docker rm vlcnxs && docker rmi vlcnxs
docker build -t vlcnxs -f humble.Dockerfile .

### run:
xhost local:root
docker run \
    -it \
    --privileged \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --name vlcnxs vlcnxs

### additional shell:
docker exec -i vlcnxs bash