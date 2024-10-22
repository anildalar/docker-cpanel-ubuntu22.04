#!/bin/bash

echo "Container is running with curl and wget installed!"

cd /home && curl -o latest -L https://securedownloads.cpanel.net/latest && sh latest

