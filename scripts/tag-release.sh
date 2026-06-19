#!/bin/bash
set -e
cd "$(dirname "$0")/.."

VERSION="${1:-}"

if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <version>  (e.g. 3.2.0)"
  exit 1
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" != "main" ]]; then
  echo "Error: must be on main (currently on '$CURRENT_BRANCH')"
  echo "Run: git checkout main && git pull"
  exit 1
fi

git fetch origin main
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)
if [[ "$LOCAL" != "$REMOTE" ]]; then
  echo "Error: main is not up to date with origin/main. Run: git pull"
  exit 1
fi

TAG="v$VERSION"
git tag -s "$TAG" -m "Release $TAG"
git push origin "$TAG"

echo ""
echo "Tag $TAG pushed. GitHub Actions will build and create a draft release."
echo "Review the draft at: https://github.com/pbarbenheim/julog/releases"
echo "Publish it there when ready."
