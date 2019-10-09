//
//  SettingTableViewCell.swift
//  AzureSDKDemoSwift
//
//  Created by Travis Prescott on 9/26/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    // MARK: Properties

    @IBOutlet var keyLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        DispatchQueue.main.async {
            super.setSelected(selected, animated: animated)
        }
    }
}
