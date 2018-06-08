#!/bin/sh

cdir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

projectDir=${dir%/*}

helpText=$(cat << endHelp

Azure.iOS Release Utility

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

# show help text if called with no args
if (($# == 0)); then
    echo "$helpText" >&2; exit 0
fi


while getopts ":bv:h:" opt; do
    case $opt in
        b)  build=$OPTARG;;
        v)  version=$OPTARG;;
        h)  echo "$helpText" >&2; exit 0;;
        \?) echo "    Invalid option -$OPTARG $helpText" >&2; exit 1;;
        :)  echo "    Option -$OPTARG requires an argument $helpText." >&2; exit 1;;
    esac
done


# 
# check if values were provided for the build and version arguments
# confirm the value(s) conform to the version number format requirements
#
if [[ $build ]]; then
    if ! [[ $build =~ $rgx ]]; then
        echo "    Invalid Value for Build (-b). Must be empty, a number (1) or period seperated numbers (1.0.0)." >&2; exit 1
    fi
    echo "  Setting Build (CFBundleVersion) to: $build"
else
    echo "  Incrementing Build (CFBundleVersion) by one"
fi


if ! [[ $version ]]; then
    echo "    Must provide a value for Version (-v) argument as a single number (1) numbers seperated by periods (1.0.0)." >&2; exit 1
fi

if ! [[ $version =~ $rgx ]]; then
    echo "    Invalid Value for Version (-v). Must be a single number (1) numbers seperated by periods (1.0.0)." >&2; exit 1
fi

echo "  Setting Version (CFBundleShortVersionString) to: $version"


#
# loop through the projects and update the build and version numbers
#
for project in AzureCore AzureData AzureAuth AzurePush AzureStorage AzureMobile; do

    pushd $cdir/../$project > /dev/null

        echo "    ...applying to: $project"

        if [[ $build ]]; then
            xcrun agvtool new-version -all $build > /dev/null
        else
            xcrun agvtool bump -all > /dev/null
        fi

        xcrun agvtool new-marketing-version $version > /dev/null
    
    popd > /dev/null

done



carthage build --project-directory "$projectDir" --no-skip-current && \
carthage archive AzureCore AzureAuth AzureData AzurePush AzureStorage AzureMobile --project-directory "$projectDir" --output "$projectDir/Azure.framework.zip" && \
hub release create -p -a "$projectDir/Azure.framework.zip" -m "v$versionNumber" "v$versionNumber" && \
pod spec lint "$projectDir/AzureCore.podspec" --allow-warnings && pod trunk push "$projectDir/AzureCore.podspec" --allow-warnings && \
pod spec lint "$projectDir/AzureData.podspec" --allow-warnings && pod trunk push "$projectDir/AzureData.podspec" --allow-warnings && \
pod spec lint "$projectDir/AzureMobile.podspec" --allow-warnings && pod trunk push "$projectDir/AzureMobile.podspec" --allow-warnings






