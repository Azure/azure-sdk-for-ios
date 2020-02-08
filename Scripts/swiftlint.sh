#!/bin/sh

#  swiftlint.sh

if which swiftformat >/dev/null; then
    echo "Formatting Swift files at paths $@"
    swiftformat --quiet $@
else
    echo "warning: SwiftFormat not installed. Download from https://github.com/nicklockwood/SwiftFormat"
fi

if which swiftlint >/dev/null; then
    echo "Correcting Swift files at paths $@"
    swiftlint autocorrect --quiet --path $@
    echo "Linting Swift files at paths $@"
    swiftlint lint --quiet --path $@
else
    echo "warning: SwiftLint not installed. Download from https://github.com/realm/SwiftLint"
fi
