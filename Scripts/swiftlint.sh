#!/bin/sh

#  swiftlint.sh

if which swiftlint >/dev/null; then
    swiftlint autocorrect
    swiftlint lint --quiet $@ | sed 's/error: /warning: /g'
else
    echo "warning: SwiftLint not installed. Download from https://github.com/realm/SwiftLint"
fi
