#!/bin/sh
echo "Starting gunicorn..."
gunicorn -w 5 -b 127.0.0.1:9000 appgate:app --daemon
sleep 3
