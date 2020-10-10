#!/usr/bin/env bash

pr-id() {
  gh api graphql -f query="
    query {
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
  " | jq -r .data.repository.pullRequests.edges[0].node.id
}


pr-id "$@"
