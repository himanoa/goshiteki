#!/usr/bin/env bash

target() {
  local headRefName=$1

  git diff "$(git merge-base HEAD "$headRefName")" HEAD | awk '
    /^index / {
      getline
      if (!/^--- /) {
        next
      }
      getline
      filename = $0
      gsub(/^+++ b\//, "", filename)
    }
    /^@@ / {
      line = $0
      gsub(/^@@ .*\+|,.*/, "", line)
      for (gap = -1;;) {
        getline
        if (/^[ +]/) {
          ++gap
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
