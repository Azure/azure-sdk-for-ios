//
//  PermissionTableViewController.swift
//  AzureData iOS Example
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AzureData

class PermissionTableViewController: UITableViewController {

    @IBOutlet weak var addButton: UIBarButtonItem!
    
    var user: User!
    var collection: DocumentCollection!
    var database: Database!
    
    var permissions: [Permission] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshData()
        
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
    }
    
    
    func refreshData() {
        user.getPermissions { r in
            debugPrint(r.result)
            DispatchQueue.main.async {
                if let items = r.resource?.items {
                    self.permissions = items
                    self.tableView.reloadData()
                } else if let error = r.error {
                    self.showErrorAlert(error)
                }
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    
    @IBAction func addButtonTouchUpInside(_ sender: Any) {
        
        let alertController = UIAlertController(title: "New Database Permission", message: "Enter the following information for the new Permission", preferredStyle: .alert)
        
        alertController.addTextField() { textField in
            textField.placeholder = "Permission ID (no spaces)"
            textField.returnKeyType = .next
        }
        
        alertController.addTextField() { textField in
            textField.text = "Read"
            textField.placeholder = "Read or All"
            textField.returnKeyType = .done
        }
        
        alertController.addAction(UIAlertAction(title: "Create", style: .default) { a in
            
            if let id = alertController.textFields?.first?.text, let mode = alertController.textFields?.last?.text {
                debugPrint("id: \(id)")
                debugPrint("mode: \(mode)")
                
                self.user.create(permissionWithId: id, mode: .read, forUser: self.user) { r in
                    debugPrint(r.result)
                    DispatchQueue.main.async {
                        if let permission = r.resource {
                            self.permissions.append(permission)
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
    
    
    @IBAction func refreshControlValueChanged(_ sender: Any) { refreshData() }
    
    
    
    // MARK: - Table view data source
    
    
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return permissions.count }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resourceCell", for: indexPath)
        
        let permission = permissions[indexPath.row]
        
        cell.textLabel?.text = permission.id
        cell.detailTextLabel?.text = permission.resourceId
        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction.init(style: .normal, title: "Get") { (action, view, callback) in
            self.user.get(permissionWithId: self.permissions[indexPath.row].id) { r in
                debugPrint(r.result)
                DispatchQueue.main.async {
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    callback(false)
                }
            }
        }
        
        action.backgroundColor = UIColor.blue
        
        return UISwipeActionsConfiguration(actions: [ action ] );
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction.init(style: .destructive, title: "Delete") { (action, view, callback) in
            self.deleteResource(at: indexPath, from: tableView, callback: callback)
        }
        return UISwipeActionsConfiguration(actions: [ action ] );
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteResource(at: indexPath, from: tableView)
        }
    }

    
    func deleteResource(at indexPath: IndexPath, from tableView: UITableView, callback: ((Bool) -> Void)? = nil) {
        AzureData.delete(permissions[indexPath.row]) { r in
            DispatchQueue.main.async {
                if r.result.isSuccess {
                    self.permissions.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                callback?(r.result.isSuccess)
            }
        }
    }
}
