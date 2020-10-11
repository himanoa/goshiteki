#!/usr/bin/env bash

# review-comments readme.md 1 body json
review-comments() {
  local REVIEW_COMMENT_STATE="./.REVIEW_COMMENT_STATE"
  local current=$(cat -- "$REVIEW_COMMENT_STATE" 2> /dev/null)

  jq \
    --arg path "$1" \
    --arg position "$2" \
    --arg body "$3" \
    'flatten + [{path: $path, position: $position | tonumber, body: $body}]' \
    <<< "${current:-[]}" > "$REVIEW_COMMENT_STATE"
}

review-comments "$@"
