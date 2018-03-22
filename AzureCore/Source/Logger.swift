//
//  Logger.swift
//  AzureCore
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Willow


public var log: Logger? = Logger(logLevels: [.all], writers: [OSLogWriter(subsystem: "com.azure.core", category: "azure")])
