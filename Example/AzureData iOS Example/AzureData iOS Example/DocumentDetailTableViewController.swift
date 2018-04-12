//
//  DocumentDetailTableViewController.swift
//  AzureData iOS Example
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import AzureData

class DocumentDetailTableViewController: UITableViewController {

    var document: documentType? = nil

    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int { return 2 }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 6 // system properties
        case 1: return document?.extraItemCount ?? 0
        default: return 0
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "documentDetailCell", for: indexPath)

        let data = document?.detail(for: indexPath)
        
        cell.textLabel?.text = data?.title
        cell.detailTextLabel?.text = data?.detail

        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "System Properties"
        case 1: return "User Properties"
        default: return nil
        }
    }
}


fileprivate extension documentType {
    
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX"
        return formatter
    }()
    
    func detail(for index: IndexPath) -> (title: String, detail: String) {
        
        var title = "nil"
        var detail = "nil"
        
        switch index.section {
        case 0: // system properties
            switch index.row {
            case 0: title = "id"; detail = self.id
            case 1: title = "resourceId"; detail = self.resourceId
            case 2: title = "selfLink"; detail = self.selfLink ?? "nil"
            case 3: title = "etag"; detail = self.etag ?? "nil"
            case 4: title = "timestamp"; detail = self.timestampString
            case 5: title = "attachmentsLink"; detail = self.attachmentsLink ?? "nil"
            default: break
            }
        case 1: // custom properties
            let item = self.itemAt(index: index.row)
            title = item.title
            detail = item.detail
        default: break
        }
        
        return (title, detail)
    }
    
    var extraItemCount: Int {
        
        //return self.data?.count ?? 0
        
        return 3
    }
    
    func itemAt(index i: Int) -> (title: String, detail: String) {
        switch i {
        case 0: return ("testNumber", "\(testNumber ?? 0)")
        case 1: return ("testDate", "\(testDate?.description ?? "nil")")
        case 2: return ("testString", "\(testString ?? "nil")")
        default: return("nil", "nil")
        }
    }
    
//    func itemAt(index i: Int) -> (title: String, detail: String) {
//        var title = "nil"
//        var detail = "nil"
//
//        if let data = self.data {
//            title = Array(data.dictionary.keys)[i]
//            if let d = Array(data.dictionary.values)[i] {
//                detail = "\(d)"
//            }
//        }
//
//        return(title, detail)
//    }

    var timestampString: String {
        if let ts = self.timestamp {
            return documentType.dateFormatter.string(from: ts)
        }
        return "nil"
    }
}
