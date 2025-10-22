#!/bin/bash

# Run Django development server in background and log output
python manage.py runserver 0.0.0.0:8000 > aws-demo.log 2>&1 &

# Save the background process PID to a file
echo $! > aws-demo.pid

echo "Server started in background with PID $(cat aws-demo.pid)"
