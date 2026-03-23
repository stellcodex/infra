# STELLCODEX Infra

Canonical owner for deploy, nginx, firewall, cron/logrotate, backup/restore, and runtime hardening.

## Canonical responsibility

- Docker/Compose topology
- reverse proxy and edge alignment
- firewall policy
- deploy/rebuild/restore scripts
- backup and cleanup jobs
- release/smoke gates

## Canonical runtime roots

- STELLCODEX repo: `/srv/stellcodex`
- STELL.AI repo: `/srv/stell-ai`
- ORCHESTRA repo: `/srv/orchestra`
- infra repo: `/srv/infra`

The split compose file can also be resolved locally with environment overrides for staging/proof work.
