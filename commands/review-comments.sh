#!/usr/bin/env bash

# review-comments readme.md 1 body json
review-comments() {
  echo "[{\"path\": \"$1\", \"position\": $2, \"body\": \"$3\"}]" > TMP.json
  TEMP=$(mktemp)
  if [ "$4" = "" ]; then
    cp TMP.json "$TEMP"
  else
    jq -s add "$4" TMP.json > "$TEMP" 
  fi

  rm TMP.json
  echo $TEMP
}

review-comments "$@"
