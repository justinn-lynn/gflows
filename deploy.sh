#!/bin/bash

set -e

# LOG_PATH="/var/log/deploy.log"
LOG_PATH="/root/gflows_git/gflows/log/deploy.log"
APP_PORT=80
VENV_PATH="/root/gflows_git/gflows/venv"

# Create the log directory if it doesn't exist
# mkdir -p /var/log
mkdir -p /root/gflows_git/gflows/log

# Ensure the log file exists
touch $LOG_PATH

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

echo "Pulling latest code from Git repository..." >> "$LOG_PATH"
git pull origin main

echo "Installing dependencies..." >> "$LOG_PATH"
pip install -r requirements.txt

echo "Killing existing application process..." >> "$LOG_PATH"
fuser -k ${APP_PORT}/tcp || true

echo "Starting application..." >> "$LOG_PATH"
python3.9 app.py

echo "Deployment completed at $(date)" >> "$LOG_PATH"
