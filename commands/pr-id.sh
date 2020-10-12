#!/usr/bin/env bash

pr-id() {
  gh api graphql \
    -F owner="$1" \
    -F name="$2" \
    -F headRefName="$3" \
    -f query='
    query($owner: String!, $name: String!, $headRefName: String!) {
      repository(owner: $owner, name: $name) {
        pullRequests(headRefName: $headRefName, first: 100) {
          edges {
            node {
              id
              baseRefName
            }
          }
        }
      }
    }
  ' | jq -r '.data.repository.pullRequests.edges[0].node[]' 
}


pr-id "$@"
