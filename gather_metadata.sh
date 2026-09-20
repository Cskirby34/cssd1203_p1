#! /usr/bin/env bash

if ["$#" -gt 1]; then
  exit 1
fi

if [ "$#" -eq 0 ]; then
    dir="."
else
    dir="$1"
fi

if [ ! -d "$dir" ]; then
    printf '%s is not a directory.\n' "$dir" >&2
    exit 1
fi

if [ ! -r "$dir" ] || [ ! -x "$dir" ]; then
    printf '%s is not readable or executable.\n' "$dir" >&2
    exit 1
fi
