//
//  BlobTableViewController.swift
//  AzureSDKDemoSwift
//
//  Created by Travis Prescott on 10/7/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import AzureCore
import AzureStorageBlob
import os.log
import UIKit

class BlobTableViewController: UITableViewController {

    internal var containerName: String?
    internal var dataSource: PagedCollection<BlobProperties>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadInitialSettings()
    }

    // MARK: Private Methods

    /// Constructs the PagedCollection and retrieves the first page of results to initalize the table view.
    private func loadInitialSettings() {

        guard let containerName = containerName else { return }
        let storageAccountName = AppConstants.storageAccountName
        let blobConnectionString = AppConstants.blobConnectionString

        if let blobClient = try? StorageBlobClient(accountName: storageAccountName,
                                                   connectionString: blobConnectionString) {
            blobClient.listBlobs(in: containerName) { result, httpResponse in
                switch result {
                case .success(let paged):
                    self.dataSource = paged
                    self.reloadTableView()
                case .failure(let error):
                    os_log("Error: %@", String(describing: error))
                }
            }
        }
    }

    /// Uses asynchronous "nextPage" method to fetch the next page of results and update the table view.
    private func loadMoreSettings() {
        self.dataSource?.nextPage { result in
            switch result {
            case .success:
                self.reloadTableView()
            case .failure(let error):
                os_log("Error: %@", String(describing: error))
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        let blobProperties = data[indexPath.row]
        cell.keyLabel.text = blobProperties.name
        cell.valueLabel.text = "???"
        if let blobType = blobProperties.blobType {
            cell.valueLabel.text = blobType.rawValue
        }

        // load next page if at the end of the current list
        if indexPath.row == data.count - 10 {
            self.loadMoreSettings()
        }
        return cell
    }
}
