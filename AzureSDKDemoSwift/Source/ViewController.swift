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

    private let connectionString = "Endpoint=https://tjpappconfig.azconfig.io;Id=2-l0-s0:zSvXZtO9L9bv9s3QVyD3;Secret=FzxmbflLwAt5+2TUbnSIsAuATyY00L+GFpuxuJZRmzI="

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let client = try? AppConfigurationClient(connectionString: connectionString) else { return }
        client.getConfigurationSettings(forKey: nil, forLabel: nil, completion: { result, httpResponse in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.textLabel.textColor = .red
                    self?.textLabel.text = "\(error.localizedDescription) - \(error)"
                }
            case .success(let settings):
                var text = ""
                if let statusCode = httpResponse.statusCode {
                    text = "\(statusCode)"
                } else {
                    text = "UNKNOWN STATUS"
                }
                var count = 0
                for item in settings {
                    count += 1
                    text = "\(text)\n\(item.key) : \(item.value)"
                }
                os_log("%i settings!", count)
                DispatchQueue.main.async { [weak self] in
                    self?.textLabel.textColor = .black
                    self?.textLabel.text = text
                }
            }
        })
    }
}
