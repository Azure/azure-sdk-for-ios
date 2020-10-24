# Azure Storage Blobs client library for iOS
Azure Blob storage is Microsoft's object storage solution for the cloud. Blob storage is optimized for storing massive amounts of unstructured data, such as text or binary data.

Blob storage is ideal for:

* Serving images or documents directly to a browser
* Storing files for distributed access
* Streaming video and audio
* Storing data for backup and restore, disaster recovery, and archiving
* Storing data for analysis by an on-premises or Azure-hosted service

[Source code](https://github.com/Azure/azure-sdk-for-ios/tree/master/sdk/storage/AzureStorageBlob)
| [API reference documentation]<!--(https://azure.github.io/azure-sdk-for-ios/AzureStorageBlob/index.html)-->
| [Product documentation](https://docs.microsoft.com/azure/storage/)
| [Samples](https://github.com/Azure/azure-sdk-for-ios/tree/master/examples/AzureSDKDemoSwift)


## Getting started
The basic outline of tasks needed to use the client library is as follows:
1. Ensure you've met the [prerequisites](#prerequisites).
2. [Install the library](#install-the-library) into your project.
3. Create an instance of the [client](#create-the-client).
4. If you'll be uploading or downloading blobs, start the [management engine](#managed-transfers).
5. Call the appropriate [client methods](#examples) to list containers, and list, download, and upload blobs.

### Prerequisites
* The client library is written in modern Swift 5. Due to this, Xcode 10.2 or higher is required to use this library.
* You must have an [Azure subscription](https://azure.microsoft.com/free/) and an
[Azure storage account](https://docs.microsoft.com/azure/storage/common/storage-account-overview) to use this library.

#### Create a storage account
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

If you plan to use the [Microsoft Authentication Library (MSAL) for iOS](https://aka.ms/aadv2) in your project, add it by
following the library's
[installation instructions](https://github.com/AzureAD/microsoft-authentication-library-for-objc#installation).

### Create the client
The Azure Storage Blobs client library for iOS allows you to interact with blob storage containers and blobs.
Interaction with these resources starts with an instance of a [client](#client).

To create a client object you will call the `StorageBlobClient` initializer, providing one or more of the following
parameters:
* A [credential](#authenticated-clients) that allows the client to access the storage account. You will need to provide
  a credential unless you're creating an [anonymous](#anonymous-clients) client.
* The [blob storage endpoint](#looking-up-the-endpoint-url) URL for the storage account. You will need to provide the
  endpoint URL if you're creating an [anonymous](#anonymous-clients) client or a client that uses the
  [Microsoft Authentication Library (MSAL) for iOS](#microsoft-authentication-library-msal-for-ios).
* A [restoration ID](#choosing-a-restoration-id) that associates the client instance with transfers that it creates. A
  restoration ID must always be provided.
* A [client options](#customizing-the-client) object to customize the behavior of the client. The client options object
  is always optional.

#### Types of clients
To interact with a storage account that permits anonymous read access, you can create an
[anonymous client](#anonymous-clients) that requires no credential.

When interacting with a storage account that doesn't permit anonymous read access, or to perform any write operations,
you'll need to create a client that is authenticated by one of the following credentials, depending on the type of
[authorization](https://docs.microsoft.com/azure/storage/common/storage-auth) you wish to use:

* [Shared Access Signature](#shared-access-signature)
* [Microsoft Authentication Library (MSAL) for iOS)](#microsoft-authentication-library-msal-for-ios)
* [Storage account shared access key](#storage-account-shared-access-key)

##### Anonymous clients
You can create an anonymous client by calling the `StorageBlobClient` initializer without providing a credential,
passing only the [blob storage endpoint](#looking-up-the-endpoint-url) for the storage account you wish to connect to
and a [restoration ID](#choosing-a-restoration-id). Anonymous clients can perform read-only operations on storage
accounts that permit anonymous read access:

```swift
import AzureStorageBlob

let endpointUrl = StorageBlobClient.endpoint(forAccount: "<my-storage-account-name>")
let client = try StorageBlobClient(endpoint: endpointUrl, withRestorationId: "MyAppClient")
```

##### Shared Access Signature
To use a [shared access signature (SAS) token](https://docs.microsoft.com/azure/storage/common/storage-sas-overview),
you'll create a `StorageSASCredential`. SAS tokens can be scoped to provide access to an entire storage account, a
single blob container, or even an individual blob, and contain an explicit grant of permissions and validity period.

You can generate a SAS token from the Azure Portal under "Settings" > "Shared access
signature" (account-scoped) or by right-clicking a blob within a container and selecting "Generate SAS" (blob-scoped).
You can also generate account-, container-, and blob-scoped SAS tokens using Azure Storage Explorer by right-clicking
the desired resource and selecting "Get Shared Access Signature...", or using the Azure CLI
([account](https://docs.microsoft.com/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-generate-sas),
[container](https://docs.microsoft.com/cli/azure/storage/container?view=azure-cli-latest#az-storage-container-generate-sas),
[blob](https://docs.microsoft.com/cli/azure/storage/blob?view=azure-cli-latest#az-storage-blob-generate-sas)).

Because SAS tokens can be limited in scope and permissions, `StorageSASCredential` is unique in that it is initialized
with a closure that will be called each time its `StorageBlobClient` needs a new token to authenticate a request. Within
the closure, you can inspect the URL that the client will be accessing, as well as the permissions requested for that
URL, and you must call the provided result handler with a valid token containing the necessary permissions to
authenticate the request.

To initialize a client instance that uses Shared Access Signature authentication, create an instance of
`StorageSASCredential` and provide a closure that will generate an appropriate SAS token for the URL and permissions
provided as parameters to the closure, and call the result handler with that token. Provide that credential and a
[restoration ID](#choosing-a-restoration-id) when initializing your `StorageBlobClient`:

```swift
import AzureStorageBlob

let sasCredential = StorageSASCredential { requestUrl, requiredPermissions, resultHandler in
    // Perform operations needed to generate a SAS token that can authenticate `requestUrl` and contains
    // `requiredPermissions`.
    let sasToken = ...

    // Call the result handler with the token if it was successfully generated, or an error otherwise.
    resultHandler(.success(sasToken))
}
let client = try StorageBlobClient(credential: sasCredential, withRestorationId: "MyAppClient")
```

If your authentication scenario is simple, a single static token may be sufficient to authenticate all requests that
your application may make. In this case, you can initialize a `StorageSASCredential` with the static token as a string
instead.

> **WARNING**: Static credentials are inherently insecure in end-user facing applications such as mobile and desktop
> apps. Static credentials should be treated as secrets and should not be shared with end users, and cannot be rotated
> once compiled into an application. Since mobile and desktop apps are inherently end-user facing, it's highly
> recommended that static credentials not be used in production for such applications.

To initialize a client instance with a static account-scoped SAS token, create an instance of `StorageSASCredential`
with the Shared Access Signature Connection String, and provide that credential and a
[restoration ID](#choosing-a-restoration-id) when initializing your `StorageBlobClient`:

```swift
import AzureStorageBlob

let sasConnectionString = "SharedAccessSignature=xxxx;BlobEndpoint=https://xxxx.blob.core.windows.net/;"
let sasCredential = StorageSASCredential(staticCredential: sasConnectionString)
let client = try StorageBlobClient(credential: sasCredential, withRestorationId: "MyAppClient")
```

When you create a Shared Access Signature that is scoped to a storage container or blob, it will be generated as a
Shared Access Signature URI, rather than a connection string. To initialize a client instance with a static container-
or blob-scoped SAS token, create an instance of `StorageSASCredential` with the Shared Access Signature URI, and provide
that credential and a [restoration ID](#choosing-a-restoration-id) when initializing your `StorageBlobClient`:

```swift
import AzureStorageBlob

let sasUri = "https://xxxx.blob.core.windows.net/container/path/to/blob?xxxx"
let sasCredential = StorageSASCredential(staticCredential: sasUri)
let client = try StorageBlobClient(credential: sasCredential, withRestorationId: "MyAppClient")
```

##### Microsoft Authentication Library (MSAL) for iOS
To use the
[Microsoft Authentication Library (MSAL) for iOS](https://github.com/AzureAD/microsoft-authentication-library-for-objc)
to authenticate your client, you'll need to provide your AAD tenant ID and your application's client ID, and you'll need
to use the MSAL for iOS library to authenticate the user and obtain instances of `MSALPublicClientApplication` and
`MSALAccount`. Refer to the
[AzureSDKSwiftDemo](https://github.com/Azure/azure-sdk-for-ios/tree/master/examples/AzureSDKDemoSwift)
sample for an example of how to use the MSAL for iOS library to authenticate a `StorageBlobClient`.

To initialize a client instance with an MSAL credential, create an instance of `MSALCredential` using your AAD tenant
ID, client ID, MSAL application object, and MSAL account object. Provide that credential, your account's blob storage
endpoint URL, and a [restoration ID](#choosing-a-restoration-id) when initializing your `StorageBlobClient`:

```swift
import AzureCore
import AzureStorageBlob
import MSAL

// Refer to the MSAL for iOS library documentation for information on how to
// initialize these values in your application
let application: MSALPublicClientApplication? = ...
let account: MSALAccount? = ...

let endpointUrl = StorageBlobClient.endpoint(forAccount: "<my-storage-account-name>")
let msalCredential = MSALCredential(
    tenant: "00112233-4455-6677-8899-aabbccddeeff",
    clientId: "00112233-4455-6677-8899-aabbccddeeff",
    application: msalApplication,
    account: msalAccount
)
let client = try StorageBlobClient(endpoint: endpointUrl, credential: msalCredential, withRestorationId: "MyAppClient")
```

##### Storage account shared access key
To use a [shared access key](https://docs.microsoft.com/rest/api/storageservices/authorize-with-shared-key),
you'll create a `StorageSharedKeyCredential` using the storage account connection string, or a combination of the
account name and access key. You can find the connection string and access keys for your storage account in the Azure
Portal under "Settings" > "Access keys", in Azure Storage Explorer located in the storage account's "Properties" pane,
or using the Azure CLI
([connection string](https://docs.microsoft.com/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-show-connection-string),
[access keys](https://docs.microsoft.com/cli/azure/storage/account/keys?view=azure-cli-latest#az-storage-account-keys-list)).

> **WARNING**: Shared keys are inherently insecure in end-user facing applications such as mobile and desktop apps.
> Shared keys provide full access to an entire storage account and should not be shared with end users. Since mobile and
> desktop applications are inherently end-user facing, it's highly recommended that `StorageSharedKeyCredential` not be
> used in production for such applications.

To initialize a client instance with a storage account connection string, create an instance of
`StorageSharedKeyCredential` with the connection string, and provide that credential and a
[restoration ID](#choosing-a-restoration-id) when initializing your `StorageBlobClient`:

```swift
import AzureStorageBlob

let connectionString = "DefaultEndpointsProtocol=https;AccountName=xxxx;AccountKey=xxxx;EndpointSuffix=core.windows.net"
let sharedKeyCredential = try StorageSharedKeyCredential(connectionString: sasConnectionString)
let client = try StorageBlobClient(credential: sharedKeyCredential, withRestorationId: "MyAppClient")
```

To initialize a client instance with a storage account name and access key, create an instance of
`StorageSharedKeyCredential` with the account name and access key, and provide that credential and a
[restoration ID](#choosing-a-restoration-id) when initializing your `StorageBlobClient`:

```swift
import AzureStorageBlob

let accountName = "<my-storage-account-name>"
let accessKey = "xxxx"
let sharedKeyCredential = try StorageSharedKeyCredential(accountName: accountName, accessKey: accessKey)
let client = try StorageBlobClient(credential: sharedKeyCredential, withRestorationId: "MyAppClient")
```

The `StorageSharedKeyCredential(accountName:accountKey:)` initializer accepts additional parameters if you need to
construct a shared access key credential that uses a different endpoint suffix or protocol, but most users should be
able to omit these parameters and use the defaults provided.

#### Looking up the endpoint URL
If you're creating an [anonymous client](#anonymous-clients) or a client that uses the
[Microsoft Authentication Library (MSAL) for iOS](#microsoft-authentication-library-msal-for-ios), you'll need to
provide the storage account's blob storage endpoint URL. You can find the blob storage endpoint URL using the
[Azure Portal](https://docs.microsoft.com/azure/storage/common/storage-account-overview#storage-account-endpoints),
[Azure PowerShell](https://docs.microsoft.com/powershell/module/az.storage/get-azstorageaccount),
or [Azure CLI](https://docs.microsoft.com/cli/azure/storage/account?view=azure-cli-latest#az-storage-account-show):

```bash
# Get the blob service account url for the storage account
az storage account show -n my-storage-account-name -g my-resource-group --query "primaryEndpoints.blob"
```

You can also easily create a blob storage endpoint URL from a given storage account name by using the static
`StorageBlobClient.endpoint(forAccount:)` method:

```swift
import AzureStorageBlob

let endpointUrl = StorageBlobClient.endpoint(forAccount: "<my-storage-account-name>")
```

The `endpoint(forAccount:)` method accepts additional parameters if you need to construct a blob storage endpoint URL
that uses a different endpoint suffix or protocol, but most users should be able to omit these parameters and use the
defaults provided.

#### Choosing a Restoration ID
When creating a client, you must provide a restoration ID. The restoration ID is a string identifier used to associate a
client instance with transfers it creates. To understand why the restoration ID is required, it is necessary to consider
how the client executes a blob upload or download.

When you call the client's [upload](#downloading-a-blob) or [download](#downloading-a-blob) methods, the client will
create and enqueue the transfer within its [transfer management engine](#managed-transfers), returning a `Transfer`
object. When your application exits with uncompleted transfers in the queue, the transfer management engine will
serialize them to disk and restore them the next time your application launches and starts the management engine.
However, because your application could contain multiple client instances with different credentials and configurations,
it's necessary to provide each client with a restoration ID so that when transfers are restored, they can be
re-associated with the correct client instance.

If your application only ever creates a single client, it's sufficient to simply choose a value unique to your
application (e.g. "MyApplication") as your restoration ID. Using a value unique to your application will ensure that the
transfer management engine can correctly re-associate transfers even if your application happens to include a
third-party dependency that also uses the AzureStorageBlob library. If your application creates multiple clients with
different configurations, use a value unique to both your application and the configuration (e.g.
"MyApplication.photosClient" or "MyApplication.backupClient"). Each client instance in your application needs to use a
unique restoration ID. If you attempt to create more than one client with the same restoration ID, an error will be
thrown.

#### Customizing the client
When creating a client, you may choose to provide an optional
[StorageBlobClientOptions](https://github.com/Azure/azure-sdk-for-ios/blob/master/sdk/storage/AzureStorageBlob/Source/Options/ClientOptions.swift)
object in order to configure the client as desired. You may instruct the client to use a specific API version of the
Azure Storage Blob service, change when and how log messages are emitted from the client, and control the chunk size
used when uploading and downloading blobs - the maximum size of each piece when the client breaks an upload or download
operation into multiple pieces.

### Managed transfers
When you use a client's [upload](#downloading-a-blob) or [download](#downloading-a-blob) methods to transfer a blob to
or from the device, the client will perform the operation as a *managed transfer*. During a managed transfer, the
library's transfer management engine will ensure that the transfer is performed reliably in the face of changing network
conditions, pausing transfers when network connectivity is lost and resuming them when connectivity is restored. Managed
transfers can also be paused, resumed, or canceled by the developer at any time. Any managed transfers which have not
been completed when the hosting application terminates are persisted to disk and can be restarted on a subsequent
application launch.

#### Starting managed transfers
When your application first launches, the library's transfer management engine is stopped. Calling `download` or
`upload` from a client will queue those transfers, but they won't begin until the management engine is started by
calling the `StorageBlobClient.startManaging()` method. When you start the transfer management engine, the state of
transfers is loaded from disk, the management engine begins listening for network connectivity events, and any
incomplete transfers are resumed.

It's recommended to call the `startManaging()` method from a background thread, at an opportune time after your app has
started. In many applications, calling this method in the `AppDelegate` or from within a `ViewController`'s lifecycle
methods is sufficient. However, depending on the type of credential used to authenticate the client, resuming a transfer
could cause a login UI to be displayed if the access token for the transfer has expired. If you're using such a
credential (e.g. `MSALCredential`) you should instead first inspect the list of transfers to determine if any are
pending. If so, you should assume that calling `startManaging()` method may display a login UI, and call it in a
user-appropriate context (e.g. display a "pending transfers" message and wait for explicit user confirmation to start
the management engine).

```swift
import AzureStorageBlob
import UIKit

class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        StorageBlobClient.startManaging()
    }
}
```

As transfers progress, the client will periodically snapshot their state to disk. However, to ensure that all progress
is saved and resources are released when your app shuts down or when your `ViewController` goes away, the
`StorageBlobClient.stopManaging()` method exists to safely stop the transfer management engine. When you stop the
transfer management engine, any incomplete transfers are paused, the management engine stops listening for network
connectivity events, and the state of transfers is stored to disk. Most applications should call this method in the
`AppDelegate` or from within a `ViewController`'s lifecycle methods.

```swift
import AzureStorageBlob
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func applicationWillTerminate(_: UIApplication) {
        StorageBlobClient.stopManaging()
    }
}
```

#### Tracking progress of managed transfers
Managed transfers emit events as they are executed by the transfer management engine. You can use these events to
understand when transfers start, make progress, and complete or fail. The transfer management engine routes relevant
events through to the client instance that initiated the transfer. To be informed about events from transfers created by
your client, attach a `TransferDelegate` to it.

```swift
import AzureStorageBlob
import UIKit

class MyViewController: UIViewController {
    private var client: StorageBlobClient

    ...

    client.transferDelegate = self
}

extension MyViewController: TransferDelegate {
    public func transfer(_ transfer: Transfer, didUpdateWithState state: TransferState, andProgress progress: Float?) {
        ...
    }

    public func transfersDidUpdate(_ transfers: [Transfer]) {
        ...
    }

    public func transfer(_ transfer: Transfer, didFailWithError error: Error) {
        ...
    }

    public func transferDidComplete(_ transfer: Transfer) {
        ...
    }
}
```

#### Looking up and manipulating transfers
All managed transfers created by a client are stored within a `TransferCollection` object held by the client that
created them. You can access this collection using the client's `transfers` property. The client also provides
convenient `downloads` and `uploads` properties which expose pre-filtered subsets of `transfers`.

A `TransferCollection` allows you to easily select one or more transfers that match supplied criteria pertaining to the
transfer using the `firstWith` and `filterWhere` methods. A single transfer within the `TransferCollection` can be
accessed by its `id` using subscript syntax, whereas the contents of the `TransferCollection` can be accessed as a Swift
`Collection` via the `items` property, allowing you to use all of the operations that the `Collection` protocol declares
and implements. 

A `TransferCollection` also contains methods that allow you to easily manipulate all transfers it contains. You can
pause, resume, or cancel all transfers within a `TransferCollection` by calling the `pauseAll`, `resumeAll`, or
`cancelAll` methods.

```swift
import AzureStorageBlob

let client = try StorageBlobClient(...)
try client.download(...)

// Cancel a download by its ID if it exists
client.downloads["00112233-4455-6677-8899-aabbccddeeff"]?.cancel()

// Pause all downloads from a given container
client.downloads
      .filterWhere(containerName: "<my_container>")
      .pauseAll()

// Resume a specific download if it exists
client.downloads
      .firstWith(containerName: "<my_container>", blobName: "<my_blob>")?
      .resume()

client.downloads.items.filter()
```

#### Parallel execution of transfers
The transfer management engine breaks each transfer into a sequence of chunks and transfers multiple chunks in parallel
in order to make more efficient use of available network bandwidth. The chunk size is configurable for each client by
specifying the desired chunk size in the [client options object](#customizing-the-client). The degree of parallelism is
a global value and can also be configured by the developer:

```swift
import AzureStorageBlob

// Only execute one transfer at a time, effectively disabling parallelism
StorageBlobClient.maxConcurrentTransfers = 1

// Execute 4 transfers in parallel
StorageBlobClient.maxConcurrentTransfers = 4

// Allow the maximum number of parallel transfers to be determined dynamically based on current system conditions.
StorageBlobClient.maxConcurrentTransfers = StorageBlobClient.maxConcurrentTransfersDynamicValue

// Restore the default value
StorageBlobClient.maxConcurrentTransfers = StorageBlobClient.maxConcurrentTransfersDefaultValue
```

## Key concepts
The following components make up the Azure Blob Service:
* The storage account itself
* A container within the storage account
* A blob within a container

The Azure Storage Blobs client library for iOS allows you to interact with some of these components through the `AzureStorageBlob` client.

### Client
A single client is provided to interact with the various components of the Blob Service:
1. [StorageBlobClient](https://github.com/Azure/azure-sdk-for-ios/blob/master/sdk/storage/AzureStorageBlob/Source/StorageBlobClient.swift) -
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
List the blobs asynchronously in your container:

```swift
import AzureStorageBlob

let sasConnectionString = "SharedAccessSignature=xxxx;BlobEndpoint=https://xxxx.blob.core.windows.net/;"
let sasCredential = try StorageSASCredential(connectionString: sasConnectionString)
let client = try StorageBlobClient(credential: sasCredential, withRestorationId: "MyAppClient")

let containerName = "<my_container>"
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
Upload a blob asynchronously from the app's documents directory to your container:

```swift
import AzureStorageBlob

let sasConnectionString = "SharedAccessSignature=xxxx;BlobEndpoint=https://xxxx.blob.core.windows.net/;"
let sasCredential = try StorageSASCredential(connectionString: sasConnectionString)
let client = try StorageBlobClient(credential: sasCredential, withRestorationId: "MyAppClient")

let containerName = "<my_container>"
let blobName = "<my_blob>"
let sourceUrl = LocalURL(fromDirectory: .documentDirectory).appendingPathComponent("<my_jpg_file>")
let properties = BlobProperties(
    contentType: "image/jpg"
)
let transfer = try client.upload(
    file: sourceUrl,
    toContainer: containerName,
    asBlob: blobName,
    properties: properties
)
```

### Downloading a blob
Download a blob asynchronously from your container to the app's cache directory, creating intermediate directories for
the container and the path portion of the blob name:

```swift
import AzureStorageBlob

let sasConnectionString = "SharedAccessSignature=xxxx;BlobEndpoint=https://xxxx.blob.core.windows.net/;"
let sasCredential = try StorageSASCredential(connectionString: sasConnectionString)
let client = try StorageBlobClient(credential: sasCredential, withRestorationId: "MyAppClient")

let containerName = "<my_container>"
let blobName = "<my_blob>"
let destinationUrl = LocalURL(inDirectory: .cachesDirectory, forBlob: blobName, inContainer: containerName)
let transfer = try client.download(
    blob: blobName,
    fromContainer: containerName,
    toFile: destinationUrl
)
```

## Troubleshooting
### General
Storage Blob clients raise exceptions defined in
[Azure Core](https://github.com/Azure/azure-sdk-for-ios/blob/master/sdk/core/AzureCore/Source/Errors.swift).

### Logging
This library uses the
[ClientLogger](https://github.com/Azure/azure-sdk-for-ios/blob/master/sdk/core/AzureCore/Source/ClientLogger.swift)
protocol for logging. The desired style of logger can be set when initializing the client:

```swift
import AzureCore
import AzureStorageBlob

let sasConnectionString = "SharedAccessSignature=xxxx;BlobEndpoint=https://xxxx.blob.core.windows.net/;"
let sasCredential = try StorageSASCredential(connectionString: sasConnectionString)

let logger = NSLogger(tag: "MyAppClient", level: .debug)

let clientOptions = StorageBlobClientOptions(logger: logger)
let client = try StorageBlobClient(credential: sasCredential, withRestorationId: "MyAppClient", withOptions: clientOptions)
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

let sasConnectionString = "SharedAccessSignature=xxxx;BlobEndpoint=https://xxxx.blob.core.windows.net/;"
let sasCredential = try StorageSASCredential(connectionString: sasConnectionString)

// Returns an `NSLogger` for iOS version < 10.2 and an `OSLogger` for 10.2 and above.
let logger = ClientLoggers.default(tag: "MyAppClient")

let clientOptions = StorageBlobClientOptions(logger: logger)
let client = try StorageBlobClient(credential: sasCredential, withRestorationId: "MyAppClient", withOptions: clientOptions)
```

You can adjust the log level of a logger after creating it. Changes to the log level are immediate:

```swift
import AzureCore
import AzureStorageBlob

let sasConnectionString = "SharedAccessSignature=xxxx;BlobEndpoint=https://xxxx.blob.core.windows.net/;"
let sasCredential = try StorageSASCredential(connectionString: sasConnectionString)

// The default log level is `info`.
let logger = ClientLoggers.default(tag: "MyAppClient")

let clientOptions = StorageBlobClientOptions(logger: logger)
let client = try StorageBlobClient(credential: sasCredential, withRestorationId: "MyAppClient", withOptions: clientOptions)

// The operation runs with logging at `info` level.
client.listBlobs(...)

logger.level = .debug

// The operation runs with logging at `debug` level.
client.listBlobs(...)
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
