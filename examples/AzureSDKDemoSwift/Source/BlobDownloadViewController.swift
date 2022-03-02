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
import MSAL
import os.log
import Photos

import AVFoundation
import AVKit
import UIKit

class BlobDownloadViewController: UIViewController, MSALInteractiveDelegate {
    private var dataSource: PagedCollection<BlobItem>?

    @IBOutlet var tableView: UITableView!

    private lazy var player = AVPlayer()
    private var blobClient: StorageBlobClient?

    // MARK: Internal Methods

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        blobClient = try? AppState.blobClient()
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Data ...", attributes: nil)
        refreshControl.addTarget(self, action: #selector(fetchData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PHPhotoLibrary.authorizationStatus()
        fetchData(self)
        guard let blobClient = blobClient else { return }
        blobClient.downloads.resumeAll(progressHandler: downloadProgress)
    }

    // MARK: Private Methods

    /// Constructs the PagedCollection and retrieves the first page of results to initalize the table view.
    @objc private func fetchData(_: Any) {
        guard let containerName = AppConstants.videoContainer else { return }
        guard let blobClient = blobClient else { return }
        let options = ListBlobsOptions(maxResults: 20)
        if !(tableView.refreshControl?.isRefreshing ?? false) {
            tableView.refreshControl?.beginRefreshing()
        }
        blobClient.blobs.list(inContainer: containerName, withOptions: options) { result, _ in
            self.tableView.refreshControl?.endRefreshing()
            switch result {
            case let .success(paged):
                self.dataSource = paged
                self.tableView.reloadData()
            case let .failure(error):
                self.showAlert(error: error)
            }
        }
    }

    /// Uses asynchronous "nextPage" method to fetch the next page of results and update the table view.
    private func loadMoreSettings() {
        guard !(dataSource?.isExhausted ?? true) else { return }
        dataSource?.nextPage { result in
            switch result {
            case .success:
                self.tableView.reloadData()
            case let .failure(error):
                self.showAlert(error: error)
            }
        }
    }

    // MARK: Internal Methods

    internal func playVideo(_ destination: URL) {
        player.replaceCurrentItem(with: AVPlayerItem(asset: AVAsset(url: destination)))
        let controller = AVPlayerViewController()
        controller.player = player
        present(controller, animated: true) {
            self.player.play()
        }
    }

    // MARK: MSALInteractiveDelegate

    func didCompleteMSALRequest(withResult result: MSALResult) {
        AppState.account = result.account
    }

    func parentForWebView() -> UIViewController {
        return self
    }
}

extension BlobDownloadViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source

    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        guard let data = dataSource?.items else { return 0 }
        return data.count
    }

    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "CustomTableViewCell"
        guard let blobClient = blobClient,
              let data = dataSource?.items,
              let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
              as? CustomTableViewCell
        else {
            fatalError("Preconditions to create CustomTableViewCell not met.")
        }
        // configure the cell
        let blobItem = data[indexPath.row]
        let blobName = blobItem.name

        cell.keyLabel.text = blobItem.name
        cell.valueLabel.text = "???"
        if let blobType = blobItem.properties?.blobType {
            cell.valueLabel.text = blobType.rawValue
        }
        cell.backgroundColor = .white

        // Match any blobs to existing transfers.
        // Update background color and progress.
        if let transfer = blobClient.downloads.firstWith(
            containerName: AppConstants.videoContainer,
            blobName: blobName
        ) {
            cell.backgroundColor = transfer.state.color
            cell.progressBar.progress = transfer.progress.asFloat
        }

        // load next page if at the end of the current list
        if indexPath.row == data.count - 1 {
            loadMoreSettings()
        }
        return cell
    }

    func downloadProgress(transfer: BlobTransfer) {
        guard transfer.state != .failed else {
            showAlert(error: transfer.error)
            tableView.reloadData()
            return
        }

        if transfer.transferType == .download {
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell else { return }
        guard let blobName = cell.keyLabel.text else { return }
        guard let containerName = AppConstants.videoContainer else { return }
        guard let blobClient = blobClient else { return }
        let destination = LocalURL(inDirectory: .cachesDirectory, forBlob: blobName, inContainer: containerName)

        let manager = FileManager.default

        if let existingTransfer = blobClient.downloads.firstWith(
            containerName: AppConstants.videoContainer,
            blobName: blobName
        ) {
            guard let destinationUrl = existingTransfer.destinationUrl else { return }

            switch existingTransfer.state {
            case .complete:
                guard manager.fileExists(atPath: destinationUrl.path) else { return }
                playVideo(destinationUrl)
            case .paused, .failed:
                existingTransfer.resume()
            case .inProgress, .pending:
                existingTransfer.pause()
            default:
                break
            }
        } else if let destinationUrl = destination.resolvedUrl, manager.fileExists(atPath: destinationUrl.path) {
            // if no transfer exists but a file exists, play
            playVideo(destinationUrl)
            return
        }

        // Otherwise, start the download with TransferManager.
        let options = AppState.downloadOptions
        do {
            try blobClient.blobs.download(
                blob: blobName,
                fromContainer: containerName,
                toFile: destination,
                withOptions: options,
                progressHandler: downloadProgress
            )
        } catch {
            showAlert(error: error)
        }
        self.tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { _, indexPath in
            guard let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell else { return }
            guard let blobName = cell.keyLabel.text else { return }
            guard let containerName = AppConstants.videoContainer else { return }
            guard let blobClient = self.blobClient else { return }

            blobClient.blobs.delete(blob: blobName, inContainer: containerName) { result, _ in
                switch result {
                case .success:
                    self.showAlert(message: "\(blobName) successfully deleted.")
                    self.fetchData(self)
                case let .failure(error):
                    self.showAlert(error: error)
                }
            }
        }
        return [deleteAction]
    }
}
