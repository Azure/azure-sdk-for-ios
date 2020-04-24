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
import AzureStorageBlob
import MSAL
import os.log
import Photos

import AVFoundation
import AVKit
import UIKit

class BlobDownloadViewController: UIViewController, MSALInteractiveDelegate {
    private var dataSource: PagedCollection<BlobItem>?
    private var downloadMap = [IndexPath: BlobTransfer]()
    private var noMoreData = false

    @IBOutlet var tableView: UITableView!

    private lazy var player: AVPlayer = AVPlayer()
    private var blobClient: StorageBlobClient?

    // MARK: Internal Methods

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        blobClient = try? AppState.blobClient(withDelegate: self)
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Data ...", attributes: nil)
        refreshControl.addTarget(self, action: #selector(fetchData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PHPhotoLibrary.authorizationStatus()
        fetchData(self)
        StorageBlobClient.startManaging()
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
        blobClient.listBlobs(inContainer: containerName, withOptions: options) { result, _ in
            DispatchQueue.main.async { self.tableView.refreshControl?.endRefreshing() }
            switch result {
            case let .success(paged):
                self.dataSource = paged
                self.reloadTableView()
            case let .failure(error):
                self.showAlert(error: error)
                self.noMoreData = true
            }
        }
    }

    /// Uses asynchronous "nextPage" method to fetch the next page of results and update the table view.
    private func loadMoreSettings() {
        guard noMoreData == false else { return }
        dataSource?.nextPage { result in
            switch result {
            case let .success(data):
                if data != nil {
                    self.reloadTableView()
                } else {
                    self.noMoreData = true
                }
            case let .failure(error):
                self.showAlert(error: error)
                self.noMoreData = true
            }
        }
    }

    /// Reload the table view on the UI thread.
    private func reloadTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

    // MARK: Internal Methods

    internal func playVideo(_ indexPath: IndexPath, _ destination: URL) {
        downloadMap.removeValue(forKey: indexPath)
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
            as? CustomTableViewCell else {
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
        // Update download map and progress.
        if let transfer = blobClient.transfers.downloadedFrom(container: AppConstants.videoContainer, blob: blobName)
            .first {
            cell.backgroundColor = transfer.state.color
            downloadMap[indexPath] = transfer
            cell.progressBar.progress = transfer.progress
        }

        // load next page if at the end of the current list
        if indexPath.row == data.count - 1, noMoreData == false {
            loadMoreSettings()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell else { return }
        guard let blobName = cell.keyLabel.text else { return }
        guard let containerName = AppConstants.videoContainer else { return }
        guard let blobClient = blobClient else { return }
        let destination = LocalURL(inDirectory: .cachesDirectory, forBlob: blobName, inContainer: containerName)
        guard let destinationUrl = destination.resolvedUrl else { return }

        let manager = FileManager.default
        if let existingTransfer = downloadMap[indexPath] {
            // if transfer exists and is complete, open file, otherwise ignore
            if manager.fileExists(atPath: destinationUrl.path), existingTransfer.incompleteBlocks == 0 {
                playVideo(indexPath, destinationUrl)
                return
            }
            return
        } else {
            // if no transfer exists but a file exists, play
            if manager.fileExists(atPath: destinationUrl.path) {
                playVideo(indexPath, destinationUrl)
                return
            }
        }

        // Otherwise, start the download with TransferManager.
        let options = AppState.downloadOptions
        do {
            if let transfer = try blobClient.download(
                blob: blobName,
                fromContainer: containerName,
                toFile: destination,
                withOptions: options
            ) as? BlobTransfer {
                downloadMap[indexPath] = transfer
            }
        } catch {
            showAlert(error: error)
        }
        DispatchQueue.main.async { [weak self] in
            self?.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}

extension BlobDownloadViewController: TransferDelegate {
    func client(forRestorationId _: String) -> PipelineClient? {
        return blobClient
    }

    func transfer(
        _ transfer: Transfer,
        didUpdateWithState _: TransferState,
        andProgress progress: Float?
    ) {
        if let blobTransfer = transfer as? BlobTransfer, blobTransfer.transferType == .download {
            reloadTableView()
        }
    }

    func transfersDidUpdate(_: [Transfer]) {
        reloadTableView()
    }

    func transferDidComplete(_ transfer: Transfer) {
        if let blobTransfer = transfer as? BlobTransfer, blobTransfer.transferType == .download {
            reloadTableView()
        }
    }

    func transfer(_: Transfer, didFailWithError error: Error) {
        showAlert(error: error)
        reloadTableView()
    }
}
