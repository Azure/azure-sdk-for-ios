# Sample: Azure Function for generating Blob Storage SAS tokens

This example will show you how to create an Azure Function that can generate
short-lived Blob Storage Shared Access Signature (SAS) tokens that are scoped to
a per-client path prefix within a Storage Container.

## Features

This project provides examples for the following scenarios:

* Using the
  [Azure Functions Python Runtime](https://docs.microsoft.com/azure/azure-functions/functions-create-first-azure-function-azure-cli?pivots=programming-language-python)
  to host an API endpoint which generates scoped Blob Storage SAS tokens for
  client applications.

* Using the
  [Azure Storage Blobs client library for iOS](https://github.com/Azure/azure-sdk-for-ios/tree/master/sdk/storage/AzureStorageBlob)
  to access Azure Blob Storage with a
  [StorageSASCredential](https://github.com/Azure/azure-sdk-for-ios/blob/master/sdk/storage/AzureStorageBlob/Source/Credentials/StorageSASCredential.swift).

## Getting started

### Prerequisites
* You must have the
  [Azure Functions Core Tools version 3.x](https://docs.microsoft.com/azure/azure-functions/functions-run-local#v2) installed to run this example. 
* This example is written in Python. Because version 3.x of the Azure Functions
  Core Runtime supports Python 3.8+ only, you must have
  [Python 3.8](https://www.python.org/downloads/) or higher installed to run
  this example.
* You must have an [Azure subscription](https://azure.microsoft.com/free/),
  an active
  [storage account](https://docs.microsoft.com/azure/storage/common/storage-account-create),
  and a [blob container](https://docs.microsoft.com/azure/storage/blobs/storage-quickstart-blobs-portal#create-a-container)
  within that storage account to run this example.

### Installation

1. If you don't already have it,
   [install Python](https://www.python.org/downloads/) and the
   [Azure Functions Core Tools](https://docs.microsoft.com/azure/azure-functions/functions-run-local#v2).
   This example is compatible with Python 3.8 and higher and Azure Functions
   Core Tools 3.x.

2. A general recommendation for Python development is to use a Virtual
   Environment. For more information, see https://docs.python.org/3/tutorial/venv.html
   
   Install and initialize the virtual environment with the "venv" module:
   ```bash
   python3 -m venv .venv        # Might be "python" or "py -3.8" depending on your Python installation
   source .venv/bin/activate    # Linux shell (Bash, ZSH, etc.) only
   ./.venv/scripts/activate     # PowerShell only
   ./.venv/scripts/activate.bat # Windows CMD only
   ```

### Quickstart

1. Clone the repository.
   ```bash
   git clone https://github.com/Azure/azure-sdk-for-ios.git
   ```

2. Install the project dependencies with `pip`:
   ```bash
   cd examples/AzureFunctionSASTokenVendor
   python3 -m pip install -r requirements.txt
   ```

3. Edit the [`https://github.com/Azure/azure-sdk-for-ios/blob/master/examples/AzureFunctionSASTokenVendor/local.settings.json`](https://github.com/Azure/azure-sdk-for-ios/blob/master/examples/AzureFunctionSASTokenVendor/local.settings.json) file to include your
   storage account name,
   [storage account access key](https://docs.microsoft.com/azure/storage/common/storage-account-keys-manage#view-account-access-keys),
   and blob container name:
   ```json
   {
     "IsEncrypted": false,
     "Values": {
       "AzureWebJobsStorage": "",
       "FUNCTIONS_WORKER_RUNTIME": "python",
       "AZURE_STORAGE_ACCOUNT_NAME": "<my_storage_account>",
       "AZURE_STORAGE_ACCOUNT_KEY": "<my_storage_account_key>",
       "AZURE_STORAGE_CONTAINER_NAME": "<my_storage_container>"
     }
   }
   ```

## Examples

### Azure Function for generating Blob Storage SAS tokens

Run the function by starting the local Azure Functions runtime host:
```bash
func start
```

Toward the end of the output, the following lines should appear:
```
...

Now listening on: http://0.0.0.0:7071
Application started. Press Ctrl+C to shut down.

Http Functions:

        GetSasToken: [GET] http://localhost:7071/api/GetSasToken
...
```

Copy the URL of the `GetSasToken` function from this output to a browser and
append the query string
`?client_id=<any-value>&container=<container-name>&path=<client-id>/<any-path>`,
making the full URL like
`http://localhost:7071/api/GetSasToken?client_id=123456&container=mycontainer&path=123456/example.txt`.
The browser should display JSON output containing the full path to the desired
blob in your blob storage container and a SAS token which can be used to
authenticate a PUT request (upload) to that path:

```json
{
  "destination": "https://mystorageaccount.blob.core.windows.net/mycontainer/123456/example.txt",
  "token": "<some-token>",
  "valid_from": "2020-07-16T03:34:52+00:00",
  "valid_to": "2020-07-16T04:34:52+00:00"
}
```

### Authenticating a StorageBlobClient with a StorageSASCredential

Deploy the example function to Azure following the
[Quickstart guide](https://docs.microsoft.com/azure/azure-functions/functions-create-first-azure-function-azure-cli?pivots=programming-language-python#create-supporting-azure-resources-for-your-function).

The publish command shows results similar to the following output (truncated for simplicity):
```
...

Getting site publishing info...
Creating archive for current directory...
Performing remote build for functions project.

...

Deployment successful.
Remote build succeeded!
Syncing triggers...
Functions in exampleapp:
    GetSasToken - [httpTrigger]
        Invoke url: https://exampleapp.azurewebsites.net/api/GetSasToken?code=<function-access-code>

```

Copy the complete **Invoke URL** shown in the output of the publish command.

In your application, create an instance of `StorageSASCredential`. In the
configuration closure, make a GET request to the function's Invoke URL, passing
in a unique Client ID, container name, and requested blob path in the query
string. When the request completes, extract the SAS token from the response and
call the `SASTokenResultHandler` with the token, or with the error if the
process failed. Finally, provide that credential and your storage account's
blob storage endpoint when initializing a `StorageBlobClient`:

```swift
import AzureStorageBlob

struct GetSasTokenResponse: Codable {
    var destination: String
    var token: String
    var validFrom: Date
    var validTo: Date
}

enum ExampleError: Error {
    case general(String)
}

...

let clientId = "123456"
let functionAccessCode = "VG9vIGVhc3ksIG5pY2UgdHJ5IQ=="
let blobEndpoint = URL(string: "https://mystorageaccount.blob.core.windows.net/")!

let sasCredential = StorageSASCredential { requestUrl, _, resultHandler in
    let pathParts = requestUrl.path.split(separator: "/", maxSplits: 1)
    let container = pathParts[0], blob = pathParts[1]
    let getTokenUrl = URL(string: "https://exampleapp.azurewebsites.net/api/GetSasToken?code=\(functionAccessCode)&client_id=\(clientId)&container=\(container)&path=\(blob)")!
    let task = URLSession.shared.dataTask(with: getTokenUrl) { data, _, error in
        if let error = error {
            resultHandler(.failure(error))
            return
        }
        guard let data = data else {
            resultHandler(.failure(ExampleError.general("Failed to receive data from the Azure Function.")))
            return
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            let tokenResponse = try decoder.decode(GetSasTokenResponse.self, from: data)
            let sasUri = "\(tokenResponse.destination)?\(tokenResponse.token)"
            resultHandler(.success(sasUri))
        } catch {
            resultHandler(.failure(error))
        }
    }
    task.resume()
}

let client = try StorageBlobClient(credential: sasCredential, endpoint: blobEndpoint)
```

![Impressions](https://azure-sdk-impressions.azurewebsites.net/api/impressions/azure-sdk-for-ios%2Fexamples%2FAzureFunctionSASTokenVendor%2FREADME.png)
