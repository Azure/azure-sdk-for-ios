#!/bin/sh

cdir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

rgx='^[0-9]+([.][0-9]+)*$'

helpText=$(cat << endHelp

Azure.iOS Version Utility

Options:
  -h  View this text again.

  -b  Build (CFBundleVersion): Optionally pass in a new build number.
        The value must be a number (1) or period seperated numbers (1.0.0).
        If no value is passed in, the current build number will be incremented by 1.

  -v  Version (CFBundleShortVersionString): Pass in a value to set as the Version Number.
        The value must be a number (1) or period seperated numbers (1.0.0).

Examples:
  
  Increment the build number by one
    $ version.sh -b

  Increment the build number by one and set the version number to 1.0.0
    $ version.sh -b -v 1.0.0

  Set the build number to 35 and set the version number to 1.0.0
    $ version.sh -b 35 -v 1.0.0
  
endHelp
)

if (($# == 0)); then
    echo "$helpText" >&2; exit 0
fi

while getopts ":b:v:h:" opt; do
    case $opt in
        b)  build=$OPTARG;;
        v)  version=$OPTARG;;
        h)  echo "$helpText" >&2; exit 0;;
        \?) echo "    Invalid option -$OPTARG $helpText" >&2; exit 1;;
        :)  echo "    Option -$OPTARG requires an argument $helpText." >&2; exit 1;;
    esac
done

if [[ $build ]]; then
    if ! [[ $build =~ $rgx ]]; then
        echo "    Invalid Value for Build (-b). Must be empty, a number (1) or period seperated numbers (1.0.0)." >&2; exit 1
    fi

    echo "  Setting Build (CFBundleVersion) to: $build"
else
    echo "  Incrementing Build (CFBundleVersion) by one"
fi


if [[ $version ]]; then
    if ! [[ $version && $version =~ $rgx ]]; then
        echo "    Invalid Value for Version (-v). Must be a number (1) or period seperated numbers (1.0.0)." >&2; exit 1
    fi

    echo "  Setting Version (CFBundleShortVersionString) to: $version"
fi


for project in AzureCore AzureData AzureAuth AzurePush AzureStorage AzureMobile; do

    pushd $cdir/../$project > /dev/null

        echo "    ...applying to: $project"

        if [[ $build ]]; then
            xcrun agvtool new-version -all $build > /dev/null
        else
            xcrun agvtool bump -all > /dev/null
        fi

        if [[ $version ]]; then
            xcrun agvtool new-marketing-version $version > /dev/null
        fi
    
    popd > /dev/null

done
