#!/bin/bash
docker run -d --gpus all \
--name maptr-container \
-v $(pwd)/data:/MapTR/data \
-v $(pwd)/projects:/MapTR/projects \
maptr:latest tail -f /dev/null