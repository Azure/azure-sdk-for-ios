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

import SwiftUI
import UIKit

import AzureCore
import AzureIdentity
import AzureStorageBlob
import MSAL
import Photos

final class BlobDownloadTableViewController: UIViewControllerRepresentable, MSALInteractiveDelegate {
    var viewController: UITableViewController?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UITableViewController {
        let tableViewController = UITableViewController(style: .grouped)
        tableViewController.tableView.delegate = context.coordinator
        tableViewController.tableView.dataSource = context.coordinator
                
        viewController = tableViewController
        return tableViewController
    }
    
    func updateUIViewController(_ uiViewController: UITableViewController,
                                context: Context) {
        uiViewController.tableView.reloadData()
    }
    
    func parentForWebView() -> UIViewController {
        return viewController ?? UITableViewController()
    }
    
    func didCompleteMSALRequest(withResult result: MSALResult) {
        AppState.account = result.account
    }

    
    class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        var parent: BlobDownloadTableViewController
        private var data: BlobListViewModel

        init(_ tableViewController: BlobDownloadTableViewController) {
            parent = tableViewController
            data = BlobListViewModel(parent)
            
            PHPhotoLibrary.authorizationStatus()
        }
        
        func tableView(_ tableView: UITableView,
                       numberOfRowsInSection section: Int) -> Int {
            return data.items.count
        }
        
        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return blobTableViewCell(indexPath, tableView: parent.viewController?.tableView)
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let blobClient = try? AppState.blobClient() else { return }
            let container = AppConstants.videoContainer
            let blobItem = data.items[indexPath.row]
            
            do {
                let localUrl = LocalURL(inDirectory: .cachesDirectory,
                                        forBlob: blobItem.name,
                                        inContainer: container)
                let transfer = try blobClient.download(blob: blobItem.name, fromContainer: container, toFile: localUrl) as? BlobTransfer
                
            } catch {
                // Show error
            }
        }
        
        private func blobTableViewCell(_ indexPath: IndexPath,
                                       tableView: UITableView?) -> UITableViewCell {
            guard let tableView = tableView else { return UITableViewCell() }
            
            let blobItem = data.items[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "BlobCell") ??
                UITableViewCell(style: .subtitle, reuseIdentifier: "BlobCell")
            
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "\(blobItem.name)\n\(blobItem.properties?.blobType?.rawValue ?? "Unknown")"
            
            if indexPath.row == data.items.count - 1 {
                loadMoreSettings()
            }
            
            return cell
        }
                
        private func loadMoreSettings() {
            guard !(data.collection?.isExhausted ?? true) else { return }
            
            data.collection?.nextPage { result in
                switch result {
                case .success:
                    self.parent.viewController?.tableView.reloadData()
                case .failure:
                    // show an alert
                    break
                }
            }
        }
    }
}
