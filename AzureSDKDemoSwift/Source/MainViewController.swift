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

    private var _settings = [ConfigurationSetting]()
    private var _settingsCollection: PagedCollection<ConfigurationSetting>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadInitialSettings()
    }
    
    // MARK: Private Methods
    private func loadInitialSettings() {
        guard let client = try? AppConfigurationClient(connectionString: connectionString) else { return }
        client.getConfigurationSettings(forKey: nil, forLabel: nil, completion: { result, httpResponse in
            switch result {
            case .failure(let error):
                os_log("Error: %@", error.localizedDescription)
            case .success(let pagedCollection):
                self._settingsCollection = pagedCollection
                if let newPage = try? self._settingsCollection?.nextPage() {
                    self._settings = newPage
                    self.reloadTableView()
                }
            }
        })
    }
    
    private func loadMoreSettings() {
        guard let settingsCollection = self._settingsCollection else { return }
        guard let newPage = try? settingsCollection.nextPage() else { return }
        self._settings += newPage
        reloadTableView()
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
        return self._settings.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "SettingTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SettingTableViewCell else {
            fatalError("The dequeued cell is not an instance of SettingTableViewCell")
        }
        // configure the cell
        let setting = _settings[indexPath.row]
        cell.keyLabel.text = setting.key
        cell.valueLabel.text = setting.value

        // load next page if at the end of the current list
        if indexPath.row == self._settings.count - 1 {
            self.loadMoreSettings()
        }
        
        return cell
    }
}
