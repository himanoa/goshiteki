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

  if [[ -z $body ]]; then
    return 1
  fi

  if ! git diff --diff-algorithm=default "$(git merge-base HEAD "$base_branch")" -- "$path" | "$(dirname -- "$0")"/line-in-range.sh "$start_line" add; then
    return 1
  fi

  if ! git diff --diff-algorithm=default "$(git merge-base HEAD "$base_branch")" -- "$path" | "$(dirname -- "$0")"/line-in-range.sh "$end_line" add; then
    return 1
  fi

  if [[ "$start_line" = "$end_line" ]]; then
    start_line=
  fi

  jq \
  --arg path "$path" \
  --arg start_line "$start_line" \
  --arg end_line "$end_line" \
  --arg body "$body" '
  flatten + [
    {
      path: $path,
      startLine: (try ($start_line | tonumber) catch null),
      line: $end_line | tonumber,
      body: $body,
      startSide: "RIGHT",
      side: "RIGHT"
    }
  ]' <<< "${current:-[]}" > "$REVIEW_COMMENT_STATE"
}

review-comments "$@"
