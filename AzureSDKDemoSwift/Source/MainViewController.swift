//
//  ViewController.swift
//  AzureSDKDemoSwift
//
//  Created by Travis Prescott on 8/27/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import AzureCore
import AzureAppConfiguration
import os.log
import UIKit

class MainViewController: UITableViewController {

    // MARK: Properties

    private let connectionString = "Endpoint=https://tjpappconfig.azconfig.io;Id=2-l0-s0:zSvXZtO9L9bv9s3QVyD3;Secret=FzxmbflLwAt5+2TUbnSIsAuATyY00L+GFpuxuJZRmzI="
    private var settingsCollection: PagedCollection<ConfigurationSetting>?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadInitialSettings()
    }

    // MARK: Private Methods
    private func loadInitialSettings() {
        guard let client = try? AppConfigurationClient(connectionString: connectionString) else { return }
        client.getConfigurationSettings(forKey: nil, forLabel: nil, completion: { result, _ in
            switch result {
            case .failure(let error):
                os_log("Error: %@", error.localizedDescription)
            case .success(let pagedCollection):
                self.settingsCollection = pagedCollection
                self.reloadTableView()
            }
        })
    }

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
