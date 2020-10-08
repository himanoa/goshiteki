#!/usr/bin/env bash


# submit-review pr-id body status draft-reviews-file
submit-review() {
  comments=$(sed -r 's/\"([^"]+)":(.+)/\1:\2/' < "$4")
  gh api graphql -f query="
    mutation {
      addPullRequestReview(input: {pullRequestId: \"$1\", event: $3, comments: $comments, body: \"$2\"}) {
        clientMutationId
      }
    }
  "
}


submit-review "$@"
