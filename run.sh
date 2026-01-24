#!/bin/bash
set -e

# 讀取 .env
if [ ! -f .env ]; then
  echo ".env file not found!"
  exit 1
fi
export $(grep -v '^#' .env | xargs)

if [ -z "$GITHUB_TOKEN" ]; then
  echo "GITHUB_TOKEN not set in .env"
  exit 1
fi

CONFIG_FILE="workflows.yml"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "workflows.yml not found!"
  exit 1
fi

REPOS=$(yq eval '.repos | keys | .[]' "$CONFIG_FILE")

for repo in $REPOS; do
  WORKFLOWS=$(yq eval ".repos.\"$repo\"[]" "$CONFIG_FILE")
  for wf in $WORKFLOWS; do
    echo "Enabling workflow $wf in repository $repo..."
    RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X PUT \
      -H "Authorization: Bearer $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github+json" \
      "https://api.github.com/repos/$repo/actions/workflows/$wf/enable")

    if [ "$RESPONSE" -eq 204 ]; then
      echo "Success: $wf enabled in $repo"
    else
      echo "Failed: $wf in $repo, HTTP code $RESPONSE"
    fi
  done
done
