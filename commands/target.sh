#!/usr/bin/env bash

target() {
  local headRefName=$1

  git diff "$(git merge-base HEAD "$headRefName")" HEAD | awk '
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
          printf "%s:%d: \n", filename, 1
          next
        }
        if (/^\+/) {
          break
        }
      }
      context = $0
      gsub(/^[ +-]/, "", context)
      printf "%s:%d:%s \n", filename, int(line) + int(gap), context
    }
  '
}

target "$@"
