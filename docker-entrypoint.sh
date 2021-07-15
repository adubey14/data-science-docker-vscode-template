#!/bin/bash
set -e

if [ $# -eq 0 ]
  then
    /opt/conda/bin/jupyter lab --ip=0.0.0.0 --port=2222 --NotebookApp.token='local-development' --allow-root --no-browser &
    code-server-3.11.0-linux-amd64/bin/code-server --auth none   --bind-addr=0.0.0.0:8443
  else
    exec "$@"
fi