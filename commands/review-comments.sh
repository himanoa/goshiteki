#!/usr/bin/env bash

# review-comments readme.md 1 body json
review-comments() {
  echo "[{\"path\": \"$1\", \"position\": $2, \"body\": \"$3\"}]" > TMP.json
  REVIEW_COMMENT_STATE="./.REVIEW_COMMENT_STATE"
  if [ -e $REVIEW_COMMENT_STATE ]; then
    # shellcheck disable=SC2094
    jq -s add "$REVIEW_COMMENT_STATE" TMP.json "." > NEW_REVIEW_COMMENT_STATE 
    mv NEW_REVIEW_COMMENT_STATE "$REVIEW_COMMENT_STATE"
  else
    cp TMP.json "$REVIEW_COMMENT_STATE"
  fi

  rm TMP.json
}

review-comments "$@"
