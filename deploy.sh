#!/bin/bash

set -e

# LOG_PATH="/var/log/deploy.log"
LOG_PATH="/root/gflows_git/gflows/log/deploy.log"
APP_PORT=80
# APP_PORT=8050
APP_LOG_PATH="/root/gflows_git/gflows/log/app.log"
VENV_PATH="/root/gflows_git/gflows/venv"
DATA_DIR="/root/gflows_git/gflows/data"

# Create the log directory if it doesn't exist
# mkdir -p /var/log
mkdir -p /root/gflows_git/gflows/log

# Ensure the log file exists
touch $LOG_PATH
touch $APP_LOG_PATH

echo "Deployment started at $(date)" >> "$LOG_PATH"

cd /root/gflows_git/gflows

echo "Activating virtual environment..." >> "$LOG_PATH"
if [ -d "$VENV_PATH" ]; then
    source "$VENV_PATH/bin/activate"
    echo "Virtual environment activated." >> "$LOG_PATH"
else
    echo "Error: Virtual environment not found at $VENV_PATH" >> "$LOG_PATH"
    exit 1
fi

# Check for changes in the data directory
if [ -n "$(git status --porcelain $DATA_DIR)" ]; then
    echo "Committing changes in the data directory..." >> "$LOG_PATH"
    git add $DATA_DIR
    git commit -m "Update data directory before deployment"
    git push origin main
fi

echo "Pulling latest code from Git repository..." >> "$LOG_PATH"
git pull origin main

echo "Installing dependencies..." >> "$LOG_PATH"
pip install -r requirements.txt

echo "Killing existing application process..." >> "$LOG_PATH"
fuser -k ${APP_PORT}/tcp || true

echo "Starting application..." >> "$LOG_PATH"
# python3.9 app.py
nohup python3.9 app.py >> "$LOG_PATH" 2>&1 &

echo "Deployment completed at $(date)" >> "$LOG_PATH"
