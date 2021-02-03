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

import AVKit
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
            tableView.deselectRow(at: indexPath, animated: true)
            
            guard let blobClient = try? AppState.blobClient() else { return }
            let blobItem = data.items[indexPath.row]
            
            if let existingTransfer = blobClient.downloads.firstWith(containerName: AppConstants.videoContainer,
                                                                     blobName: blobItem.name) {
                switch existingTransfer.state {
                case .complete:
                    // Play video
                    guard let destinationUrl = existingTransfer.destinationUrl else { return }
                    playVideo(from: destinationUrl)
                case .paused, .failed:
                    existingTransfer.resume()
                case .inProgress, .pending:
                    existingTransfer.pause()
                default:
                    existingTransfer.cancel()
                }
            } else {
                data.startDownload(blobItem: blobItem, blobClient: blobClient)
            }
        }
        
        private func blobTableViewCell(_ indexPath: IndexPath,
                                       tableView: UITableView?) -> UITableViewCell {
            guard let tableView = tableView else { return UITableViewCell() }
            
            let blobItem = data.items[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "BlobCell") ??
                UITableViewCell(style: .subtitle, reuseIdentifier: "BlobCell")
            
            cell.textLabel?.numberOfLines = 0

            if let transfer = data.transfers[blobItem.name] {
                cell.textLabel?.text = getCellText(for: blobItem, transfer: transfer)
            } else {
                cell.textLabel?.text = getCellText(for: blobItem)
            }
                        
            return cell
        }
         
        private func getCellText(for blobItem: BlobItem, transfer: BlobTransfer? = nil) -> String {
            if let transfer = transfer {
                let percent = transfer.progress.asPercent
                return "\(blobItem.name) \n State \(transfer.state.label) Progress \(percent)"
            } else {
                return "\(blobItem.name)"
            }
        }
        
        private func playVideo(from source: URL) {
            let player = AVPlayer()
            player.replaceCurrentItem(with: AVPlayerItem(asset: AVAsset(url: source)))
            let controller = AVPlayerViewController()
            controller.player = player
            parent.viewController?.present(controller, animated: true, completion: {})
        }
    }
}
