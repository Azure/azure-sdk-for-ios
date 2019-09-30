//
//  ViewController.swift
//  AzureSDKDemoSwift
//
//  Created by Travis Prescott on 8/27/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import AzureCore
import AzureAppConfiguration
import AzureStorageBlob
import os.log
import UIKit

class MainViewController: UITableViewController {

    // MARK: Properties

    private let connectionString = "Endpoint=https://tjpappconfig.azconfig.io;Id=2-l0-s0:zSvXZtO9L9bv9s3QVyD3;Secret=FzxmbflLwAt5+2TUbnSIsAuATyY00L+GFpuxuJZRmzI="
    private var settingsCollection: PagedCollection<ConfigurationSetting>?

    private let storageBaseUrl = "https://tjpstorage1.blob.core.windows.net"

    override func viewDidLoad() {
        // If I try to call loadAllSettingsByItem here, the execution hangs...
        super.viewDidLoad()
        loadInitialSettings()
    }

    // MARK: Private Methods

    /// Constructs the PagedCollection and retrieves the first page of results to initalize the table view.
    private func loadInitialSettings() {
        guard let client = try? AppConfigurationClient(connectionString: connectionString) else { return }
        client.getConfigurationSettings(forKey: nil, forLabel: nil, completion: { result, _ in
            switch result {
            case .failure(let error):
                os_log("Error: %@", error.localizedDescription)
            case .success(let pagedCollection):
                self.settingsCollection = pagedCollection
                // self.loadAllSettingsByItem()
                self.reloadTableView()
            }
        })

        if let blobClient = try? StorageBlobClient(baseUrl: storageBaseUrl) {
            blobClient.listContainers { result, httpResponse in
                debugPrint(httpResponse)
                switch result {
                case .success(let containers):
                    let test = "best"
                case .failure(let error):
                    os_log("Error: %@", error.localizedDescription)
                }
            }
        }
    }

    /// For demo purposes only to illustrate usage of the "nextItem" method to retrieve all items.
    /// Requires semaphore to force synchronous behavior, otherwise concurrency issues arise.
    private func loadAllSettingsByItem() {
        var newItem: ConfigurationSetting?
        let semaphore = DispatchSemaphore(value: 0)
        repeat {
            self.settingsCollection?.nextItem { result in
                defer { semaphore.signal() }
                switch result {
                case .failure(let error):
                    newItem = nil
                    os_log("Error: %@", error.localizedDescription)
                case .success(let item):
                    newItem = item
                }
            }
            _ = semaphore.wait(wallTimeout: .distantFuture)
        } while(newItem != nil)
    }

    /// Uses asynchronous "nextPage" method to fetch the next page of results and update the table view.
    private func loadMoreSettings() {
        self.settingsCollection?.nextPage { result in
            switch result {
            case .success:
                self.reloadTableView()
            case .failure(let error):
                os_log("Error: %@", error.localizedDescription)
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
        guard let data = settingsCollection?.items else { return 0 }
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = settingsCollection?.items else {
            fatalError("No data found to construct cell.")
        }
        let cellIdentifier = "SettingTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SettingTableViewCell else {
            fatalError("The dequeued cell is not an instance of SettingTableViewCell")
        }
        // configure the cell
        let setting = data[indexPath.row]
        cell.keyLabel.text = setting.key
        cell.valueLabel.text = setting.value

        // load next page if at the end of the current list
        if indexPath.row == data.count - 10 {
            self.loadMoreSettings()
        }
        return cell
    }
}
