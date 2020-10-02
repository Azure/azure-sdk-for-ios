# Azure SDK for iOS Contributing Guide

Thank you for your interest in contributing to Azure SDK for iOS.

- For reporting bugs, requesting features, or asking for support, please file an issue in the [issues](https://github.com/Azure/azure-sdk-for-ios/issues) section of the project.

- If you would like to become an active contributor to this project please follow the instructions provided in [Microsoft Azure Projects Contribution Guidelines](https://opensource.microsoft.com/collaborate).

- To make code changes, or contribute something new, please follow the [GitHub Forks / Pull requests model](https://help.github.com/articles/fork-a-repo/): Fork the repo, make the change and propose it back by submitting a pull request.

## Pull Requests

### Submitting Pull Requests

* **DO** ensure that your code is formatted and free of lint issues by running `swiftlint` and `swiftformat` before committing.
* **DO** follow the [seven rules of a great Git commit message](https://chris.beams.io/posts/git-commit/#seven-rules) when writing your commit messages.
* **DO** submit all code changes via pull requests (PRs) rather than through a direct commit. PRs will be reviewed and potentially merged by the repo maintainers after a peer review that includes at least one maintainer.
* **DO** submit "work in progress" PRs using the GitHub [Draft Pull Request](https://help.github.com/en/github/collaborating-with-issues-and-pull-requests/about-pull-requests#draft-pull-requests) feature.
* **DO** give PRs short-but-descriptive names (e.g. "Improve code coverage for Azure.Core by 10%", not "Fix #1234")
* **DO** refer to any relevant issues, and include [keywords](https://help.github.com/articles/closing-issues-via-commit-messages/) that automatically close issues when the PR is merged.
* **DO** request reviews from -and- tag any users that should know about and/or review the change.
* **DO** ensure each commit successfully builds. The entire PR must pass all tests in the Continuous Integration (CI) system before it'll be merged.
* **DO** address PR feedback in an additional [fixup](https://thoughtbot.com/blog/autosquashing-git-commits) commit(s) rather than amending the existing commits, and only rebase/squash them once the PR is approved and ready to merge. This makes it easier for reviewers to track changes.
* **DO** reply to PR feedback with the commit ID the addresses the feedback (e.g. "Fixed in 1234abc").
* **DO** assume that ["Squash and Merge"](https://github.com/blog/2141-squash-your-commits) will be used to merge your commit unless you request otherwise in the PR.
* **DO NOT** fix merge conflicts using a merge commit. Prefer `git rebase`.
* **DO NOT** mix independent, unrelated changes in one PR. Separate real product/test code changes from larger code formatting/dead code removal changes. Separate unrelated fixes into separate PRs, especially if they are in different libraries.

### Merging Pull Requests (for project contributors with write access)

* **DO** use ["Squash and Merge"](https://github.com/blog/2141-squash-your-commits) by default for individual contributions unless requested by the PR author. Do so, even if the PR contains only one commit. It creates a simpler history than "Create a Merge Commit". Reasons that PR authors may request "Merge and Commit" may include (but are not limited to):
  - The commit history itself has semantic meaning, or the change is easier to understand as a series of individual commits. Each commit in the series should constitute an independent, isolated change, include a detailed description of the change, and be buildable so as not to break `git bisect`.
  - The contributor is using an e-mail address other than the primary GitHub address and wants that preserved in the history. Contributor must be willing to squash the commits manually before acceptance.

## Developer Guide

### Pre-requisites

- Install Xcode 10.2 or higher. The project maintainers generally work on the latest Xcode release from Apple.
- Install [Homebrew](https://brew.sh/).
- Install [CocoaPods](https://cocoapods.org/), [SwiftLint](https://github.com/realm/SwiftLint), and [SwiftFormat](https://github.com/nicklockwood/SwiftFormat) from Homebrew:
  ```bash
  brew install cocoapods swiftlint swiftformat
  ```
- [Optional] To build the API docs, install [Jazzy](https://github.com/realm/jazzy) from RubyGems:
  ```bash
  [sudo] gem install jazzy
  ```

### Building and Testing

The first time you build the project, or if the dependencies have changed, you'll need to run `pod install` to install the dependencies. Open the `AxureSDK.xcworkspace` workspace in Xcode and choose the scheme for the library or example application you wish to build. Select a deployment target, and then run the *Build* or *Test* actions.

The workspace also contains a number of meta-schemes which do not appear in the schemes drop-down by default. The per-service schemes allow you to build all libraries for a given service, and are named after the containing service directory (e.g. `storage`). The `all` scheme allows you to build all SDK libraries, and the `examples` scheme allows you to build all example applications. You can choose to show these schemes from the *Manage schemes* dialog, or you can build them from the command line:
```bash
xcodebuild -workspace AzureSDK.xcworkspace -scheme storage -sdk iphonesimulator
```
