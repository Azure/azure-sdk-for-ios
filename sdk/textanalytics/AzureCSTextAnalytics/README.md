# Azure Cognitive Services - Text Analytics client library for iOS

Azure Cognitive Services Text Analytics is a cloud service that provides advanced natural language processing over raw
text.

## Getting started

### CocoaPods

To integrate this library into your project using CocoaPods, specify it in your
[Podfile](https://guides.cocoapods.org/using/the-podfile.html):

```ruby
pod 'AzureCSTextAnalytics', '~> 0.1'
```

### Carthage

To integrate this library into your project using Carthage, specify the release feed in your
[Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile):

```ruby
binary "https://github.com/Azure/azure-sdk-for-ios/raw/master/releases/AzureCSTextAnalytics.json" ~> 0.1
```

> Note: To obtain a build with debug symbols included, use the `AzureCSTextAnalytics-symbols.json` feed instead.

## Key concepts

Text Analytics includes six main functions: 
- Language Detection
- Sentiment Analysis
- Key Phrase Extraction
- Named Entity Recognition
- Recognition of Personally Identifiable Information 
- Linked Entity Recognition

AzureCSTextAnalytics allows you to perform one or more such operations on a block of text input, known as a document,
via the `TextAnalyticsClient`.

## Examples

TODO

## Troubleshooting

If you run into issues while using this library, please feel free to
[file an issue](https://github.com/Azure/azure-sdk-for-ios/issues/new).

## Next steps

Get started with our [Text Analytics samples](samples) to learn how to use `TextAnalyticsClient` within your
applications.

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

![Impressions](https://azure-sdk-impressions.azurewebsites.net/api/impressions/azure-sdk-for-ios%2Fsdk%2Ftextanalytics%2FAzureCSTextAnalytics%2FREADME.png)
