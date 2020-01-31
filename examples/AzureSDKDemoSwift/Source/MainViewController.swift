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

import AzureAppConfiguration
import AzureCore
import AzureStorageBlob
import MSAL
import os.log
import UIKit

class MainViewController: UITableViewController, MSALInteractiveDelegate {

    // MARK: Properties

    private var dataSource: PagedCollection<ContainerItem>?
    private var noMoreData = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        loadInitialSettings()
    }

    // MARK: Private Methods

    /// Constructs the PagedCollection and retrieves the first page of results to initalize the table view.
    private func loadInitialSettings() {
        guard let blobClient = getBlobClient() else { return }
        let options = ListContainersOptions()
        options.maxResults = 20
        blobClient.listContainers(withOptions: options) { result, _ in
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

    /// For demo purposes only to illustrate usage of the "nextItem" method to retrieve all items.
    /// Requires semaphore to force synchronous behavior, otherwise concurrency issues arise.
    private func loadAllSettingsByItem() {
        var newItem: ContainerItem?
        let semaphore = DispatchSemaphore(value: 0)
        repeat {
            dataSource?.nextItem { result in
                defer { semaphore.signal() }
                switch result {
                case let .failure(error):
                    newItem = nil
                    os_log("Error: %@", String(describing: error))
                case let .success(item):
                    newItem = item
                }
            }
            _ = semaphore.wait(wallTimeout: .distantFuture)
        } while newItem != nil
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
        let container = data[indexPath.row]
        cell.keyLabel.text = container.name
        cell.valueLabel.text = ""

        // load next page if at the end of the current list
        if indexPath.row == data.count - 1, noMoreData == false {
            loadMoreSettings()
        }
        return cell
    }

    // MARK: MSALInteractiveDelegate

    func didCompleteMSALRequest(withResult result: MSALResult) {
        AppState.account = result.account
    }
}
