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

import AVFoundation
import AVKit
import UIKit

// swiftlint:disable function_body_length
// swiftlint:disable cyclomatic_complexity

class BlobTableViewController: UITableViewController, MSALInteractiveDelegate {
    internal var containerName: String! = "videos"
    private var dataSource: PagedCollection<BlobItem>?
    private var noMoreData = false
    private lazy var imagePicker = UIImagePickerController()
    private lazy var player: AVPlayer = AVPlayer()
    private var currentDownloader: BlobStreamDownloader?
    private var downloaderBuffered = false

    @IBAction func didSelectUpload(_: UIBarButtonItem) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Data ...", attributes: nil)
        refreshControl.addTarget(self, action: #selector(fetchData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        fetchData(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentDownloader = nil
        downloaderBuffered = false
    }

    // MARK: Private Methods

    /// Constructs the PagedCollection and retrieves the first page of results to initalize the table view.
    @objc private func fetchData(_: Any) {
        guard let containerName = containerName else { return }
        guard let blobClient = getBlobClient() else { return }
        let options = ListBlobsOptions()
        options.maxResults = 20
        if !(tableView.refreshControl?.isRefreshing ?? false) {
            showActivitySpinner()
        }
        blobClient.listBlobs(in: containerName, withOptions: options) { result, _ in
            self.hideActivitySpinner()
            switch result {
            case let .success(paged):
                self.dataSource = paged
                self.reloadTableView()
            case let .failure(error):
                self.showAlert(error: String(describing: error))
                self.noMoreData = true
            }
        }
    }

    /// Uses asynchronous "nextPage" method to fetch the next page of results and update the table view.
    private func loadMoreSettings() {
        guard noMoreData == false else { return }
        dataSource?.nextPage { result in
            switch result {
            case .success:
                self.reloadTableView()
            case let .failure(error):
                self.showAlert(error: String(describing: error))
                self.noMoreData = true
            }
        }
    }

    /// Reload the table view on the UI thread.
    private func reloadTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
            self?.refreshControl?.endRefreshing()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        guard let data = dataSource?.items else { return 0 }
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = dataSource?.items else {
            fatalError("No data found to construct cell.")
        }
        let cellIdentifier = "CustomTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            as? CustomTableViewCell else {
            fatalError("The dequeued cell is not an instance of CustomTableViewCell")
        }
        // configure the cell
        let blobItem = data[indexPath.row]
        cell.keyLabel.text = blobItem.name
        cell.valueLabel.text = "???"
        if let blobType = blobItem.properties.blobType {
            cell.valueLabel.text = blobType.rawValue
        }

        // load next page if at the end of the current list
        if indexPath.row == data.count - 1, noMoreData == false {
            loadMoreSettings()
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell else { return }
        guard let blobName = cell.keyLabel.text else { return }
        guard let containerName = containerName else { return }
        guard let blobClient = getBlobClient() else { return }

        do {
            let options = DownloadBlobOptions()
            options.range = RangeOptions()
            options.destination = DestinationOptions()
            options.destination?.isTemporary = true
            options.range?.calculateMD5 = true
            guard let url = blobClient.url(forBlob: blobName, inContainer: containerName) else {
                showAlert(error: "Unable to create URL!")
                return
            }
            showActivitySpinner()
            try blobClient.rawDownload(url: url, withOptions: options) { result, _ in
                switch result {
                case let .success(downloader):
                    let options = [
                        NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf
                    ]
                    do {
                        let contentType = downloader.blobProperties?.contentType

                        if ["video/mp4", "application/octet-stream"].contains(contentType) {
                            self.currentDownloader = downloader
                            downloader.delegate = self
                            try downloader.complete {}
                        } else {
                            try downloader.complete {
                                self.hideActivitySpinner()
                                guard let data = try? downloader.contents() else {
                                    self.showAlert(error: "Downloaded data not found!")
                                    return
                                }

                                if let attributedString = try? NSAttributedString(
                                    data: data,
                                    options: options,
                                    documentAttributes: nil
                                ) {
                                    self.showAlert(message: attributedString.string)
                                } else if let rawString = String(data: data, encoding: .utf8) {
                                    self.showAlert(message: rawString)
                                } else {
                                    self.showAlert(error: "Unable to display the downloaded content.")
                                }
                            }
                        }
                    } catch {
                        self.showAlert(error: String(describing: error))
                    }
                case let .failure(error):
                    // TODO: Don't like this. Feels like the SDK should be responsible for handling errors rather
                    // than dumping it on the client.
                    switch error {
                    case let HTTPResponseError.statusCode(message):
                        self.showAlert(error: message)
                    case let AzureError.general(message):
                        self.showAlert(error: message)
                    default:
                        self.showAlert(error: String(describing: error))
                    }
                }
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.deselectRow(at: indexPath, animated: true)
                }
            }
        } catch {
            showAlert(error: String(describing: error))
        }
    }

    // MARK: MSALInteractiveDelegate

    func didCompleteMSALRequest(withResult result: MSALResult) {
        AppState.account = result.account
    }

    func parentForWebView() -> UIViewController {
        hideActivitySpinner()
        return self
    }
}

extension BlobTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _: UIImagePickerController,
        didFinishPickingMediaWithInfo _: [UIImagePickerController.InfoKey: Any]
    ) {
        // TODO: Upload the media to the storage container
        dismiss(animated: true) {
            self.showAlert(message: "Upload functionality coming soon!")
        }
    }

    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension BlobTableViewController: BlobDownloadDelegate {
    func downloader(_ downloader: BlobStreamDownloader, didUpdateWithProgress progress: BlobDownloadProgress) {
        guard let current = currentDownloader else { return }
        guard downloader === current else { return }
        print("Download: \(downloader.blobName) Progress: %\(progress.percentProgress)")
        // blobClient.options.logger.info("Progress: %\(percentDone)")
        if progress.percentProgress > 25, !downloaderBuffered {
            downloaderBuffered = true
            hideActivitySpinner()
            DispatchQueue.main.async {
                let url = downloader.downloadDestination
                self.player.replaceCurrentItem(with: AVPlayerItem(asset: AVAsset(url: url)))
                let controller = AVPlayerViewController()
                controller.player = self.player
                self.present(controller, animated: true) {
                    self.player.play()
                }
            }
        }
    }

    func downloader(_ downloader: BlobStreamDownloader, didFinishWithProgress _: BlobDownloadProgress) {
        guard let current = currentDownloader else { return }
        guard downloader === current else { return }
        // update playing with completed file
        DispatchQueue.main.async { [weak self] in
            guard let parent = self else { return }
            let currentTime = parent.player.currentTime()
            let asset = AVURLAsset(url: downloader.downloadDestination)
            let item = AVPlayerItem(asset: asset)
            parent.player.replaceCurrentItem(with: item)
            parent.player.seek(to: currentTime)
            parent.player.play()
        }
    }
}
