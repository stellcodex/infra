#!/usr/bin/env bash
set -e

PROFILE=$1

if [ -z "$PROFILE" ]; then
  echo "Usage: ./deploy.sh [profile]"
  exit 1
fi

ENV_FILE="profiles/$PROFILE.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "Profile not found: $PROFILE"
  exit 1
fi

cp $ENV_FILE .env

echo "Deploying with profile: $PROFILE"

docker compose up -d --build
