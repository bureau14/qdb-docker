CURRENT_TIME=$(date +"%Y%m%dT%H%M%S")
echo $CURRENT_TIME

ARCH=$1

if [[ -z $ARCH ]]; then
    echo "Should provide architecture (amd64 or aarch64)"
    exit 1
fi

docker build --squash --tag build-$ARCH-builder:$CURRENT_TIME -f $ARCH/Dockerfile .
docker tag build-$ARCH-builder:$CURRENT_TIME docker.io/bureau14/$ARCH-builder:latest
docker tag build-$ARCH-builder:$CURRENT_TIME docker.io/bureau14/$ARCH-builder:$CURRENT_TIME
docker push docker.io/bureau14/$ARCH-builder:$CURRENT_TIME
