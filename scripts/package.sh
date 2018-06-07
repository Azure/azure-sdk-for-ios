#! /bin/sh

# Before running this command:
#
# - Increment Version Numbers in Targets
#     $ versions.sh -b -v [new version number]
#
# - Increment Version Numers in Podspecs
#    - AzureCore
#    - AzureAuth
#    - AzureData
#    - AzurePush
#    - AzureStorage
#      

dir=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

projectDir=${dir%/*}

versionNumber=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" $projectDir/AzureCore/Source/Info.plist)

echo Version Number : "$versionNumber"
echo Project Path : "$projectDir"


carthage build --project-directory "$projectDir" --no-skip-current && \
carthage archive AzureCore AzureAuth AzureData AzurePush AzureStorage --project-directory "$projectDir" --output "$projectDir/Azure.framework.zip" && \
hub release create -p -a "$projectDir/Azure.framework.zip" -m "v$versionNumber" "v$versionNumber" && \
pod spec lint "$projectDir/AzureCore.podspec" --allow-warnings && pod trunk push "$projectDir/AzureCore.podspec" --allow-warnings && \
pod spec lint "$projectDir/AzureData.podspec" --allow-warnings && pod trunk push "$projectDir/AzureData.podspec" --allow-warnings

# pod repo push mypods "$projectDir/AzureCore.podspec" --allow-warnings && \
# pod repo push "$projectDir/mypods AzureData.podspec" --allow-warnings && \
