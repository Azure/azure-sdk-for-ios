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

class BlobTableViewController: UITableViewController, MSALInteractiveDelegate {
    private var containerName: String! = "videos"
    private var dataSource: PagedCollection<BlobItem>?
    private var downloadMap = [IndexPath: Transfer]()
    private var noMoreData = false
    private var uploadAlert: UIAlertController?
    private lazy var imagePicker = UIImagePickerController()
    private lazy var player: AVPlayer = AVPlayer()

    @IBAction func didSelectUpload(_: UIBarButtonItem) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.mediaTypes = ["public.movie"]
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Data ...", attributes: nil)
        refreshControl.addTarget(self, action: #selector(fetchData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        fetchData(self)
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
            options.destination?.isTemporary = false
            // TODO: Diagnose issues with EXC_BAD_ACCESS and restore to true
            options.range?.calculateMD5 = false
            guard let url = blobClient.url(forBlob: blobName, inContainer: containerName) else {
                showAlert(error: "Unable to create URL!")
                return
            }
            guard let destination = try? blobClient.localUrl(remoteUrl: url, withOptions: options) else {
                showAlert(error: "Unable to create destination URL!")
                return
            }

            // If file is fully downloaded, load it with AVPlayer
            let manager = FileManager.default
            if manager.fileExists(atPath: destination.path) {
                downloadMap.removeValue(forKey: indexPath)
                player.replaceCurrentItem(with: AVPlayerItem(asset: AVAsset(url: destination)))
                let controller = AVPlayerViewController()
                controller.player = player
                present(controller, animated: true) {
                    self.player.play()
                }
                return
            }

            // Otherwise, start the download with TransferManager.
            if let transfer = try blobClient.download(url: url, withOptions: options) {
                downloadMap[indexPath] = transfer
            }
            DispatchQueue.main.async { [weak self] in
                self?.tableView.deselectRow(at: indexPath, animated: true)
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
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        dismiss(animated: true) {
            guard let blobClient = self.getBlobClient() else {
                fatalError("Unable to create blob client.")
            }
            guard let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String else {
                fatalError("Unable to determine media type.")
            }
            var mediaUrl: URL!
            switch mediaType {
            case "public.movie":
                mediaUrl = info[.mediaURL] as? URL
            default:
                break
            }
            guard mediaUrl != nil else {
                fatalError("Unable to find media URL.")
            }

            guard let url = mediaUrl else { return }
            let blobName = url.lastPathComponent
            let properties = BlobProperties(
                contentType: "video/quicktime"
            )
            let options = UploadBlobOptions()

            // Otherwise, start the upload with TransferManager.
            if let transfer = try? blobClient.upload(
                url: url,
                toContainer: self.containerName,
                asBlob: blobName,
                properties: properties,
                withOptions: options
            ) as? BlobTransfer {
                self.showUploadAlert(forTransfer: transfer)
            }
        }
    }

    func imagePickerControllerDidCancel(_: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: Internal Methods

    internal func showUploadAlert(forTransfer transfer: BlobTransfer) {
        let alertView = UIAlertController(
            title: "Upload in Progress",
            message: "Please wait...",
            preferredStyle: .alert
        )
        alertView.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            URLSessionTransferManager.shared.cancel(transfer: transfer)
        }))
        let margin: CGFloat = 8.0
        let rect = CGRect(x: margin, y: 72.0, width: alertView.view.frame.width - margin * 2.0, height: 2.0)
        let progressView = UIProgressView(frame: rect)
        progressView.progress = 0.0
        progressView.tintColor = view.tintColor
        alertView.view.addSubview(progressView)
        uploadAlert = alertView

        present(alertView, animated: true)
    }

    internal func updateProgressBar(forTransfer transfer: Transfer, withProgress progress: TransferProgress) {
        DispatchQueue.main.sync {
            let indexPath = self.downloadMap.filter { _, value in
                value === transfer
            }
            guard let cellIndex = indexPath.first?.key else { return }
            DispatchQueue.main.async {
                guard let cell = self.tableView.cellForRow(at: cellIndex) as? CustomTableViewCell else { return }
                cell.progressBar.progress = progress.asFloat
            }
        }
    }

    internal func updateUploadAlert(forTransfer _: BlobTransfer, withProgress progress: TransferProgress) {
        guard let uploadAlert = uploadAlert else { return }
        DispatchQueue.main.async {
            if progress.asPercent == 100 {
                uploadAlert.dismiss(animated: true) {
                    self.uploadAlert = nil
                }
            } else {
                let progressViews = uploadAlert.view.subviews.filter { $0 is UIProgressView }
                if let progressView = progressViews.first as? UIProgressView {
                    progressView.progress = progress.asFloat
                }
            }
        }
    }
}

extension BlobTableViewController: TransferManagerDelegate {
    func transferManager<T>(
        _: T,
        didUpdateTransfer transfer: Transfer,
        withState _: TransferState,
        andProgress progress: TransferProgress?
    ) where T: TransferManager {
        guard let blobTransfer = transfer as? BlobTransfer else { return }
        if let progress = progress {
            switch blobTransfer.transferType {
            case .download:
                updateProgressBar(forTransfer: transfer, withProgress: progress)
            case .upload:
                updateUploadAlert(forTransfer: blobTransfer, withProgress: progress)
            default:
                return
            }
        }
        reloadTableView()
    }

    func transferManager<T>(_: T, didUpdateTransfers _: [Transfer], withState _: TransferState)
        where T: TransferManager {
        reloadTableView()
    }

    func transferManager<T>(_: T, didCompleteTransfer _: Transfer) where T: TransferManager {
        reloadTableView()
    }

    func transferManager<T>(_: T, didFailTransfer transfer: Transfer, withError _: Error) where T: TransferManager {
        reloadTableView()
    }

    func transferManager<T>(_: T, didUpdateWithState _: TransferState) where T: TransferManager {
        reloadTableView()
    }
}
