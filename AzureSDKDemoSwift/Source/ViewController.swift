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

class ViewController: UIViewController {

    @IBOutlet weak var textLabel: UILabel!

    private let connectionString = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let client = try? AppConfigurationClient(connectionString: connectionString) else { return }
        let raw = HttpResponse()
        do {
            if let settings = try client.getConfigurationSettings(forKey: nil, forLabel: nil, withResponse: raw) {
                textLabel.textColor = .black
                var text = "\(raw.statusCode!)"
                for item in settings.items {
                    text = "\(text)\n\(item.key) : \(item.value)"
                }
                textLabel.text = text
            } else {
                textLabel.textColor = .red
                textLabel.text = "No settings found..."
            }
        } catch {
            textLabel.textColor = .red
            textLabel.text = error.localizedDescription
        }
    }

}
