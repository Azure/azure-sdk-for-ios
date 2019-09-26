//
//  SettingTableViewCell.swift
//  AzureSDKDemoSwift
//
//  Created by Travis Prescott on 9/26/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import UIKit

class SettingTableViewCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var keyLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
