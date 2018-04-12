//
//  Extensions.swift
//  AzureData iOS Example
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import UIKit
import AzureData

extension UITableViewController {
    
    func showErrorAlert (_ error: Error) {
        
        var title = "Error"
        var message = error.localizedDescription
        
        if let documentError = error as? DocumentClientError {
            title += ": \(documentError.kind)"
            message = documentError.message
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alertController, animated: true) { }
    }
}
