// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import AzureCore
import AzureIdentity
import AzureStorageBlob
import Foundation
import MSAL

struct AppConstants {
    static let storageAccountUrl = URL(string: "https://iosdemostorage1.blob.core.windows.net/")!
    static let tenant = "7e6c9611-413e-47e4-a054-a389854dd732"
    static let clientId = "6f2c62dd-d6b2-444a-8dff-c64380e7ac76"
    static let redirectUri = "msauth.com.azure.examples.AzureSDKDemoSwift://auth"
    static let authority = "https://login.microsoftonline.com/7e6c9611-413e-47e4-a054-a389854dd732"
    static let uploadContainer: String! = "uploads"
    static let videoContainer: String = "videos"
    
// NOTE: This connection string is a read-only SAS token, may need to be regenerated. Expires end of Aug
    // swiftlint:disable line_length
    static let sasConnectionString =
        "BlobEndpoint=https://iosdemostorage1.blob.core.windows.net/;QueueEndpoint=https://iosdemostorage1.queue.core.windows.net/;FileEndpoint=https://iosdemostorage1.file.core.windows.net/;TableEndpoint=https://iosdemostorage1.table.core.windows.net/;SharedAccessSignature=sv=2019-12-12&ss=bfqt&srt=co&sp=rl&se=2021-08-30T07:04:27Z&st=2021-01-30T00:04:27Z&spr=https&sig=no%2BHSwTVjheowEdMSJ0iI6NdWvPXZ51n99PJG91O0ko%3D"
}

struct AppState {
    static var application: MSALPublicClientApplication?

    static var account: MSALAccount?

    static let scopes = [
        "https://storage.azure.com/.default"
    ]

    static var currentAccount: MSALAccount? {
        if let account = AppState.account {
            return account
        }
        guard let application = AppState.application else { return nil }
        // We retrieve our current account by getting the first account from cache
        // In multi-account applications, account should be retrieved by home account identifier or username instead
        do {
            let cachedAccounts = try application.allAccounts()

            if !cachedAccounts.isEmpty {
                return cachedAccounts.first
            }
        } catch let error as NSError {
            print("Didn't find any accounts in cache: \(error)")
        }
        return nil
    }

    static var downloadOptions: DownloadBlobOptions {
        let options = DownloadBlobOptions(
            range: RangeOptions(calculateMD5: true)
        )
        return options
    }

    private static var internalBlobClient: StorageBlobClient?
    static func blobClient(withDelegate delegate: StorageBlobClientDelegate? = nil) throws -> StorageBlobClient {
        let error = AzureError.client("Unable to create Blob Storage Client.")
        if AppState.internalBlobClient == nil {
            guard let _ = AppState.application else {
                fatalError("Application is not initialized. Unable to create Blob Storage Client.")
            }
            
            let credential = StorageSASCredential(staticCredential: AppConstants.sasConnectionString)
            AppState.internalBlobClient = try? StorageBlobClient(
                endpoint: URL(string: "https://iosdemostorage1.blob.core.windows.net/")!,
                credential: credential)
        }
        
        guard AppState.internalBlobClient != nil else {
            throw error
        }

        let client = AppState.internalBlobClient!
        client.delegate = delegate
        StorageBlobClient.maxConcurrentTransfers = 4
        return client
    }
}
