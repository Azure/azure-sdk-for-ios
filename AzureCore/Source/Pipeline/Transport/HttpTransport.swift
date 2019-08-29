//
//  HttpTransport.swift
//  AzureCore
//
//  Created by Travis Prescott on 8/29/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

@objc protocol HttpTransportProtocol {
    @objc func send(request: PipelineRequest) -> PipelineResponse
    @objc func open()
    @objc func close()
    @objc func sleep(duration: Int)
}

@objc public class HttpTransport: NSObject {
    @objc public final func sleep(duration: Int) {
        Foundation.sleep(UInt32(duration))
    }
}
