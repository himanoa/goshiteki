#!/usr/bin/env bash

# line-in-range 1 add
line-in-range() {
  local line=$1
  local target=$2
  shift 2

  if [[ ! $line =~ ^[0-9]+$ ]]; then
    echo '$1 must be a number' >&2
    return 1
  fi
  if [[ ! $target =~ ^(add|remove)$ ]]; then
    echo '$2 must be add or remove' >&2
    return 1
  fi

  awk \
    -v line="$line" \
    -v target="$target" '
    /^@@/ {
      orig = $0
      gsub(/ @@.*/, " @@", orig)

      if (target == "add") {
        gsub(/^@@[^+]+\+| @@.*/, "")
      }
      if (target == "remove") {
        gsub(/^@@ -| .*/, "")
      }

      start = $0
      gsub(/,.*/, "", start)

      sum = $0
      gsub(/.*,/, "", sum)

      for (i = int(start); i <= int(start) + int(sum); ++i) {
        if (i == line) {
          found = 1
          exit
        }
      }
    }
    END {
      if (!found) {
        exit 1
      }
    }
  '
}

line-in-range "$@"
