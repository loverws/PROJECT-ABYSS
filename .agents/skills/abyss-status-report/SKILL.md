---
name: abyss-status-report
description: Report PROJECT ABYSS progress to Slack from canonical task state and evidence without overstating model output or test coverage.
---

# Abyss Status Report

Generate status from the canonical state record, not from a model summary.
Include task ID, transition ID, current state, commit, tests, blocker and next action.
Use PLAN READY for schema-valid planner output and DONE only after required verification and Director review.
Acknowledge approvals with the resulting state and bound action.
Deduplicate by Slack message or event ID and task transition ID.
Never equate Slack delivery with task success.
