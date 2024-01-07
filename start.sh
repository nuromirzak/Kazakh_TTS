#!/bin/bash

# Set default PORT to 8000 if not provided
if [ -z "$PORT" ]; then
    echo "No PORT environment variable set, defaulting to 8000"
    PORT=8000
fi

# Start your application
/app/espnet/tools/miniconda/bin/conda run -n espnet uvicorn main:app --host 0.0.0.0 --port $PORT

