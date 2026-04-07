---
name: lcz-coding-style
description: Enforce LCZ coding style for pipeline and service changes. Use when implementing or refactoring business logic in Groovy/Python/CI code where function-first encapsulation is required and business-path code should stay one-line. Also use before commit/push to keep commit scope minimal and exclude deploy/test/docs content by default unless user explicitly asks to include them.
---

# LCZ Coding Style

Apply minimal, production-oriented edits with two hard constraints:
1. Encapsulate logic in helper functions first, then keep business path as one-line call.
2. Exclude deploy/test/docs content from commits by default.

## Workflow

1. Identify the business-path insertion point.
2. Move non-trivial logic into helper function(s).
3. Replace business-path block with a one-line function call.
4. Keep logs minimal: preserve key observability logs, remove noisy debug logs.
5. Stage only functional files; exclude deploy/test/docs unless user explicitly asks.

## Rule 1: Function First, One-Line Business Call

Use this pattern:

```groovy
// business path
handleClangFail(config, env)
```

```groovy
void handleClangFail(Map config, def envVars) {
    // full implementation
}
```

Apply the same principle in Python:

```python
# business path
process_clang_fail(payload)
```

## Rule 2: Default Commit Scope Excludes Deploy/Test/Docs

Before commit, check staged diff and remove non-functional files by default:

```bash
git status --short
git diff --cached --name-only
```

Unstage these paths unless the user explicitly requires them:
- `deploy/`
- `**/deploy/**`
- `test/`, `tests/`
- `docs/`

Useful commands:

```bash
git restore --staged <path>
git rm --cached <path>   # keep local file, remove from tracking
```

## Commit Checklist

- Keep behavior unchanged unless request says otherwise.
- Keep business code concise and readable.
- Keep commit minimal and focused on functional changes.
- Mention explicitly if excluded files are kept local-only.
