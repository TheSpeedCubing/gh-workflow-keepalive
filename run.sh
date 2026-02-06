#!/bin/bash
set -e

YQ=/usr/local/bin/yq
GITHUB_API=https://api.github.com
UA="gh-workflow-keepalive"

if [ ! -f .env ]; then
  echo ".env file not found!"
  exit 1
fi
export $(grep -v '^#' .env | xargs)

if [ -z "$GITHUB_TOKEN" ]; then
  echo "GITHUB_TOKEN not set in .env"
  exit 1
fi

CONFIG_FILE="config.yml"
if [ ! -f "$CONFIG_FILE" ]; then
  echo "config.yml not found!"
  exit 1
fi

fetch_repos() {
  local url=$1
  local page=1

  while true; do
    RES=$(curl -s \
      -H "Authorization: Bearer $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github+json" \
      -H "User-Agent: $UA" \
      "$url&page=$page")

    COUNT=$(echo "$RES" | $YQ 'length')
    [ "$COUNT" -eq 0 ] && break

    echo "$RES" | $YQ -r '.[].full_name'
    page=$((page + 1))
  done
}

process_repo() {
  local repo=$1

  echo "[REPO] $repo"

  WF_RES=$(curl -s \
    -H "Authorization: Bearer $GITHUB_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    -H "User-Agent: $UA" \
    "$GITHUB_API/repos/$repo/actions/workflows")

  WF_COUNT=$(echo "$WF_RES" | $YQ '.workflows | length')

  if [ "$WF_COUNT" -eq 0 ]; then
    echo "[WF] No workflows in $repo"
    return
  fi

  WF_IDS=$(echo "$WF_RES" | $YQ -r '.workflows[].id')
  WF_NAMES=$(echo "$WF_RES" | $YQ -r '.workflows[].name')

  paste <(echo "$WF_IDS") <(echo "$WF_NAMES") | while read -r id name; do
    echo "[WF] Enabling \"$name\" ($id)"

    CODE=$(curl -s -o /tmp/resp.$$ -w "%{http_code}" -X PUT \
      -H "Authorization: Bearer $GITHUB_TOKEN" \
      -H "Accept: application/vnd.github+json" \
      -H "User-Agent: $UA" \
      "$GITHUB_API/repos/$repo/actions/workflows/$id/enable")

    BODY=$(cat /tmp/resp.$$)
    rm -f /tmp/resp.$$

    if [ "$CODE" -eq 204 ]; then
      echo "[OK] Enabled \"$name\" in $repo"
    else
      echo "[FAIL] Enable \"$name\" in $repo status=$CODE body=$BODY"
    fi
  done
}

ORGS=$($YQ eval '.orgs[]?' "$CONFIG_FILE")
USERS=$($YQ eval '.users[]?' "$CONFIG_FILE")

for org in $ORGS; do
  REPOS=$(fetch_repos "$GITHUB_API/orgs/$org/repos?type=all&per_page=100")
  for repo in $REPOS; do
    process_repo "$repo"
  done
done

for user in $USERS; do
  REPOS=$(fetch_repos "$GITHUB_API/users/$user/repos?type=all&per_page=100")
  for repo in $REPOS; do
    process_repo "$repo"
  done
done
