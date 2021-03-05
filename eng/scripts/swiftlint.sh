#!/bin/sh

#  swiftlint.sh
REPO_ROOT=$(dirname "$0")/../..

if which swiftformat >/dev/null; then
    echo "Formatting Swift files at paths $@"
    swiftformat --quiet --config "$REPO_ROOT/.swiftformat" $@
else
    echo "warning: SwiftFormat not installed. Download from https://github.com/nicklockwood/SwiftFormat"
fi

if which swiftlint >/dev/null; then
    echo "Correcting Swift files at paths $@"
    swiftlint autocorrect --quiet --config "$REPO_ROOT/.swiftlint.yml" --path $@
    echo "Linting Swift files at paths $@"
    swiftlint lint --quiet --config "$REPO_ROOT/.swiftlint.yml" --path $@
else
    echo "warning: SwiftLint not installed. Download from https://github.com/realm/SwiftLint"
fi
