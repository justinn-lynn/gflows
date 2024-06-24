#!/bin/bash

set -e

LOG_PATH="/var/log/deploy.log"
APP_PORT=80

# Create the log directory if it doesn't exist
mkdir -p /var/log

# Ensure the log file exists
touch $LOG_PATH

echo "Deployment started at $(date)" >> "$LOG_PATH"

cd /root/gflows_git/gflows

echo "Activating virtual environment..." >> "$LOG_PATH"
source venv/bin/activate

echo "Pulling latest code from Git repository..." >> "$LOG_PATH"
git pull origin main

echo "Installing dependencies..." >> "$LOG_PATH"
pip install -r requirements.txt

echo "Killing existing application process..." >> "$LOG_PATH"
fuser -k ${APP_PORT}/tcp || true

echo "Starting application..." >> "$LOG_PATH"
nohup python3 app.py >> "$LOG_PATH" 2>&1 &

echo "Deployment completed at $(date)" >> "$LOG_PATH"
