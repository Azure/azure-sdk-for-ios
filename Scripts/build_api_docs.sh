#!/bin/sh

if which jazzy >/dev/null; then
    if [[ -z "$1" ]]; then
      echo "Usage: $(basename $0) <library-to-generate>|all"
      exit 1
    fi
    cd $(git rev-parse --show-toplevel)
    if [[ "$1" == "all" ]]; then
      for cfg in .jazzy/*.yml; do
        echo "Generating API docs for $(basename $cfg .yml)"
        jazzy --config $cfg
      done
      echo "Generating index"
      erb .jazzy/index.html.erb > build/jazzy/index.html
    elif [[ -f ".jazzy/$1.yml" ]]; then
        echo "Generating API docs for $1"
        jazzy --config ".jazzy/$1.yml"
        echo "Generating index"
        erb .jazzy/index.html.erb > build/jazzy/index.html
    else
        echo "warning: No Jazzy configuration for $1 was found."
        exit 1
    fi
else
    echo "warning: Jazzy not installed. Download from https://github.com/realm/jazzy"
    exit 1
fi
