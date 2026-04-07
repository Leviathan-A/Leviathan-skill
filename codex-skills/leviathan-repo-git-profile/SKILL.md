---
name: leviathan-repo-git-profile
description: Apply and persist the Leviathan-A Git identity for a repository before commit/push. Use when the user asks to upload, push, or submit code to a Leviathan repository, or uses phrases like "上传至Leviathan仓库", "推送到Leviathan仓库", or "use Leviathan account". This skill enforces local repo identity as user.name=Leviathan-A and user.email=1151858182@qq.com, and can optionally write .envrc for automatic re-application on directory entry.
---

# Leviathan Repo Git Profile

## Overview

Enforce a repository-local Git identity for Leviathan pushes.
Run a deterministic script so commit authorship does not depend on global Git config.

## Workflow

1. Enter the target repository.
2. Run `scripts/apply_leviathan_git_profile.sh`.
3. Verify identity with:
   - `git config --show-origin user.name`
   - `git config --show-origin user.email`
4. Continue commit and push flow.

## Persist With direnv (Optional)

1. Run `scripts/apply_leviathan_git_profile.sh --write-envrc` to write a hardcoded `.envrc`.
2. Run `direnv allow` in that repository.
3. Re-enter the directory or run `direnv reload`.

## Constraints

1. Set repository-local config only (`git config --local`), never modify `--global`.
2. Keep values hardcoded:
   - `user.name`: `Leviathan-A`
   - `user.email`: `1151858182@qq.com`
3. Remove local `include.path` to avoid inherited profile conflicts.

## Script

Use [`scripts/apply_leviathan_git_profile.sh`](scripts/apply_leviathan_git_profile.sh) for all profile updates.
