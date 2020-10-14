#!/usr/bin/env bash

# review-comments readme.md 1 body json
review-comments() {
  local REVIEW_COMMENT_STATE="./.REVIEW_COMMENT_STATE"
  local current=$(cat -- "$REVIEW_COMMENT_STATE" 2> /dev/null)
  local path=$1
  local start_line=$2
  local end_line=$3
  local body=$4
  local base_branch=$5

  if ! git diff --diff-algorithm=default "$base_branch" -- "$path" | "$(dirname -- "$0")"/line-in-range.sh "$start_line" add; then
    return 1
  fi

  if ! git diff --diff-algorithm=default "$base_branch" -- "$path" | "$(dirname -- "$0")"/line-in-range.sh "$end_line" add; then
    return 1
  fi

  if [ "$start_line" = "$end_line" ]; then
    jq \
      --arg path "$path" \
      --arg start_line "$start_line" \
      --arg body "$body" '
      flatten + [
        {
          path: $path,
          line: $start_line | tonumber,
          body: $body,
          startSide: "RIGHT",
          side: "RIGHT"
        }
      ]' <<< "${current:-[]}" > "$REVIEW_COMMENT_STATE"
  else
    jq \
      --arg path "$path" \
      --arg start_line "$start_line" \
      --arg end_line "$end_line" \
      --arg body "$body" '
      flatten + [
        {
          path: $path,
          startLine: $start_line | tonumber,
          line: $end_line | tonumber,
          body: $body,
          startSide: "RIGHT",
          side: "RIGHT"
        }
      ]' <<< "${current:-[]}" > "$REVIEW_COMMENT_STATE"
  fi
}

review-comments "$@"
