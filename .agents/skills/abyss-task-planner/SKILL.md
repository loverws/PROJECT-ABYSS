---
name: abyss-task-planner
description: Convert an approved PROJECT ABYSS objective into a schema-valid bounded task packet without implementing or claiming test results.
---

# Abyss Task Planner

Produce a plan tied to one task ID and action type.
Use only existing read paths and keep proposed writes within the task allowlist.
Separate assumptions, proposed changes, test commands, security checks and unresolved questions.
Do not claim files changed, commands ran, tests passed or commits exist.
Reject a task that lacks acceptance criteria, evidence requirements or rollback.
A planner result is PLANNED or PROPOSED, never DONE.
