# dockerfiles

## Directory vulcanexus
Create docker images with vulcanexus/ROS2

### Build:

#### Targets:
run = image to run things
dev = basic development image without desktop tools
full = development image including all desktop tools

docker rm vulcanexus-humble-<target> && docker rmi stepkun/vulcanexus:humble-<target>
docker build --target <target> -t stepkun/vulcanexus:humble--<target> -f humble.Dockerfile .

### Run:
docker run \
    -it \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    --name vulcanexus-humble-<target> stepkun/vulcanexus:humble-<target>

### additional shell:
docker exec -i vulcanexus-humble-<target> bash