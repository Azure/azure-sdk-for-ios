//
//  PipelineLogger.swift
//  AzureCore
//
//  Created by Brandon Siegel on 10/3/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation
import os.log

public enum PipelineLogLevel: Int {
    case error, warning, info, debug
}

public protocol PipelineLogger {
    func debug(_: String)
    func info(_: String)
    func warning(_: String)
    func error(_: String)

    func log(_: String, atLevel: PipelineLogLevel)
}

extension PipelineLogger {
    public func debug(_ message: String) {
        log(message, atLevel: .debug)
    }

    public func info(_ message: String) {
        log(message, atLevel: .info)
    }

    public func warning(_ message: String) {
        log(message, atLevel: .warning)
    }

    public func error(_ message: String) {
        log(message, atLevel: .error)
    }
}

// MARK: - Implementations

public class PipelinePrintLogger: PipelineLogger {
    private let logLevel: PipelineLogLevel

    public init(logLevel: PipelineLogLevel = .warning) {
        self.logLevel = logLevel
    }

    public func log(_ message: String, atLevel messageLevel: PipelineLogLevel) {
        if messageLevel.rawValue >= logLevel.rawValue {
            let tag = String(describing: messageLevel).uppercased()
            print("\(tag): \(message)")
        }
    }
}

public class PipelineNSLogger: PipelineLogger {
    private let logLevel: PipelineLogLevel

    public init(logLevel: PipelineLogLevel = .warning) {
        self.logLevel = logLevel
    }

    public func log(_ message: String, atLevel messageLevel: PipelineLogLevel) {
        if messageLevel.rawValue >= logLevel.rawValue {
            let tag = String(describing: messageLevel).uppercased()
            NSLog("%@: %@", tag, message)
        }
    }
}

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
public class PipelineOSLogAdapter: PipelineLogger {
    private let osLogger: OSLog

    public init(withLogger osLogger: OSLog) {
        self.osLogger = osLogger
    }

    public convenience init(subsystem: String = "com.azure", category: String = "Pipeline") {
        self.init(withLogger: OSLog(subsystem: subsystem, category: category))
    }

    public func log(_ message: String, atLevel messageLevel: PipelineLogLevel) {
        os_log("%@", log: osLogger, type: osLogTypeFor(messageLevel), message)
    }

    private func osLogTypeFor(_ level: PipelineLogLevel) -> OSLogType {
        switch level {
        case .error:
            return .error
        case .warning:
            // os_log has no 'warning', mapped to 'error' as per suggestion by
            // https://forums.swift.org/t/logging-levels-for-swifts-server-side-logging-apis-and-new-os-log-apis/20365
            return .error
        case .info:
            return .info
        case .debug:
            return .debug
        }
    }
}
