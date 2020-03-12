#!/bin/sh

if which jazzy >/dev/null; then
  if [ -z "$1" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Usage: $(basename "$0") (<library-to-generate>... | all)"
    exit 1
  fi

  cd "$(git rev-parse --show-toplevel)" || { echo "error: Script must be executed within Git repository."; exit 1; }

  if [ "$1" = "all" ]; then
    for cfg in .jazzy/*.yml; do
      echo "Generating API docs for $(basename "$cfg" .yml)"
      jazzy --config "$cfg"
    done
    echo "Generating index"
    erb .jazzy/index.html.erb > build/jazzy/index.html
  else
    index=n
    for lib in "$@"; do
      if [ -f ".jazzy/$lib.yml" ]; then
        index=y
        echo "Generating API docs for $lib"
        jazzy --config ".jazzy/$lib.yml"
      else
        echo "warning: No Jazzy configuration for $lib was found, it will be skipped."
      fi
    done

    if [ "$index" = "y" ]; then
      echo "Generating index"
      erb .jazzy/index.html.erb > build/jazzy/index.html
    fi
  fi
else
  echo "error: Jazzy not installed. Download from https://github.com/realm/jazzy"
  exit 1
fi
