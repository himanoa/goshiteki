#!/usr/bin/env bash

target() {
  local dir=${PWD#$(git rev-parse --show-toplevel)}
  local tmp=${dir//[^\/]/}
  local relative_prefix=${tmp//\//../}
  local base_branch=$1

  git diff --diff-algorithm=default "$(git merge-base HEAD "$base_branch")" HEAD |
    awk -v relative_prefix="$relative_prefix" '
    /^index / {
      getline
      if (!/^--- /) {
        next
      }
      filename = $0
      getline
      if (/^\+\+\+ b\//) {
        filename = $0
      }
      gsub(/^(--- a|\+\+\+ b)\//, "", filename)
    }
    /^@@ / {
      line = $0
      gsub(/^@@ .*\+|,.*/, "", line)
      for (gap = -1;;) {
        getline
        if (/^[ +]/) {
          ++gap
        }
        if (!/^[ +-]/) {
          printf "%s%s:%d: \n", relative_prefix, filename, 1
          next
        }
        if (/^\+/) {
          break
        }
      }
      context = $0
      gsub(/^[ +-]/, "", context)
      printf "%s%s:%d:%s \n", relative_prefix, filename, int(line) + int(gap), context
    }
  '
}

target "$@"
