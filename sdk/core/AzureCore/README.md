# Azure core client library for iOS

This is the core framework for the Azure SDK for iOS, containing the HTTP pipeline, as well as a shared set of
components that are used across all client libraries, including pipeline policies, error types, type aliases, an XML
Codable implementation, and a logging system. As an end user, you don't need to manually install AzureCore because it
will be installed automatically when you install other SDK libraries. If you are a client library developer, please
reference the [AzureStorageBlob](https://github.com/Azure/azure-sdk-for-ios/tree/master/sdk/storage/AzureStorageBlob)
library as an example of how to use the shared AzureCore components in your client library.

## Getting started

### CocoaPods

To integrate this library into your project using CocoaPods, specify it in your
[Podfile](https://guides.cocoapods.org/using/the-podfile.html):

```ruby
pod 'AzureCore', '~> 0.1'
```

### Carthage

To integrate this library into your project using Carthage, specify the release feed in your
[Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```ruby
binary "https://github.com/Azure/azure-sdk-for-ios/raw/master/releases/AzureCore.json" ~> 0.1
```

> Note: To obtain a build with debug symbols included, use the `AzureCore-symbols.json` feed instead.

## Key concepts

The main shared concepts of AzureCore (and thus, Azure SDK libraries using AzureCore) include:

- Configuring service clients, e.g. policies, logging (`HeadersPolicy` et al., `ClientLogger`).
- Accessing HTTP response details (`HTTPResponse`, `HTTPResultHandler<T>`).
- Paging and asynchronous streams (`PagedCollection<T>`).
- Exceptions for reporting errors from service requests in a consistent fashion. (`AzureError`, `HTTPResponseError`).
- Abstractions for representing Azure SDK credentials. (`AccessToken`).

## Examples

TODO

## Troubleshooting

If you run into issues while using this library, please feel free to
[file an issue](https://github.com/Azure/azure-sdk-for-ios/issues/new).

## Next steps

Explore and install
[available Azure SDK libraries](https://github.com/Azure/azure-sdk-for-ios/blob/master/README.md#packages-available).

## Contributing

This project welcomes contributions and suggestions. Most contributions require you to agree to a Contributor License
Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For
details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide a CLA and decorate
the PR appropriately (e.g., label, comment). Simply follow the instructions provided by the bot. You will only need to
do this once across all repositories using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact
[opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

![Impressions](https://azure-sdk-impressions.azurewebsites.net/api/impressions/azure-sdk-for-ios%2Fsdk%2Fcore%2FAzureCore%2FREADME.png)
