#!/usr/bin/env bash


submit-review() {
  gh api graphql -f query="
    mutation {
      repository(owner: \"$1\", name:\"$2\") {
        pullRequests(headRefName: \"$3\", first: 100) {
          edges {
            node {
              id
            }
          }
        }
      }
    }
  " | jq .data.repository.pullRequests.edges[0].node.id
}


pr-id "$@"
