#!/bin/bash
# ----------------------------------------------------------------------
# Author: Sagar Malla
# Email : sagarmalla08
# Date  : 22-10-2025
# Description:
#   Script to run Django development server in the background,
#   log output to aws-demo.log, and manage PID file.
# ----------------------------------------------------------------------

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Kill the existing process if PID file exists
if [ -f aws-demo.pid ]; then
    OLD_PID=$(cat aws-demo.pid)
    kill -9 "$OLD_PID" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo -e "${YELLOW}Killed previous process with PID ${OLD_PID}${NC}"
    else
        echo -e "${RED}No running process found for PID ${OLD_PID}${NC}"
    fi
    rm -f aws-demo.pid
fi

# Run Django development server in background and log output
python manage.py runserver 0.0.0.0:8000 > aws-demo.log 2>&1 &

# Save the background process PID to a file
echo $! > aws-demo.pid

echo -e "\n\n${GREEN}Server started in background with PID $(cat aws-demo.pid)${NC}"
echo -e "${GREEN}Logging output to aws-demo.log${NC}"