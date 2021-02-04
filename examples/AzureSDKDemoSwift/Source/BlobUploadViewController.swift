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

import AVFoundation
import AVKit
import Photos
import UIKit

internal struct UploadData {
    let asset: PHAsset
    let url: URL
    var blobName: String {
        let string = url.absoluteString.lowercased()
        if let range = string.range(of: "img") {
            let blobName = string[range.lowerBound...]
            return String(blobName)
        }
        return ""
    }
}

class BlobUploadViewController: UIViewController, MSALInteractiveDelegate {
    private var dataSource = [UploadData]()
    private var blobClient: StorageBlobClient?

    private var sizeForCell: CGSize {
        let itemsPerRow: CGFloat = 3.0
        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }

    @IBOutlet var collectionView: UICollectionView!

    private let sectionInsets = UIEdgeInsets(
        top: 10.0,
        left: 5.0,
        bottom: 10.0,
        right: 5.0
    )

    // MARK: Internal Methods

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        blobClient = try? AppState.blobClient(withDelegate: self)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized {
                    self.loadImages()
                }
            }
        } else if status == .authorized {
            loadImages()
        }
    }

    // MARK: Internal Methods

    internal func url(for asset: PHAsset, completionHandler: @escaping (URL?) -> Void) {
        asset.requestContentEditingInput(with: nil) { contentEditingInput, _ in
            if asset.mediaType == .image {
                let url = contentEditingInput?.fullSizeImageURL?.absoluteURL
                completionHandler(url)
            } else {
                let url = (contentEditingInput?.audiovisualAsset as? AVURLAsset)?.url.absoluteURL
                completionHandler(url)
            }
        }
    }

    internal func image(for asset: PHAsset, withSize size: CGSize) -> UIImage? {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .highQualityFormat

        var assetImage: UIImage?
        imageManager.requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFill,
            options: requestOptions
        ) { image, _ in
            assetImage = image
        }
        return assetImage
    }

    internal func loadImages() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]

        let fetchResult: PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        let group = DispatchGroup()
        fetchResult.enumerateObjects { asset, _, _ in
            group.enter()
            self.url(for: asset) { url in
                guard let assetUrl = url else { return }
                self.dataSource.append(UploadData(asset: asset, url: assetUrl))
                group.leave()
            }
        }
        group.notify(queue: .main) {
            PHPhotoLibrary.authorizationStatus()
            self.collectionView.reloadData()
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

extension BlobUploadViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    private func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return dataSource.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cellIdentifier = "CustomCollectionViewCell"
        guard let blobClient = blobClient,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath)
            as? CustomCollectionViewCell
        else {
            fatalError("Preconditions not met to create CustomCollectionViewCell")
        }

        let data = dataSource[indexPath.row]
        cell.backgroundColor = .white
        cell.image.image = image(for: data.asset, withSize: sizeForCell)
        cell.progressBar.progress = 0

        if let transfer = blobClient.uploads.firstWith(blobName: data.blobName) {
            // Match any blobs to existing transfers.
            // Update upload map and progress.
            cell.backgroundColor = transfer.state.color
            cell.progressBar.progress = transfer.progress.asFloat
        }
        return cell
    }

    func collectionView(_: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        defer {
            self.collectionView.deselectItem(at: indexPath, animated: true)
        }
        guard let containerName = AppConstants.uploadContainer else { return }
        guard let blobClient = blobClient else { return }
        let data = dataSource[indexPath.row]
        let blobName = data.blobName

        // don't start a transfer if one has already started
        guard blobClient.uploads.firstWith(blobName: blobName) == nil else { return }

        let sourceUrl = LocalURL(fromAbsoluteUrl: data.url)
        let properties = BlobProperties(
            contentType: "image/jpg"
        )
        let options = AppState.uploadOptions
        do {
            try blobClient.blobs.upload(
                file: sourceUrl,
                toContainer: containerName,
                asBlob: blobName,
                properties: properties,
                withOptions: options
            )
        } catch {
            showAlert(error: error)
        }
    }
}

extension BlobUploadViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt _: IndexPath
    ) -> CGSize {
        return sizeForCell
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        insetForSectionAt _: Int
    ) -> UIEdgeInsets {
        return sectionInsets
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        minimumLineSpacingForSectionAt _: Int
    ) -> CGFloat {
        return sectionInsets.left
    }
}

extension BlobUploadViewController: StorageBlobClientDelegate {
    func blobClient(
        _: StorageBlobClient,
        didUpdateTransfer transfer: BlobTransfer,
        withState _: TransferState,
        andProgress _: TransferProgress
    ) {
        if transfer.transferType == .upload {
            collectionView.reloadData()
        }
    }

    func blobClient(_: StorageBlobClient, didCompleteTransfer transfer: BlobTransfer) {
        if transfer.transferType == .upload {
            collectionView.reloadData()
        }
    }

    func blobClient(_: StorageBlobClient, didFailTransfer _: BlobTransfer, withError error: Error) {
        showAlert(error: error)
        collectionView.reloadData()
    }
}
