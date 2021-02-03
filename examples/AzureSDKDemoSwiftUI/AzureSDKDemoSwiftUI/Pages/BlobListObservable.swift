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

import Foundation

import AzureCore
import AzureIdentity
import AzureStorageBlob
import MSAL

class BlobListViewModel {
    private(set) var blobClient: StorageBlobClient?
    private(set) var tableViewController: BlobDownloadTableViewController?
    var collection: PagedCollection<BlobItem>?
    var items = [BlobItem]()
    var transfers = [String: BlobTransfer]()

    init(_ tableViewController: BlobDownloadTableViewController) {
        self.tableViewController = tableViewController
        loadBlobData()
    }

    func loadBlobData() {
        blobClient = try? AppState.blobClient()
        
        guard let blobClient = blobClient else { return }
        let containerName = AppConstants.videoContainer 
        let options = ListBlobsOptions(maxResults: 20)
        
        blobClient.listBlobs(inContainer: containerName, withOptions: options) { result, _ in
            switch result {
            case let .success(collection):
                self.collection = collection
                self.items = collection.items ?? [BlobItem]()
                self.updateTransfers(using: self.items)
                self.tableViewController?.viewController?.tableView.reloadData()
                
            case .failure:
                // show an error here
                break
            }
        }
        
        blobClient.downloads.resumeAll(progressHandler: downloadProgress)
    }
    
    func startDownload(blobItem: BlobItem, blobClient: StorageBlobClient) {
        let container = AppConstants.videoContainer
        let localUrl = LocalURL(inDirectory: .cachesDirectory,
                                forBlob: blobItem.name,
                                inContainer: container)
                
        do {
            let transfer = try blobClient.download(blob: blobItem.name,
                                                   fromContainer: container,
                                                   toFile: localUrl,
                                                   withOptions: AppState.downloadOptions,
                                                   progressHandler: downloadProgress)
            
            transfers[blobItem.name] = transfer
            self.tableViewController?.viewController?.tableView.reloadData()
        } catch {
            // Throw an error
        }
    }
    
    private func updateTransfers(using items: [BlobItem]) {
        blobClient = try? AppState.blobClient()
        
        guard let blobClient = blobClient else { return }
        let containerName = AppConstants.videoContainer
        
        for item in items {
            if let existingTransfer = blobClient.downloads.firstWith(containerName: containerName,
                                                                     blobName: item.name) {
                transfers[item.name] = existingTransfer
            }
        }
    }
    
    private func downloadProgress(transfer: BlobTransfer) {
        guard transfer.state != .failed else {
            // show an error here
            return
        }

        if transfer.transferType == .download {
            self.tableViewController?.viewController?.tableView.reloadData()
        }
    }
}
