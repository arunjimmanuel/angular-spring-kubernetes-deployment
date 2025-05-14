#!/bin/bash

set -e  # Exit immediately on error

echo ">>> Creating 2G swap file..."
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile