#!/bin/bash

for file in *.yaml; do
  if [ -f "$file" ]; then
    output=$(yq eval 'select(has("github") )' "$file")
    if [ "$output" ]; then
      echo "File $file does have an 'github' key"
      # do something else here if needed
    fi
  fi
done