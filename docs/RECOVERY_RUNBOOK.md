# RECOVERY RUNBOOK

## Purpose

This document defines the canonical recovery sequence for STELLCODEX when a server is lost, replaced, or rebuilt.

The architecture rule is strict:

- **GitHub** = canonical source of code, infrastructure, contracts, scripts, and system definition
- **Google Drive** = canonical source of backups, memory, evidence, archives, and operational artifacts
- **Server** = disposable runtime only

A server must always be recoverable from GitHub first, then reattached to Drive-managed state.

## Recovery Principle

Recovery must happen in two phases:

1. **Rebuild the runtime from GitHub**
2. **Reattach Drive-managed state and artifacts**

Never treat the dead server as the primary source of truth.

## Phase 1 — Rebuild from GitHub

### Required repositories

- `stellcodex/stellcodex`
- `stellcodex/stell-ai`
- `stellcodex/orchestra`
- `stellcodex/infra`

### Recovery goals for Phase 1

- restore deployment topology
- restore compose/runtime definitions
- restore nginx / routing / edge alignment
- restore container build context
- restore scripts and operational contracts
- restore deterministic service startup

### Expected outcome of Phase 1

At the end of Phase 1:

- repos are present on the server
- env contracts are known
- infra runtime can be started
- STELLCODEX services are reachable
- system can pass basic health/smoke checks

Drive content is not required to complete the code/runtime rebuild.

## Phase 2 — Reattach Drive State

After the runtime is rebuilt from GitHub, reattach Drive-managed state.

### Drive-managed categories

- backups
- memory
- evidence
- reports
- archives
- release bundles
- operational artifacts

### Expected outcome of Phase 2

At the end of Phase 2:

- backup lineage is available
- memory/evidence are reattached
- archived proof and reports are reachable
- runtime is reconnected to long-lived state

## Strict Rules

- Never store permanent business truth on the server.
- Never treat the server filesystem as canonical history.
- Never rebuild the platform by relying on server residue first.
- Always rebuild the runtime from GitHub before restoring Drive-managed state.
- Always keep secrets outside Git-tracked roots.

## Minimum Recovery Order

1. Clone or pull canonical repositories from GitHub
2. Materialize runtime environment files from approved secret storage
3. Start infra/runtime topology
4. Verify service health
5. Reattach Drive-managed state
6. Run smoke/restore validation
7. Resume normal operations

## Validation Checks

Recovery is not complete until the following are true:

- deployment topology is up
- public and internal health surfaces respond
- STELLCODEX, STELL.AI, and ORCHESTRA boundaries are intact
- Drive-managed backups and memory are reachable again
- smoke validation passes

## Canonical Summary

If the server dies:

- GitHub rebuilds the system
- Drive restores the memory
- the server is replaced, not trusted
