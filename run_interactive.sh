#!/bin/bash

# Prompt for external SSD mount path
read -p "Enter your external SSD mount path (e.g., /media/koki/MySSD): " EXTERNAL_SSD

# Check if the path exists
if [ ! -d "$EXTERNAL_SSD" ]; then
    echo "Error: Directory $EXTERNAL_SSD does not exist!"
    return 1 2>/dev/null || exit 1
fi

# Check if data folder exists
if [ ! -d "$EXTERNAL_SSD/data" ]; then
    echo "Error: Data folder not found in $EXTERNAL_SSD. Please ensure the 'data' folder exists."
    return 1 2>/dev/null || exit 1
fi

echo "Using SSD path: $EXTERNAL_SSD/data"

# Run docker and check if it succeeded
if docker run -d --gpus all \
  --name maptr-container \
  -v "${EXTERNAL_SSD}/data:/MapTR/data" \
  -v "$(pwd)/projects:/MapTR/projects" \
  maptr:latest tail -f /dev/null; then
    echo "Container started! Use 'docker exec -it maptr-container /bin/bash' to enter."
else
    echo "Error: Failed to start container!"
    return 1 2>/dev/null || exit 1
fi