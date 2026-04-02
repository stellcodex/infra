#!/bin/bash

echo "Starting STELLCODEX full system..."

docker compose down

docker compose up -d --build

echo "System started."
