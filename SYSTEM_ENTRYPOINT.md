# STELLCODEX — System Entrypoint

This document defines the single canonical entry flow for the infrastructure repository.

## Start Here

1. Run bootstrap
   - Linux/macOS: `./bootstrap.sh`
   - Windows: `./bootstrap.ps1`

2. Choose deployment profile
   - `single-node`
   - `three-node`
   - `multi-node`

3. Deploy
   - Linux/macOS: `./deploy.sh <profile>`

## Canonical Files

- `repos.lock.json` → repository manifest
- `docker-compose.yml` → orchestration
- `bootstrap.sh` / `bootstrap.ps1` → workspace closure
- `deploy.sh` → topology selection
- `system.release.json` → release manifest
- `RELEASE.md` → release statement

## Rule

This repository is the infrastructure authority and canonical GitHub entrypoint for STELLCODEX runtime reconstruction.
