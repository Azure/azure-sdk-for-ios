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

    // read-only connection string
    private let appConfigConnectionString = "Endpoint=https://tjpappconfig.azconfig.io;Id=2-l0-s0:zSvXZtO9L9bv9s3QVyD3;Secret=FzxmbflLwAt5+2TUbnSIsAuATyY00L+GFpuxuJZRmzI="
    private var settingsCollection: PagedCollection<ConfigurationSetting>?

    // read-only blob connection string using a SAS token
    private let storageAccountName = "tjpstorage1"
    private let blobConnectionString = "BlobEndpoint=https://tjpstorage1.blob.core.windows.net/;QueueEndpoint=https://tjpstorage1.queue.core.windows.net/;FileEndpoint=https://tjpstorage1.file.core.windows.net/;TableEndpoint=https://tjpstorage1.table.core.windows.net/;SharedAccessSignature=sv=2018-03-28&ss=b&srt=sco&sp=rl&se=2020-10-03T07:45:02Z&st=2019-10-02T23:45:02Z&spr=https&sig=L7zqOTStAd2o3Mp72MW59GXM1WbL9G2FhOSXHpgrBCE%3D"

    private let storageBaseUrl = "https://tjpstorage1.blob.core.windows.net"

    override func viewDidLoad() {
        // If I try to call loadAllSettingsByItem here, the execution hangs...
        super.viewDidLoad()
        loadInitialSettings()
    }

    // MARK: Private Methods

    /// Constructs the PagedCollection and retrieves the first page of results to initalize the table view.
    private func loadInitialSettings() {
//        guard let client = try? AppConfigurationClient(connectionString: appConfigConnectionString) else { return }
//        client.listConfigurationSettings(forKey: nil, forLabel: nil, completion: { result, _ in
//            switch result {
//            case .failure(let error):
//                os_log("Error: %@", String(describing: error))
//            case .success(let pagedCollection):
//                self.settingsCollection = pagedCollection
//                // self.loadAllSettingsByItem()
//                self.reloadTableView()
//            }
//        })
        
        if let blobClient = try? StorageBlobClient(accountName: storageAccountName,
                                                   connectionString: blobConnectionString) {
            blobClient.listContainers { result, httpResponse in
                switch result {
                case .success(let paged):
                    if let containers = paged.pageItems {
                        for container in containers {
                            let leaseState = container.leaseState.rawValue
                            print("Name: \(container.name)\nLeaseState: \(leaseState)")
                        }
                    }
                case .failure(let error):
                    os_log("Error: %@", String(describing: error))
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
                    os_log("Error: %@", String(describing: error))
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
