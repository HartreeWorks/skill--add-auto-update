#!/usr/bin/env bash
# Add the update scripts to a skill.
#
# Usage: install.sh <skill folder> --repo OWNER/REPO [--path DIR] [--name NAME] [--data-root NAME]
#   --path       the skill's folder inside the repository; omit for a skill at the root
#   --name       the skill's name (default: the folder name)
#   --data-root  the folder under ~/.config that holds each skill's user data
#                (default: <owner in lower case>-skills)
#
# Writes check-update.sh, migrate.sh and data-dir.sh into the skill's scripts/.
# Releases are tagged v<VERSION> for a skill at the repository root and
# <name>-v<VERSION> for one in a subfolder, so skills sharing a repository
# release independently.
set -euo pipefail

usage() { sed -n '2,14p' "${BASH_SOURCE[0]}" >&2; exit 2; }

[ $# -ge 1 ] || usage
SKILL_DIR="$1"
shift
REPO="" REPO_PATH="" NAME="" DATA_ROOT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO="${2:?}"; shift 2 ;;
    --path) REPO_PATH="${2%/}"; shift 2 ;;
    --name) NAME="${2:?}"; shift 2 ;;
    --data-root) DATA_ROOT="${2:?}"; shift 2 ;;
    *) usage ;;
  esac
done
[[ "$REPO" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || { echo "--repo must be OWNER/REPO" >&2; exit 2; }
[ -f "$SKILL_DIR/SKILL.md" ] || { echo "No SKILL.md in $SKILL_DIR" >&2; exit 1; }
NAME="${NAME:-$(basename "$(cd "$SKILL_DIR" && pwd)")}"
DATA_ROOT="${DATA_ROOT:-$(echo "${REPO%%/*}" | tr '[:upper:]' '[:lower:]')-skills}"
if [ -n "$REPO_PATH" ]; then TAG_PREFIX="$NAME-v"; else TAG_PREFIX="v"; fi

TEMPLATES="$(cd "$(dirname "${BASH_SOURCE[0]}")/../templates" && pwd)"
mkdir -p "$SKILL_DIR/scripts"
for TEMPLATE in "$TEMPLATES"/*.sh; do
  OUT="$SKILL_DIR/scripts/$(basename "$TEMPLATE")"
  sed -e "s|__SKILL_NAME__|$NAME|g" -e "s|__REPO__|$REPO|g" -e "s|__REPO_PATH__|$REPO_PATH|g" \
      -e "s|__TAG_PREFIX__|$TAG_PREFIX|g" -e "s|__DATA_ROOT__|$DATA_ROOT|g" "$TEMPLATE" > "$OUT"
  chmod +x "$OUT"
done
echo "Added update scripts to $SKILL_DIR/scripts (repo $REPO${REPO_PATH:+, path $REPO_PATH}, tags ${TAG_PREFIX}<VERSION>, data in ~/.config/$DATA_ROOT/$NAME)."
