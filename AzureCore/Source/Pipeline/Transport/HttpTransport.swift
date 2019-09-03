//
//  HttpTransport.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/29/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc public protocol HttpTransport: PipelineSendable {
    @objc func open()
    @objc func close()
    @objc func sleep(duration: Int)
}
