---
name: multi-terminal-daily-collab
description: Coordinate multiple terminal agents that update the same daily note in a Git-backed Obsidian vault. Use when the user asks for multi-terminal collaboration, parallel daily-note updates, staged handoff to a coordinator agent, or final consolidation and push. Trigger on phrases such as "多个terminal协作", "让其他agent更新daily", "先分散更新再统一整理", and "整理后上传".
---

# Multi Terminal Daily Collab

## Overview

Run a low-conflict workflow for parallel daily-note edits.
Standardize worker updates first, then consolidate in a coordinator pass before push.

## Roles

1. Worker agent: append structured progress lines to the daily note.
2. Coordinator agent: deduplicate, normalize sections, add links/tags, then commit/push.

## Worker Flow

1. Enter repository root.
2. Pull first: `bash vault/scripts/pull.sh`.
3. Append one entry with:
   - `scripts/daily_worker_update.sh --date YYYY-MM-DD --agent <agent> --section <section> --message "<content>"`
   - If current worktree is dirty and cannot pull safely: add `--skip-pull`.
4. Push immediately only if this worker owns publishing. Otherwise stop after local update.
5. Check `vault/00-Inbox` for user-written notes and include them in handoff context.

## Coordinator Flow

1. Pull latest updates.
2. Scan `vault/00-Inbox` and decide for each note: project/knowledge/resource or keep in inbox.
3. Consolidate `## 多端协作记录` into canonical sections:
   - `## 工作内容`
   - `## 问题/阻塞`
   - `## 思考/洞察`
   - `## 明日计划`
4. Add or fix project/knowledge wikilinks, including links generated from inbox consolidation.
5. Run `python3 vault/scripts/sync_status.py`.
6. Commit and push when user confirms publishing.

## Conflict Policy

1. Always `pull --rebase` before editing.
2. Append-only for worker updates; avoid rewriting the whole daily note.
3. If conflicts happen, resolve once in coordinator pass and push once.

## Handoff Prompt Template

Use this exact handoff request to the coordinator agent:

```text
请接手整理日报并准备上传：
日期=YYYY-MM-DD
来源agent=agent-a,agent-b,agent-c
要求=去重、归并到标准章节、补双链、给出提交信息建议
是否整理Inbox=是
是否直接push=是/否
```

## Script

Use `scripts/daily_worker_update.sh` to append standardized worker entries safely.
