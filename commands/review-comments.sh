#!/usr/bin/env bash

# review-comments readme.md 1 body json
review-comments() {
  local REVIEW_COMMENT_STATE="./.REVIEW_COMMENT_STATE"
  local current=$(cat -- "$REVIEW_COMMENT_STATE" 2> /dev/null)
  local path=$1
  local line=$2
  local body=$3
  local base_branch=$4

  if ! git diff --diff-algorithm=default "$base_branch" -- "$path" | "$(dirname -- "$0")"/line-in-range.sh "$line" add; then
    return 1
  fi

  jq \
    --arg path "$path" \
    --arg line "$line" \
    --arg body "$body" '
    flatten + [
      {
        path: $path,
        line: $line | tonumber,
        body: $body,
        startSide: "RIGHT",
        side: "RIGHT"
      }
    ]' <<< "${current:-[]}" > "$REVIEW_COMMENT_STATE"
}

review-comments "$@"
