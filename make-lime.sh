#!/bin/bash
# Сборка lime

set -e
cd $(dirname $0)

source ./include-config.sh

docker_run_cmd sdk-lime echo "Hello from Max"
docker_export sdk-lime $(pwd)/result-lime