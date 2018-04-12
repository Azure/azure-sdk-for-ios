//
//  DatabaseTableViewController.swift
//  AzureData iOS Example
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AzureData

class DatabaseTableViewController: UITableViewController {

    let selectedSegmentIndexKey = "DatabaseTableViewController.selectedSegmentIndex"
    
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var offers: [Offer] = []
    var databases: [Database] = []
    
    
    var databasesSelected: Bool {
        return self.segmentedControl.selectedSegmentIndex == 0
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: selectedSegmentIndexKey)
        
        addButton.isEnabled = databasesSelected
    }
    
    
    func refreshData(fromUser: Bool = false) {
        
        if databasesSelected || !fromUser  {
            
            AzureData.databases { r in
                debugPrint(r.result)
                DispatchQueue.main.async {
                    if let databases = r.resource?.items {
                        self.databases = databases
                        if self.databasesSelected {
                            self.tableView.reloadData()
                        }
                    } else if let error = r.result.error {
                        self.showErrorAlert(error)
                    }
                    self.refreshControl?.endRefreshing()
                }
            }
        }
        if !databasesSelected || !fromUser {
            
            AzureData.offers { r in
                debugPrint(r.result)
                DispatchQueue.main.async {
                    if let offers = r.resource?.items {
                        self.offers = offers
                        if !self.databasesSelected {
                            self.tableView.reloadData()
                        }
                    } else if let error = r.result.error {
                        self.showErrorAlert(error)
                    }
                    self.refreshControl?.endRefreshing()
                }
            }
        }
    }

    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        UserDefaults.standard.set(segmentedControl.selectedSegmentIndex, forKey: selectedSegmentIndexKey)
        addButton.isEnabled = databasesSelected
        tableView.reloadData()
    }
    
    
    @IBAction func refreshControlValueChanged(_ sender: Any) { refreshData(fromUser: true) }
    
    
    @IBAction func addButtonTouchUpInside(_ sender: Any) { showNewResourceAlert() }
    
    
    @IBAction func logoutButtonTouchUpInside(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Clear Database Account", message: "This will remove the stored database account name and key.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in })
        
        alertController.addAction(UIAlertAction(title: "Clear", style: .destructive) { _ in

            self.offers = []
            self.databases = []

            self.tableView.reloadData()
            
            (UIApplication.shared.delegate as? AppDelegate)?.storeDatabaseAccount(name: nil, key: nil)
        })
        
        present(alertController, animated: true) { }
    }
    
    
    func showNewResourceAlert() {
        
        let alertController = UIAlertController(title: "New Database", message: "Enter an ID for the new Database", preferredStyle: .alert)
        
        alertController.addTextField() { textField in
            textField.placeholder = "Database ID"
            textField.returnKeyType = .done
        }

        alertController.addAction(UIAlertAction(title: "Create", style: .default) { a in
            
            if let name = alertController.textFields?.first?.text {
                AzureData.create(databaseWithId: name) { r in
                    DispatchQueue.main.async {
                        if let database = r.resource {
                            self.databases.append(database)
                            self.tableView.reloadData()
                        } else if let error = r.error {
                            self.showErrorAlert(error)
                        }
                    }
                }
            }
        })
        
        present(alertController, animated: true) { }
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return databasesSelected ? databases.count : offers.count }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resourceCell", for: indexPath)
        
        let resource: CodableResource = databasesSelected ? databases[indexPath.row] : offers[indexPath.row]
        
        cell.textLabel?.text = resource.id
        cell.detailTextLabel?.text = resource.resourceId

        return cell
    }


    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let dbSelected = databasesSelected
        
        let action = UIContextualAction.init(style: .normal, title: "Get") { (action, view, callback) in
            if dbSelected {
                self.databases[indexPath.row].refresh { r in
                    debugPrint(r.result)
                    DispatchQueue.main.async {
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                        callback(false)
                    }
                }
            } else {
                AzureData.get(offerWithId: self.offers[indexPath.row].id) { r in
                    debugPrint(r.result)
                    DispatchQueue.main.async {
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                        callback(false)
                    }
                }
            }
        }
        
        action.backgroundColor = UIColor.blue
        
        return UISwipeActionsConfiguration(actions: [ action ] );
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        if !databasesSelected { return UISwipeActionsConfiguration.init(actions: [])}
        
        let action = UIContextualAction.init(style: .destructive, title: "Delete") { (action, view, callback) in
            AzureData.delete(self.databases[indexPath.row]) { r in
                DispatchQueue.main.async {
                    if r.result.isSuccess {
                        self.databases.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                    callback(r.result.isSuccess)
                }
            }
        }
        
        return UISwipeActionsConfiguration(actions: [ action ] );
    }

    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && databasesSelected {
            AzureData.delete(self.databases[indexPath.row]) { r in
                if r.result.isSuccess {
                    self.databases.remove(at: indexPath.row)
                    DispatchQueue.main.async { tableView.deleteRows(at: [indexPath], with: .automatic) }
                }
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return databasesSelected ? indexPath : nil
    }
    
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell, let index = tableView.indexPath(for: cell), let destinationViewController = segue.destination as? CollectionTableViewController {
            destinationViewController.database = databases[index.row]
        }
    }
}
