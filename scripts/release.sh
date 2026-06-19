#!/bin/bash
set -e
cd "$(dirname "$0")/.."

BUMP_TYPE="${1:-}"

if [[ "$BUMP_TYPE" != "major" && "$BUMP_TYPE" != "minor" && "$BUMP_TYPE" != "patch" ]]; then
  echo "Usage: $0 <major|minor|patch>"
  exit 1
fi

dart pub bump "$BUMP_TYPE"

# Extract version without build number (3.1.0+1 -> 3.1.0)
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //;s/+.*//')

echo "Bumped to $VERSION"

# Update README
sed -i "s/Aktuelle Version: \*\*[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\*\*/Aktuelle Version: **$VERSION**/" README.md

# Update Inno Setup installer display name
sed -i "s/AppVerName=Julog .*/AppVerName=Julog $VERSION/" windows/innosetup/setup.iss

BRANCH="release-$(echo "$VERSION" | tr '.' '-')"

git checkout -b "$BRANCH"
git add pubspec.yaml README.md windows/innosetup/setup.iss
git commit -m "Release $VERSION"
git push -u origin "$BRANCH"

gh pr create \
  --title "Release $VERSION" \
  --body "Bump version to $VERSION." \
  --base main

gh pr merge --auto --squash

echo ""
echo "PR opened and set to auto-merge. Once it lands on main, run:"
echo "  ./scripts/tag-release.sh $VERSION"
