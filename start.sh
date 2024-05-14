# Set default PORT to 8000 if not provided
if [ -z "$PORT" ]; then
    echo "No PORT environment variable set, defaulting to 8000"
    PORT=8000
fi

# Start your application
source /app/espnet/tools/miniconda/bin/activate espnet
echo "Activated espnet"
#python -c "import torch; print(torch.cuda.is_available())"
python -c "import torch; print(f'cuda available: {torch.cuda.is_available()}')"

# Start your application
uvicorn main:app --host 0.0.0.0 --port $PORT
