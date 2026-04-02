#!/bin/bash

if [ ! -f .env ]; then
  echo ".env not found, copying from .env.example"
  cp .env.example .env
fi

echo "Starting STELLCODEX full system..."

docker compose down

docker compose up -d --build

echo "System started."
