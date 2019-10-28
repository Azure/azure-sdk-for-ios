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
import os.log
import UIKit

class BlobTableViewController: UITableViewController {
    internal var containerName: String?
    private var dataSource: PagedCollection<BlobItem>?
    private var noMoreData = false

    override func viewDidLoad() {
        super.viewDidLoad()
        loadInitialSettings()
    }

    // MARK: Private Methods

    /// Constructs the PagedCollection and retrieves the first page of results to initalize the table view.
    private func loadInitialSettings() {
        guard let containerName = containerName else { return }
        guard let blobClient = getBlobClient() else { return }
        let options = ListBlobsOptions()
        options.maxResults = 20
        blobClient.listBlobs(in: containerName, withOptions: options) { result, _ in
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CustomTableViewCell else {
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
        blobClient.download(blob: blobName, fromContainer: containerName) { result, _ in
            switch result {
            case let .success(data):
                let options = [
                    NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf,
                ]
                if let attributedString = try? NSAttributedString(data: data, options: options,
                                                                  documentAttributes: nil) {
                    self.showAlert(message: attributedString.string)
                } else if let rawString = String(data: data, encoding: .utf8) {
                    self.showAlert(message: rawString)
                } else if let image = UIImage(data: data) {
                    self.showAlert(image: image)
                } else {
                    self.showAlert(error: "Unable to display the downloaded content.")
                }
            case let .failure(error):
                self.showAlert(error: String(describing: error))
            }
            DispatchQueue.main.async { [weak self] in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
}
