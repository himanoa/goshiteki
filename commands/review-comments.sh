#!/usr/bin/env bash

# review-comments readme.md 1 body json
review-comments() {
  local REVIEW_COMMENT_STATE="./.REVIEW_COMMENT_STATE"
  local current=$(cat -- "$REVIEW_COMMENT_STATE" 2> /dev/null)
  local path=$1
  local line=$2
  local body=$3
  local position

  # TODO: Change upstream branch (currently `master`) to correct one!
  # TODO: Change `add` to correct one!
  if ! position=$(git diff --diff-algorithm=default master -- "$path" | "$(dirname -- "$0")"/line-to-position "$line" add); then
    return 1
  fi

  jq \
    --arg path "$path" \
    --arg position "$position" \
    --arg body "$body" \
    'flatten + [{path: $path, position: $position | tonumber, body: $body}]' \
    <<< "${current:-[]}" > "$REVIEW_COMMENT_STATE"
}

review-comments "$@"
