#!/bin/sh

rgx='^[0-9]+([.][0-9]+)*$'

cdir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

projectDir=${cdir%/*}

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
    $ release.sh -b

  Increment the build number by one and set the version number to 1.0.0
    $ release.sh -b -v 1.0.0

  Set the build number to 35 and set the version number to 1.0.0
    $ release.sh -b 35 -v 1.0.0
  
endHelp
)

# show help text if called with no args
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

echo build $build
echo version $version
echo projectDir $projectDir

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
    echo "    Must provide a value for Version (-v) argument as a single number (1) or numbers seperated by periods (1.0.0)." >&2; exit 1
fi

if ! [[ $version =~ $rgx ]]; then
    echo "    Invalid Value for Version (-v). Must be a single number (1) or numbers seperated by periods (1.0.0)." >&2; exit 1
fi

echo "  Setting Version (CFBundleShortVersionString) to: $version"
echo

while true; do
    read -p "Has the version been updated to $version in all podspecs (y/n)? : " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "    Please update the version property in all podspecs to $version and run this script again." >&2; exit 1;;
        * ) echo "Please answer yes (y) or no (n).";;
    esac
done


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

echo
echo "Please confirm the local build/version number changes are correct and push to github."
echo

while true; do
    read -p "Have the updated version numbers pushed to github (y/n)? : " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) echo "    Please confirm/fix the local changes and run this script again." >&2; exit 1;;
        * ) echo "Please answer yes (y) or no (n).";;
    esac
done


carthage build --project-directory "$projectDir" --no-skip-current && \
carthage archive AzureCore AzureAuth AzureData AzurePush AzureStorage AzureMobile --project-directory "$projectDir" --output "$projectDir/Azure.framework.zip" && \
hub release create -p -a "$projectDir/Azure.framework.zip" -m "v$version" "v$version" && \
pod repo update && \
pod spec lint "$projectDir/AzureCore.podspec" --allow-warnings && pod trunk push "$projectDir/AzureCore.podspec" --allow-warnings && \
pod spec lint "$projectDir/AzureData.podspec" --allow-warnings && pod trunk push "$projectDir/AzureData.podspec" --allow-warnings && \
pod spec lint "$projectDir/AzureMobile.podspec" --allow-warnings && pod trunk push "$projectDir/AzureMobile.podspec" --allow-warnings

echo "Successfully released: v$version ($build)"


