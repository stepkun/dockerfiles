# dockerfiles

## Directory vulcanexus
Create a dockerfile with vulcanexus humble

### build:
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