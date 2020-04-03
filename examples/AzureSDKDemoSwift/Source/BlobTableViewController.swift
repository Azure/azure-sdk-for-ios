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
    private let containerName: String! = "videos"
    private var dataSource: PagedCollection<BlobItem>?
    private var downloadMap = [IndexPath: Transfer]()
    private var noMoreData = false
    private var uploadAlert: UIAlertController?

    private let downloadOptions = DownloadBlobOptions(
        range: RangeOptions(
            calculateMD5: false // TODO: Diagnose issues with EXC_BAD_ACCESS and restore to true
        )
    )

    private lazy var blobClient: StorageBlobClient? = {
        guard let application = AppState.application else { return nil }
        let credential = MSALCredential(
            tenant: AppConstants.tenant, clientId: AppConstants.clientId, application: application,
            account: AppState.currentAccount()
        )
        let options = StorageBlobClientOptions(
            logger: ClientLoggers.none
        )
        let client = StorageBlobClient(
            accountUrl: AppConstants.storageAccountUrl,
            credential: credential,
            withOptions: options
        )
        client.transferDelegate = self
        return client
    }()

    private lazy var imagePicker = UIImagePickerController()
    private lazy var player: AVPlayer = AVPlayer()

    // MARK: Actions

    @IBAction func didSelectUpload(_: UIBarButtonItem) {
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.mediaTypes = ["public.movie"]
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }

    // MARK: Internal Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Fetching Data ...", attributes: nil)
        refreshControl.addTarget(self, action: #selector(fetchData(_:)), for: .valueChanged)
        tableView.refreshControl = refreshControl
        blobClient?.startManaging()
        fetchData(self)
    }

    override func viewWillDisappear(_: Bool) {
        blobClient?.stopManaging()
    }

    // MARK: Private Methods

    /// Constructs the PagedCollection and retrieves the first page of results to initalize the table view.
    @objc private func fetchData(_: Any) {
        guard let containerName = containerName else { return }
        let options = ListBlobsOptions(maxResults: 20)
        if !(tableView.refreshControl?.isRefreshing ?? false) {
            showActivitySpinner()
        }
        blobClient?.listBlobs(inContainer: containerName, withOptions: options) { result, _ in
            self.hideActivitySpinner()
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
            case .success:
                self.reloadTableView()
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
        let blobName = blobItem.name

        cell.keyLabel.text = blobItem.name
        cell.valueLabel.text = "???"
        if let blobType = blobItem.properties?.blobType {
            cell.valueLabel.text = blobType.rawValue
        }
        cell.backgroundColor = .white

        // Match any blobs to existing transfers.
        // Update download map and progress.
        if let transfer = blobClient?.transfers.from(container: containerName, blob: blobName).first as? BlobTransfer {
            if transfer.state != .complete {
                cell.backgroundColor = .yellow
            } else {
                cell.backgroundColor = .green
            }
            downloadMap[indexPath] = transfer
            cell.progressBar.progress = transfer.progress
        }

        // load next page if at the end of the current list
        if indexPath.row == data.count - 1, noMoreData == false {
            loadMoreSettings()
        }
        return cell
    }

    fileprivate func playVideo(_ indexPath: IndexPath, _ destination: URL) {
        downloadMap.removeValue(forKey: indexPath)
        player.replaceCurrentItem(with: AVPlayerItem(asset: AVAsset(url: destination)))
        let controller = AVPlayerViewController()
        controller.player = player
        present(controller, animated: true) {
            self.player.play()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell else { return }
        guard let blobName = cell.keyLabel.text else { return }
        guard let containerName = containerName else { return }
        let destination = LocalPathHelper.url(forBlob: blobName, inContainer: containerName)

        let manager = FileManager.default
        if let existingTransfer = downloadMap[indexPath] as? BlobTransfer {
            // if transfer exists and is complete, open file, otherwise ignore
            if manager.fileExists(atPath: destination.path), existingTransfer.incompleteBlocks == 0 {
                playVideo(indexPath, destination)
                return
            }
            return
        } else {
            // if no transfer exists but a file exists, play
            if manager.fileExists(atPath: destination.path) {
                playVideo(indexPath, destination)
                return
            }
        }

        // Otherwise, start the download with TransferManager.
        do {
            if let transfer = try blobClient?.download(
                blob: blobName,
                fromContainer: containerName,
                toFile: destination,
                withRestorationId: "download",
                withOptions: downloadOptions
            ) {
                downloadMap[indexPath] = transfer
            }
            DispatchQueue.main.async { [weak self] in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            }
        } catch {
            showAlert(error: error)
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

            // Otherwise, start the upload with TransferManager.
            if let transfer = try? self.blobClient?.upload(
                file: url,
                toContainer: self.containerName,
                asBlob: blobName,
                properties: properties,
                withRestorationId: "upload"
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
            self.blobClient?.cancel(transfer: transfer)
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
        updateProgressBar(forTransfer: transfer, withProgress: progress.asFloat)
    }

    internal func updateProgressBar(forTransfer transfer: Transfer, withProgress progress: Float) {
        DispatchQueue.main.async {
            let indexPath = self.downloadMap.filter { _, value in
                value === transfer
            }
            guard let cellIndex = indexPath.first?.key else { return }
            guard let cell = self.tableView.cellForRow(at: cellIndex) as? CustomTableViewCell else { return }
            cell.progressBar.progress = progress
        }
    }

    internal func updateUploadAlert(forTransfer transfer: BlobTransfer, withProgress progress: TransferProgress) {
        updateUploadAlert(forTransfer: transfer, withProgress: progress.asFloat)
    }

    internal func updateUploadAlert(forTransfer _: BlobTransfer, withProgress progress: Float) {
        DispatchQueue.main.async {
            guard let uploadAlert = self.uploadAlert else { return }
            if progress == 1.0 {
                uploadAlert.dismiss(animated: true) {
                    self.uploadAlert = nil
                }
            } else {
                let progressViews = uploadAlert.view.subviews.filter { $0 is UIProgressView }
                if let progressView = progressViews.first as? UIProgressView {
                    progressView.progress = progress
                }
            }
        }
    }
}

extension BlobTableViewController: TransferDelegate {
    func client(forRestorationId _: String) -> PipelineClient? {
        return blobClient
    }

    func options(forRestorationId restorationId: String) -> AzureOptions? {
        if restorationId == "download" { return downloadOptions }
        return nil
    }

    func transfer(
        _ transfer: Transfer,
        didUpdateWithState _: TransferState,
        andProgress progress: TransferProgress?
    ) {
        if let blobTransfer = transfer as? BlobTransfer {
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
    }

    func transferDidComplete(_ transfer: Transfer) {
        if let blobTransfer = transfer as? BlobTransfer {
            switch blobTransfer.transferType {
            case .download:
                updateProgressBar(forTransfer: transfer, withProgress: 1.0)
            case .upload:
                updateUploadAlert(forTransfer: blobTransfer, withProgress: 1.0)
            default:
                return
            }
            reloadTableView()
        }
    }

    func transfer(_: Transfer, didFailWithError error: Error) {
        showAlert(error: error)
        reloadTableView()
    }

    func transfer(_: Transfer, didUpdateWithState _: TransferState) {
        reloadTableView()
    }
}
