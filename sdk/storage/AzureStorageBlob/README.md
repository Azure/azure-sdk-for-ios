# Azure Storage Blobs client library for iOS
Azure Blob storage is Microsoft's object storage solution for the cloud. Blob storage is optimized for storing massive amounts of unstructured data, such as text or binary data.

Blob storage is ideal for:

* Serving images or documents directly to a browser
* Storing files for distributed access
* Streaming video and audio
* Storing data for backup and restore, disaster recovery, and archiving
* Storing data for analysis by an on-premises or Azure-hosted service

[Source code](https://github.com/Azure/azure-sdk-for-ios/tree/master/sdk/storage/AzureStorageBlob) | [API reference documentation](...) | [Product documentation](https://docs.microsoft.com/azure/storage/) | [Samples](https://github.com/Azure/azure-sdk-for-ios/tree/master/examples/AzureSDKDemoSwift)


## Getting started

### Prerequisites
* The client library is written in modern Swift 5. Due to this, Xcode 10.2 or higher is required to use this library.
* You must have an [Azure subscription](https://azure.microsoft.com/free/) and an
[Azure storage account](https://docs.microsoft.com/azure/storage/common/storage-account-overview) to use this library.

### Install the library
At the present time, to install the Azure Storage Blobs client library for iOS you must download the latest
[release](https://github.com/Azure/azure-sdk-for-ios/releases) and integrate it into your project manually:

#### Manually integrate the library into your project

To manually integrate this library into your project, first download the latest releases of the following libraries from
the repository's [Releases](https://github.com/Azure/azure-sdk-for-ios/releases) page:

* `AzureCore.framework`
* `AzureStorageBlob.framework`

Extract the .frameworks to your project's "Frameworks" folder. Select your project in Xcode's Project navigator, and
then select the desired target in the Targets list. Drag & drop the .frameworks from your project's "Frameworks" folder
into the "Frameworks, Libraries, and Embedded Content" section.

> Note: To include debug symbols for these frameworks in your project, download the corresponding `dSYM` archives,
> extract them to a location within your project directory, and add a Build Phase to your project that will copy them to
> your Products Directory when installing.

If you plan to use the [Microsoft Authentication Library (MSAL) for iOS](http://aka.ms/aadv2) in your project, add it by
following the library's
[installation instructions](https://github.com/AzureAD/microsoft-authentication-library-for-objc#installation).

### Create a storage account
If you wish to create a new storage account, you can use the
[Azure Portal](https://docs.microsoft.com/azure/storage/common/storage-quickstart-create-account?tabs=azure-portal),
[Azure PowerShell](https://docs.microsoft.com/azure/storage/common/storage-quickstart-create-account?tabs=azure-powershell),
or [Azure CLI](https://docs.microsoft.com/azure/storage/common/storage-quickstart-create-account?tabs=azure-cli):

```bash
# Create a new resource group to hold the storage account -
# if using an existing resource group, skip this step
az group create --name my-resource-group --location westus2

# Create the storage account
az storage account create -n my-storage-account-name -g my-resource-group
```

### Create the client
The Azure Storage Blobs client library for iOS allows you to interact with blob storage containers and blobs.
Interaction with these resources starts with an instance of a [client](#client). To create a client object, you will
need a credential that allows you to access the storage account:

```swift
import AzureStorageBlob

let credential = ...
let client = StorageBlobClient(credential: credential)
```

Certain types of credentials may also require you to provide the storage account's blob service account URL:

```swift
import AzureStorageBlob

let accountUrl = "https://<my-storage-account-name>.blob.core.windows.net/"
let credential = ...
let client = StorageBlobClient(accountUrl: accountUrl, credential: credential)
```

#### Looking up the account URL
You can find the storage account's blob service URL using the 
[Azure Portal](https://docs.microsoft.com/azure/storage/common/storage-account-overview#storage-account-endpoints),
[Azure PowerShell](https://docs.microsoft.com/powershell/module/az.storage/get-azstorageaccount),
or [Azure CLI](https://docs.microsoft.com/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-show):

```bash
# Get the blob service account url for the storage account
az storage account show -n my-storage-account-name -g my-resource-group --query "primaryEndpoints.blob"
```

#### Types of credentials
The `credential` parameter may be provided in a number of different forms, depending on the type of
[authorization](https://docs.microsoft.com/azure/storage/common/storage-auth) you wish to use.

##### Shared Access Signature
To use a [shared access signature (SAS) token](https://docs.microsoft.com/azure/storage/common/storage-sas-overview),
provide the token as a string. SAS tokens can scoped to provide access to an entire storage account, a single blob
container, or even an individual blob, and contain an explicit grant of permissions and validity period. You can
generate a SAS token from the Azure Portal under "Shared access signature", or from Azure Storage Explorer by selecting
"Get Shared Access Signature...".

To initialize a client instance with an account-level SAS token, create an instance of `StorageSASCredential` with the
Shared Access Signature Connection String, and provide that credential when initializing your `StorageBlobClient`:

```swift
import AzureStorageBlob

let sasConnectionString = "SharedAccessSignature=xxxx;BlobEndpoint=https://xxxx.blob.core.windows.net/;"
let sasCredential = StorageSASCredential(connectionString: sasConnectionString)
let client = StorageBlobClient(credential: credential)
```

When you create a Shared Access Signature that is scoped to a storage container or blob, it will be generated as a
Shared Access Signature URI, rather than a connection string. To initialize a client instance with a container- or
blob-level SAS token, create an instance of `StorageSASCredential` with the Shared Access Signature URI, and provide
that credential when initializing your `StorageBlobClient`:

```swift
import AzureStorageBlob

let sasUri = "https://xxxx.blob.core.windows.net/container/path/to/blob?xxxx"
let sasCredential = StorageSASCredential(blobSasUri: sasUri)
let client = StorageBlobClient(credential: credential)
```

##### Microsoft Authentication Library (MSAL) for iOS
To use the [Microsoft Authentication Library (MSAL) for iOS](https://github.com/AzureAD/microsoft-authentication-library-for-objc)
to authenticate your client, you will need to provide your AAD tenant ID and your application's client ID, and you will
need use the MSAL for iOS library to authenticate the user and obtain instances of `MSALPublicClientApplication` and
`MSALAccount`. Refer to the [AzureSDKSwiftDemo](https://github.com/Azure/azure-sdk-for-ios/tree/master/examples/AzureSDKDemoSwift)
sample for an example of how to use the MSAL for iOS library to authenticate a `StorageBlobClient`.

To initialize a client instance with an MSAL credential, create an instance of `MSALCredential` using your AAD tenant
ID, client ID, MSAL application object, and MSAL account object. Provide that credential and your account URL when
initializing your `StorageBlobClient`:

```swift
import AzureCore
import AzureStorageBlob
import MSAL

// Refer to the MSAL for iOS library documentation for information on how to
// initialize these values in your application
let application: MSALPublicClientApplication? = ...
let account: MSALAccount? = ...

let accountUrl = "https://xxxx.blob.core.windows.net"
let msalCredential = MSALCredential(
    tenant: "00112233-4455-6677-8899-aabbccddeeff",
    clientId: "00112233-4455-6677-8899-aabbccddeeff",
    application: msalApplication,
    account: msalAccount
)
let client = StorageBlobClient(accountUrl: accountUrl, credential: credential)
```

##### Storage account connection string
Depending on your use case and authorization method, you may prefer to initialize a client instance with a storage
connection string instead of providing the account URL and credential separately.

> **WARNING**: Connection strings are inherently insecure in a mobile application. Connection strings provide full
> access to a storage account. Any connection strings used should be read-only and not have write permissions.

To initialize a client instance with a storage connection string, provide the connection string when initializing your
`StorageBlobClient`:

```swift
import AzureStorageBlob

let connectionString = "DefaultEndpointsProtocol=https;AccountName=xxxx;AccountKey=xxxx;EndpointSuffix=core.windows.net"
let client = StorageBlobClient(connectionString: connectionString)
```

The connection string to your storage account can be found in the Azure Portal under the "Access Keys" section or by
running the following CLI command:

```bash
az storage account show-connection-string -g MyResourceGroup -n MyStorageAccount
```

## Key concepts
The following components make up the Azure Blob Service:
* The storage account itself
* A container within the storage account
* A blob within a container

The Azure Storage Blobs client library for iOS allows you to interact with some of these components through the `AzureStorageBlob` client.

### Client
A single client is provided to interact with the various components of the Blob Service:
1. [StorageBlobClient](https://github.com/Azure/azure-sdk-for-ios/blob/dev/sdk/storage/AzureStorageBlob/Source/StorageBlobClient.swift) -
   this client represents interaction with a specific blob container. It provides operations to upload, download and list blobs.

### Blob Types
The `StorageBlobClient` only works with block blobs:
* [Block blobs](https://docs.microsoft.com/rest/api/storageservices/understanding-block-blobs--append-blobs--and-page-blobs#about-block-blobs)
  store text and binary data, up to approximately 4.75 TiB. Block blobs are made up of blocks of data that can be
  managed individually

## Examples
The following sections provide several code snippets covering some of the most common Storage Blob tasks, including:

* [Uploading a blob](#uploading-a-blob "Uploading a blob")
* [Downloading a blob](#downloading-a-blob "Downloading a blob")
* [Enumerating blobs](#enumerating-blobs "Enumerating blobs")

Note that a container must already be created to upload or download a blob.

### Create a container

Create a container from where you can upload or download blobs.
```bash
az storage container create --account-name <my_account> --name <my_container>
```

### Enumerating blobs
List the blobs asynchronously in your container

```swift
import AzureStorageBlob

let containerName = "<my_container>"
let connectionString = "DefaultEndpointsProtocol=https;AccountName=xxxx;AccountKey=xxxx;EndpointSuffix=core.windows.net"
let client = StorageBlobClient(connectionString: connectionString)

let options = ListBlobsOptions(maxResults: 20)
client.listBlobs(inContainer: containerName, withOptions: options) { result, httpResponse in
    switch result {
    case let .success(paged):
        // Do what you want with the paged result object
    case let .failure(error):
        // handle error
    }
}
```

### Uploading a blob
Upload a blob asynchronously to your container

```swift
import AzureStorageBlob

let containerName = "<my_container>"
let connectionString = "DefaultEndpointsProtocol=https;AccountName=xxxx;AccountKey=xxxx;EndpointSuffix=core.windows.net"
let client = StorageBlobClient(connectionString: connectionString)

let blobName = "<my_blob>"
let sourceUrl = URL(string: "<path_to_file>")
let properties = BlobProperties(
    contentType: "image/jpg"
)
let transfer = try? client.upload(
    file: sourceUrl,
    toContainer: containerName,
    asBlob: blobName,
    properties: properties,
    withRestorationId: "upload"
)
```

### Downloading a blob
Download a blob asynchronously from your container

```swift
import AzureStorageBlob

let containerName = "<my_container>"
let connectionString = "DefaultEndpointsProtocol=https;AccountName=xxxx;AccountKey=xxxx;EndpointSuffix=core.windows.net"
let client = StorageBlobClient(connectionString: connectionString)

let blobName = "<my_blob>"
let destinationUrl = URL(string: "<path_on_disk>")
let transfer = try? client.download(
    blob: blobName,
    fromContainer: containerName,
    toFile: destinationUrl,
    withRestorationId: "download"
)
```

## Troubleshooting
### General
Storage Blob clients raise exceptions defined in [Azure Core](https://github.com/Azure/azure-sdk-for-ios/blob/dev/sdk/core/AzureCore/Source/Errors.swift).

### Logging
This library uses the [ClientLogger](https://github.com/Azure/azure-sdk-for-ios/blob/dev/sdk/core/AzureCore/Source/ClientLogger.swift) protocol for logging. The desired style of logger can be set when initializing the
client:

```swift

import AzureCore
import AzureStorageBlob

let connectionString = "DefaultEndpointsProtocol=https;AccountName=xxxx;AccountKey=xxxx;EndpointSuffix=core.windows.net"
let logger = NSLogger(tag: "StorageBlobClient")
let clientOptions = StorageBlobClientOptions(logger: logger)
let client = StorageBlobClient.from(connectionString: connectionString, withOptions: clientOptions)
```

The following loggers are provided, but custom loggers can be created by implementing the `ClientLogger` protocol:

- `NullClientLogger`: Suppress all logging.
- `PrintLogger`: Log via print statements to STDOUT.
- `NSLogger`: Uses the `NSLog` class for logging. The default prior to iOS 10.2.
- `OSLogger`: Uses the `os_log` method for logging. The default for iOS 10.2 and above.

The helper struct `ClientLoggers` contains static access to common loggers:

```swift

import AzureCore
import AzureStorageBlob

let connectionString = "DefaultEndpointsProtocol=https;AccountName=xxxx;AccountKey=xxxx;EndpointSuffix=core.windows.net"
// yields NSLogger for iOS version < 10.2 and OSLogger for 10.2 and above
let logger = ClientLoggers.default(tag: "StorageBlobClient")
let clientOptions = StorageBlobClientOptions(logger: logger)
let client = StorageBlobClient.from(connectionString: connectionString, withOptions: clientOptions)
```

## Next steps

### More sample code

Get started with our [examples](https://github.com/Azure/azure-sdk-for-ios/tree/master/examples/).

Storage Blobs Swift SDK samples are available to you in the SDK's GitHub repository. These samples provide example code for additional scenarios commonly encountered while working with Storage Blobs:

* [AzureSDKSwiftDemo](https://github.com/Azure/azure-sdk-for-ios/tree/master/examples/AzureSDKDemoSwift) - Example for common Storage Blob tasks:
    * List blobs in a container
    * Upload blobs
    * Download blobs

### Additional documentation
For more extensive documentation on Azure Blob storage, see the [Azure Blob storage documentation](https://docs.microsoft.com/azure/storage/blobs/) on docs.microsoft.com.

## Contributing
This project welcomes contributions and suggestions.  Most contributions require you to agree to a Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

![Impressions](https://azure-sdk-impressions.azurewebsites.net/api/impressions/azure-sdk-for-ios%2Fsdk%2Fstorage%2FAzureStorageBlob%2FREADME.png)
