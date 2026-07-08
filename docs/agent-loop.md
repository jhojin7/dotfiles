# Agent Loop

## Goal

Let an agent continue cleanup in bounded loops without losing context.

## Before every loop

Read:

```text
SPEC.md
AGENTS.md
state/plan.md
state/state.md
state/decisions.md
```

## Loop process

1. Pick one task from `state/plan.md`.
2. Make smallest viable change.
3. Run checks relevant to changed files.
4. Update `state/state.md`.
5. Update `state/notes.md` only if useful.
6. Stop with exact file list and check results.

## Do not

- ask decisions already resolved
- move many categories at once
- silently delete files
- run commands requiring auth
- mutate outside repo
- touch Docker/Tailscale account state
- claim unrun tests

## Stop conditions

- secret found
- wrong branch
- destructive command needed
- auth/login prompt needed
- diff too broad
