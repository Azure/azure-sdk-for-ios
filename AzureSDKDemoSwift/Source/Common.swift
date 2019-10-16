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

import AzureStorageBlob
import Foundation

struct AppConstants {
    // read-only connection string
    static let appConfigConnectionString = "Endpoint=https://tjpappconfig.azconfig.io;Id=2-l0-s0:zSvXZtO9L9bv9s3QVyD3;Secret=FzxmbflLwAt5+2TUbnSIsAuATyY00L+GFpuxuJZRmzI="

    // read-only blob connection string using a SAS token
    static let blobConnectionString = "BlobEndpoint=https://tjpstorage1.blob.core.windows.net/;QueueEndpoint=https://tjpstorage1.queue.core.windows.net/;FileEndpoint=https://tjpstorage1.file.core.windows.net/;TableEndpoint=https://tjpstorage1.table.core.windows.net/;SharedAccessSignature=sv=2018-03-28&ss=b&srt=sco&sp=rl&se=2020-10-03T07:45:02Z&st=2019-10-02T23:45:02Z&spr=https&sig=L7zqOTStAd2o3Mp72MW59GXM1WbL9G2FhOSXHpgrBCE%3D"
    static let storageAccountName = "tjpstorage1"
    static let storageBaseUrl = "https://tjpstorage1.blob.core.windows.net"
}

func getBlobClient() -> StorageBlobClient? {
    let storageAccountName = AppConstants.storageAccountName
    let blobConnectionString = AppConstants.blobConnectionString

    return try? StorageBlobClient(accountName: storageAccountName,
                                  connectionString: blobConnectionString)
}
