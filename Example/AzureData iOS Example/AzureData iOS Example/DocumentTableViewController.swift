//
//  DocumentTableViewController.swift
//  AzureData iOS Example
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AzureData

class DocumentTableViewController: UITableViewController {

    @IBOutlet var addButton: UIBarButtonItem!
    
    var database: Database!
    var collection: DocumentCollection!
    
    var documents: [documentType] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshData()
        
        navigationItem.rightBarButtonItems = [addButton, editButtonItem]
        

        NotificationCenter.default.addObserver(forName: .ResourceWriteOperationQueueProcessed, object: nil, queue: nil) { [weak self] _ in
            DispatchQueue.main.async {
                self?.refreshData()
            }
        }
    }

    
    func refreshData() {
        
        collection.get(documentsAs: documentType.self) { response in
            debugPrint(response.result)
            DispatchQueue.main.async {
                if let items = response.resource?.items {
                    self.documents = items
                    self.tableView.reloadData()
                } else if let error = response.error {
                    self.showErrorAlert(error)
                }
                self.refreshControl?.endRefreshing()
            }
        }
    }

    
    @IBAction func refreshControlValueChanged(_ sender: Any) { refreshData() }
    
    
    @IBAction func addButtonTouchUpInside(_ sender: Any) {
        
//        let query =  Query.select()
//                            .from(collection.id)
//                            .where("firstName", is: "Colby")
//                            .and("lastName", is: "Williams")
//                            .and("age", isGreaterThanOrEqualTo: 20)
//                            .orderBy("_etag", descending: true)
//        
        //AzureData.query(query(documentsIn: collection.id, inDatabase: database.id, with: query) { r in
//        collection.queryDocuments(with: query) { r in
//            debugPrint(r.result)
//            if let items = r.resource?.items {
//                for item in items { item.printLog() }
//            } else if let error = r.error {
//                self.showErrorAlert(error)
//            }
//        }
//        
//        return
        
        let doc = documentType()
        
//        doc["testNumber"] = 1_000_000
//        doc["testString"] = "Yeah baby\nRock n Roll"
//        doc["testDate"]   = Date()
        
        collection.create(doc) { r in
            debugPrint(r.result)
            DispatchQueue.main.async {
                if let document = r.resource {
                    self.documents.append(document)
                    self.tableView.reloadData()
                } else if let error = r.error {
                    self.showErrorAlert(error)
                }
            }
        }
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { return 1 }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return documents.count }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "resourceCell", for: indexPath)

        let resource = documents[indexPath.row]
        
        cell.textLabel?.text = resource.id
        cell.detailTextLabel?.text = resource.resourceId
        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action = UIContextualAction.init(style: .normal, title: "Get") { (action, view, callback) in
            
            self.documents[indexPath.row].refresh { r in
                DispatchQueue.main.async {
                    if r.result.isSuccess {
                        debugPrint(r.result)
                        tableView.reloadRows(at: [indexPath], with: .automatic)
                        callback(false)
                    } else if let error = r.error {
                        self.showErrorAlert(error)
                        callback(false)
                    }
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

        collection.delete(documents[indexPath.row]) { r in
            DispatchQueue.main.async {
                if r.result.isSuccess {
                    self.documents.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                callback?(r.result.isSuccess)
            }
        }
    }
    
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath.section == 0 ? indexPath : nil
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell, let index = tableView.indexPath(for: cell), let destinationViewController = segue.destination as? DocumentDetailTableViewController {
            destinationViewController.document = documents[index.row]
        }
    }
}
