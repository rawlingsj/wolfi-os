#!/bin/bash

for file in *.yaml; do
  if [ -f "$file" ]; then
    output=$(yq eval 'select(has("update") | not)' "$file")
    if [ -n "$output" ]; then
      echo "File $file does not have an 'update' key"
      # do something else here if needed
    fi
  fi
done