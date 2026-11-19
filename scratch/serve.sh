#!/bin/sh
echo ok > /www/healthz
grep -q '"ready": false' /www/version || echo ok > /www/ready
exec httpd -f -p 8080 -h /www
