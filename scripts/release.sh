#!/usr/bin/env bash
# Start a release of a skill that has the update scripts.
#
# Usage: release.sh <skill folder> "<user-facing note>"
#
# Sets VERSION to today's date plus a counter (YYYY.MM.DD.N) and adds the note to
# the top of CHANGES.md. Prints the new version on stdout and the remaining steps
# on stderr: commit both files, tag the commit, and push the commit and the tag.
# Installed copies only see a release once its tag is on GitHub.
set -euo pipefail

SKILL_DIR="${1:?Usage: release.sh <skill folder> \"<user-facing note>\"}"
NOTE="${2:?Usage: release.sh <skill folder> \"<user-facing note>\"}"
CHECK="$SKILL_DIR/scripts/check-update.sh"

TODAY="$(date +%Y.%m.%d)"
PREV="$(tr -d '[:space:]' < "$SKILL_DIR/VERSION" 2>/dev/null || true)"
if [[ "$PREV" == "$TODAY".* ]]; then
  VERSION="$TODAY.$(( ${PREV##*.} + 1 ))"
else
  VERSION="$TODAY.1"
fi
echo "$VERSION" > "$SKILL_DIR/VERSION"

CHANGES="$SKILL_DIR/CHANGES.md"
if [ -f "$CHANGES" ]; then
  { head -n 2 "$CHANGES"; echo "- $VERSION: $NOTE"; tail -n +3 "$CHANGES"; } > "$CHANGES.tmp"
  mv "$CHANGES.tmp" "$CHANGES"
else
  printf '# Changes\n\n- %s: %s\n' "$VERSION" "$NOTE" > "$CHANGES"
fi

TAG="$(sed -n 's/^TAG_PREFIX="\(.*\)"$/\1/p' "$CHECK" 2>/dev/null || true)"
TAG="${TAG:-v}$VERSION"
echo "Release $VERSION. Commit VERSION and CHANGES.md, then: git tag $TAG && git push origin $TAG && git push" >&2
echo "$VERSION"
