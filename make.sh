#!/usr/bin/env bash

set -e

IMAGE=rgbds-0.2.5

main() {
  local container

  container=speedchoice-builder

  echo "building $IMAGE"
  pushd images/rgbds-0.2.5
    docker build -t "$IMAGE" .
  popd

  docker run \
	 --name "$container" \
  	 --volume $(pwd):/pokecrystal \
  	 --workdir /pokecrystal \
  	 "$IMAGE" \
  	 make crystal-speedchoice.gbc

  echo "copying files from container"
  docker cp "$container:/pokecrystal/crystal-speedchoice.gbc" .
  docker cp "$container:/pokecrystal/crystal-speedchoice.sym" .
  echo "cleaning up: rm $container"
  docker rm "$container"
}

main
