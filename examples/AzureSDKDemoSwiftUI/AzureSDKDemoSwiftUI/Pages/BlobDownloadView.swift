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

final class BlobDownloadTableViewController: UIViewControllerRepresentable {
    typealias UIViewControllerType = UITableViewController
    var viewController: UITableViewController?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIViewController(context: Context) -> UITableViewController {
        let tableViewController = UITableViewController(style: .plain)
        tableViewController.tableView.delegate = context.coordinator
        tableViewController.tableView.dataSource = context.coordinator
                
        viewController = tableViewController
        return tableViewController
    }
    
    func updateUIViewController(_ uiViewController: UITableViewController,
                                context: Context) {
        uiViewController.tableView.reloadData()
    }
    
    class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate, MSALInteractiveDelegate {
        var parent: BlobDownloadTableViewController
        private var data = BlobListViewModel()

        init(_ tableViewController: BlobDownloadTableViewController) {
            parent = tableViewController
            
            PHPhotoLibrary.authorizationStatus()
        }
        
        func tableView(_ tableView: UITableView,
                       numberOfRowsInSection section: Int) -> Int {
            return data.items.count
        }
        
        func tableView(_ tableView: UITableView,
                       cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            return UITableViewCell()
        }
        
        func parentForWebView() -> UIViewController {
            guard let vc = parent.viewController else { return UIViewController() }
            
            return vc
        }
        
        func didCompleteMSALRequest(withResult result: MSALResult) {
            AppState.account = result.account
        }
        
        private func blobTableViewCell(_ indexPath: IndexPath,
                                       tableView: UITableView) -> UITableViewCell {
            let blobItem = data.items[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "BlobCell") ??
                UITableViewCell(style: .subtitle, reuseIdentifier: "BlobCell")
            
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.text = "\(blobItem.name)\n\(blobItem.properties?.blobType?.rawValue ?? "Unknown")"
            
            return cell
        }
    }
}
