#! /bin/bash -l

docker compose up -d
docker exec -ti openwind-build /usr/src/openwind/build-cli.sh "$@"
#docker exec -ti openwind-build /bin/bash
docker compose down

