//
//  StoredProcedureTableViewController.swift
//  AzureData iOS Example
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AzureData

class StoredProcedureTableViewController: UITableViewController {

    @IBOutlet var addButton: UIBarButtonItem!
    
    var database: Database!
    var collection: DocumentCollection!

    var resources:  [StoredProcedure] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItems = [addButton, editButtonItem]


        NotificationCenter.default.addObserver(forName: .ResourceWriteOperationQueueProcessed, object: nil, queue: nil) { [weak self] _ in
            DispatchQueue.main.async {
                self?.refreshData()
            }
        }
    }

    
    func refreshData() {
        collection.getStoredProcedures { r in
            debugPrint(r.result)
            DispatchQueue.main.async {
                if let items = r.resource?.items {
                    self.resources = items
                    self.tableView.reloadData()
                } else if let error = r.error {
                    self.showErrorAlert(error)
                }
                self.refreshControl?.endRefreshing()
            }
        }
    }

        
    @IBAction func addButtonTouchUpInside(_ sender: Any) {
        
        let storedProcedure = """
        function () {
            var context = getContext();
            var r = context.getResponse();

            r.setBody(\"Hello World!\");
        }
        """
        
        collection.create(storedProcedureWithId: "helloWorld", andBody: storedProcedure) { r in
            debugPrint(r.result)
            DispatchQueue.main.async {
                if let storedProcedure = r.resource {
                    self.resources.append(storedProcedure)
                    self.tableView.reloadData()
                } else if let error = r.error {
                    self.showErrorAlert(error)
                }
            }
        }
    }
    
    
    @IBAction func refreshControlValueChanged(_ sender: Any) { refreshData() }
    
    
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return resources.count }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resourceCell", for: indexPath)
        
        let resource = resources[indexPath.row]
        
        cell.textLabel?.text = resource.id
        cell.detailTextLabel?.text = resource.resourceId
        
        return cell
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
        collection.delete(self.resources[indexPath.row]) { r in
            DispatchQueue.main.async {
                if r.result.isSuccess {
                    self.resources.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                callback?(r.result.isSuccess)
            }
        }
    }

    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let procedure = resources[indexPath.row]
        
        AzureData.execute(storedProcedureWithId: procedure.id, usingParameters: nil, inCollection: collection.id, inDatabase: database.id) { r in
            if let data = r.data {
                if let string = String(data: data, encoding: .utf8) {
                    print(string)
                } else {
                    print(data)
                }
            } else {
                print("error")
            }
        }
    }
}
