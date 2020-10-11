#!/usr/bin/env bash

# submit-review pr-id body status draft-reviews-file
submit-review() {
  local comments=$(jq -r '
    "[" + (
      map(
        "{" + (to_entries | map("\(.key): \(.value | @json)") | join(", ")) + "}"
      ) | join(", ")
    ) + "]"' "$4")

  gh api graphql \
    -F pullRequestId="$1" \
    -F body="$2" \
    -F event="$3" \
    -f query='
    mutation($pullRequestId: ID!, $body: String, $event: String) {
      addPullRequestReview(input: {pullRequestId: $pullRequestId, body: $body, event: $event, comments: '"$comments"'}) {
        clientMutationId
      }
    }
  '
  rm "$4"
}

submit-review "$@"
