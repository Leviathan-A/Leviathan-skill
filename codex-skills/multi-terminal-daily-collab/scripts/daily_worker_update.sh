#!/usr/bin/env bash
set -euo pipefail

date_value="$(date +%F)"
agent=""
section="工作内容"
message=""
repo=""
auto_push=0
skip_pull=0
skip_inbox_check=0
inbox_dir=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --date)
      date_value="$2"
      shift 2
      ;;
    --agent)
      agent="$2"
      shift 2
      ;;
    --section)
      section="$2"
      shift 2
      ;;
    --message)
      message="$2"
      shift 2
      ;;
    --repo)
      repo="$2"
      shift 2
      ;;
    --push)
      auto_push=1
      shift
      ;;
    --skip-pull)
      skip_pull=1
      shift
      ;;
    --skip-inbox-check)
      skip_inbox_check=1
      shift
      ;;
    --inbox-dir)
      inbox_dir="$2"
      shift 2
      ;;
    *)
      echo "unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

if [[ -z "$agent" || -z "$message" ]]; then
  echo "usage: $0 --agent <name> --message <text> [--date YYYY-MM-DD] [--section <name>] [--repo <path>] [--push] [--skip-pull] [--skip-inbox-check] [--inbox-dir <path>]" >&2
  exit 1
fi

if [[ -z "$repo" ]]; then
  repo="$(git rev-parse --show-toplevel 2>/dev/null || true)"
fi

if [[ -z "$repo" || ! -d "$repo/.git" ]]; then
  echo "error: repo not found, pass --repo <git-root>" >&2
  exit 1
fi

if [[ -z "$inbox_dir" ]]; then
  inbox_dir="$repo/vault/00-Inbox"
fi

daily_file="$repo/vault/01-Daily/$date_value.md"
pull_script="$repo/vault/scripts/pull.sh"
push_script="$repo/vault/scripts/push.sh"
new_daily_py="$repo/vault/scripts/new_daily.py"

if [[ "$skip_pull" -eq 0 && -x "$pull_script" ]]; then
  if ! bash "$pull_script"; then
    echo "error: pull failed. commit/stash local changes first, or rerun with --skip-pull." >&2
    exit 1
  fi
fi

if [[ ! -f "$daily_file" ]]; then
  if [[ -f "$new_daily_py" ]]; then
    python3 "$new_daily_py" --date "$date_value" --vault "$repo/vault" || true
  fi
fi

if [[ ! -f "$daily_file" ]]; then
  mkdir -p "$(dirname "$daily_file")"
  cat > "$daily_file" <<EOF
# $date_value Daily Note

## 多端协作记录
EOF
fi

if ! grep -qx "## 多端协作记录" "$daily_file"; then
  printf "\n## 多端协作记录\n" >> "$daily_file"
fi

ts="$(date +%H:%M:%S)"
printf -- "- [%s][%s][%s] %s\n" "$ts" "$agent" "$section" "$message" >> "$daily_file"

echo "updated: $daily_file"

if [[ "$skip_inbox_check" -eq 0 ]]; then
  if [[ -d "$inbox_dir" ]]; then
    mapfile -t inbox_files < <(find "$inbox_dir" -maxdepth 1 -type f -name '*.md' ! -name 'README.md' ! -name '*.bak' | sort)
    if [[ "${#inbox_files[@]}" -gt 0 ]]; then
      echo "inbox pending (${#inbox_files[@]}):"
      for item in "${inbox_files[@]}"; do
        rel="$item"
        rel="${rel#"$repo/vault/"}"
        echo "- [[${rel%.md}]]"
      done
      echo "hint: include inbox consolidation in coordinator handoff."
    else
      echo "inbox pending: none"
    fi
  else
    echo "inbox check skipped: directory not found ($inbox_dir)"
  fi
fi

if [[ "$auto_push" -eq 1 && -x "$push_script" ]]; then
  bash "$push_script" "daily: $date_value $agent"
fi
