#!/bin/sh
echo "Starting gunicorn..."
cd /opt/api
gunicorn -w 5 -b 127.0.0.1:9000 appgate:app --daemon
sleep 3
echo "Starting haproxy..."
haproxy -f "/etc/haproxy/haproxy.cfg" &
while true; do sleep 1; done
