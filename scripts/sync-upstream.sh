#!/usr/bin/env bash
set -euo pipefail

DEFAULT_BRANCH="${1:-main}"
FEATURE_BRANCH="${2:-exodo-brand}"

if ! git remote | grep -q '^upstream$'; then
  echo "Missing upstream remote. Add it with: git remote add upstream https://github.com/open-webui/open-webui.git"
  exit 1
fi

echo "[1/5] Fetching upstream and origin"
git fetch upstream
git fetch origin

echo "[2/5] Updating ${DEFAULT_BRANCH} from upstream/${DEFAULT_BRANCH}"
git checkout "${DEFAULT_BRANCH}"
git merge --ff-only "upstream/${DEFAULT_BRANCH}"
git push origin "${DEFAULT_BRANCH}"

echo "[3/5] Updating ${FEATURE_BRANCH} with ${DEFAULT_BRANCH}"
if git show-ref --verify --quiet "refs/heads/${FEATURE_BRANCH}"; then
  git checkout "${FEATURE_BRANCH}"
  git merge --no-edit "${DEFAULT_BRANCH}"
  git push origin "${FEATURE_BRANCH}"
else
  echo "Feature branch ${FEATURE_BRANCH} not found locally. Skipping feature sync."
fi

echo "[4/5] Returning to ${FEATURE_BRANCH}"
if git show-ref --verify --quiet "refs/heads/${FEATURE_BRANCH}"; then
  git checkout "${FEATURE_BRANCH}"
else
  git checkout "${DEFAULT_BRANCH}"
fi

echo "[5/5] Sync complete"
