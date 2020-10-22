#!/usr/bin/env bash

pr-id() {
  set -o pipefail
  local result

  result="$(gh api graphql \
    -F owner="$1" \
    -F name="$2" \
    -F headRefName="$3" \
    -f query='
    query($owner: String!, $name: String!, $headRefName: String!) {
      repository(owner: $owner, name: $name) {
        pullRequests(headRefName: $headRefName, first: 1, states: [OPEN]) {
          edges {
            node {
              id
              baseRefName
            }
          }
        }
      }
    }
  ' | jq -r '(.data.repository.pullRequests.edges[0].node // {})[]')"

  (( "$?" )) && return 1

  if [[ -z "$result" ]]; then
    echo 'The pull request was not found.'
    return 2
  fi

  echo "$result"
}


pr-id "$@"
