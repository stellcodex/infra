#!/usr/bin/env bash
set -e

ROOT_DIR=$(pwd)
LOCK_FILE="$ROOT_DIR/repos.lock.json"

if [ ! -f "$LOCK_FILE" ]; then
  echo "repos.lock.json not found"
  exit 1
fi

clone_if_missing () {
  NAME=$1
  REPO=$2

  if [ ! -d "$ROOT_DIR/../$NAME" ]; then
    echo "Cloning $NAME..."
    git clone "$REPO" "$ROOT_DIR/../$NAME"
  else
    echo "$NAME already exists"
  fi
}

clone_if_missing "stellcodex" "https://github.com/stellcodex/stellcodex.git"
clone_if_missing "stell-ai" "https://github.com/stellcodex/stell-ai.git"
clone_if_missing "orchestra" "https://github.com/stellcodex/orchestra.git"

echo "Bootstrap complete"
