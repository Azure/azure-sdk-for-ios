//
//  Constants.swift
//  AzureSDKDemoSwift
//
//  Created by Travis Prescott on 10/7/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation

struct AppConstants {
    // read-only connection string
    static let appConfigConnectionString = "Endpoint=https://tjpappconfig.azconfig.io;Id=2-l0-s0:zSvXZtO9L9bv9s3QVyD3;Secret=FzxmbflLwAt5+2TUbnSIsAuATyY00L+GFpuxuJZRmzI="

    // read-only blob connection string using a SAS token
    static let blobConnectionString = "BlobEndpoint=https://tjpstorage1.blob.core.windows.net/;QueueEndpoint=https://tjpstorage1.queue.core.windows.net/;FileEndpoint=https://tjpstorage1.file.core.windows.net/;TableEndpoint=https://tjpstorage1.table.core.windows.net/;SharedAccessSignature=sv=2018-03-28&ss=b&srt=sco&sp=rl&se=2020-10-03T07:45:02Z&st=2019-10-02T23:45:02Z&spr=https&sig=L7zqOTStAd2o3Mp72MW59GXM1WbL9G2FhOSXHpgrBCE%3D"
    static let storageAccountName = "tjpstorage1"
    static let storageBaseUrl = "https://tjpstorage1.blob.core.windows.net"
}
