---
name: clang-debug-step
description: Run the standard clang debug workflow that enters the project Docker environment and executes default clang check commands. Use when users ask to start or repeat clang debug checks, run `./docker_into.sh ubuntu-20.04-x86`, or execute `CLANG_WEEKLY_CHECK -r $CODE_alg_map_engine_server`.
---

# Clang Debug Step

## Goal
Run a repeatable clang debug flow inside the expected Docker environment.

## Workflow
1. Verify the current directory contains `docker_into.sh`.
2. Start the docker shell:
```bash
./docker_into.sh ubuntu-20.04-x86
```
3. In the container shell, run the default check:
```bash
CLANG_WEEKLY_CHECK -r $CODE_alg_map_engine_server
```
4. If the user provides another target, replace the `-r` argument with that target path.
5. Capture command output and report the first actionable failures.

## Variants
Use this form for a custom target:
```bash
CLANG_WEEKLY_CHECK -r <repo_or_module_path>
```

## Failure Handling
- If `docker_into.sh` is missing, run `find . -name docker_into.sh` and switch to the correct repo root.
- If `CLANG_WEEKLY_CHECK` is not found, run `type CLANG_WEEKLY_CHECK` and `echo $PATH`, then report missing environment setup.
- If `$CODE_alg_map_engine_server` is empty, run `echo $CODE_alg_map_engine_server` and request an explicit path for `-r`.

## Output Contract
Report these fields:
- Docker image used.
- Exact check command used.
- Whether the check completed successfully.
- Key error lines and the next recommended fix step.
