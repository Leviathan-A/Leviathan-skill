---
name: project-deploy-journal
description: "Maintain a structured deployment and operations journal for engineering projects. Use for change summaries, operation timelines, root cause analysis, validation evidence, rollback state, and current effective configuration."
---

# Project Deploy Journal

## Workflow
1. Identify the target record file.
- Prefer an existing record file in the project (for example `deploy/*operation_record*.md`).
- If none exists, create one in `deploy/` with date suffix.

2. Collect factual inputs before writing.
- Read recent code changes (`git log`, `git diff`, changed files).
- Read operation evidence (commands run, rollout status, pod/workflow states, key logs).
- Distinguish code changes vs runtime-only changes.

3. Update the record in-place (do not rewrite history blindly).
- Append or revise sections with explicit status per step:
  - `planned`
  - `in_progress`
  - `completed`
  - `blocked`
  - `rolled_back`
- Keep concrete identifiers:
  - commit hash
  - file path
  - resource name (pod/deploy/workflow/configmap/secret)
  - timestamp when relevant

4. Write root cause analysis explicitly.
- For each issue, record:
  - symptom
  - direct cause
  - deeper/root cause
  - fix
  - validation result
  - final status (`resolved` or `open`)

5. Keep a current-state snapshot.
- Capture active runtime mode and key toggles (for example inflight mode, semaphore switch, debug flags, notification mode).
- Mark what is production-effective now vs historical temporary workaround.

## Output Structure
Use this structure unless the project already has a stricter format:
- Scope and objective
- Code change log (with reason)
- Operation timeline (with per-step status)
- Root cause section
- Current effective configuration snapshot
- Verification evidence
- Open items and next actions

For a reusable template, read `references/operation_record_template.md`.

## Quality Bar
- Do not use vague statements like "fixed" without evidence.
- Prefer exact names and IDs over narrative wording.
- If an operation was only local and not pushed, state it explicitly.
- If a previous workaround was superseded, keep both entries and mark lifecycle clearly.
