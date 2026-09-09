---
name: abyss-git-checkpoint
description: Create reviewable PROJECT ABYSS branch checkpoints while preserving unrelated changes, secrets and canonical history.
---

# Abyss Git Checkpoint

Verify the repository, branch, upstream and worktree before editing.
Use an isolated task branch and stage only task-related files.
Exclude secrets, runtime state, logs and generated place artifacts.
Run diff checks and required tests before committing.
Record input and output commit SHA and push success separately.
Do not force push, rewrite history, clean broadly or merge without the applicable authorization.
