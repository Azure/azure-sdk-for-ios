//
//  ClientLogger.swift
//  AzureCore
//
//  Created by Brandon Siegel on 10/3/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import Foundation
import os.log

public enum ClientLogLevel: Int {
    case error, warning, info, debug
}

public protocol ClientLogger {
    var level: ClientLogLevel { get set }

    func debug(_: String)
    func info(_: String)
    func warning(_: String)
    func error(_: String)

    func log(_: String, atLevel: ClientLogLevel)
}

extension ClientLogger {
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

    public static func `default`() -> ClientLogger {
        if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
            return OSLogAdapter()
        } else {
            return NSLogger()
        }
    }
}

// MARK: - Implementations

public class NullLogger: ClientLogger {
    public var level: ClientLogLevel = .warning

    public init() { }

    public func log(_ message: String, atLevel messageLevel: ClientLogLevel) { }
}

public class PrintLogger: ClientLogger {
    public var level: ClientLogLevel

    public init(level: ClientLogLevel = .warning) {
        self.level = level
    }

    public func log(_ message: String, atLevel messageLevel: ClientLogLevel) {
        if messageLevel.rawValue >= level.rawValue {
            let tag = String(describing: messageLevel).uppercased()
            print("\(tag): \(message)")
        }
    }
}

public class NSLogger: ClientLogger {
    public var level: ClientLogLevel

    public init(level: ClientLogLevel = .warning) {
        self.level = level
    }

    public func log(_ message: String, atLevel messageLevel: ClientLogLevel) {
        if messageLevel.rawValue >= level.rawValue {
            let tag = String(describing: messageLevel).uppercased()
            NSLog("%@: %@", tag, message)
        }
    }
}

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
public class OSLogAdapter: ClientLogger {
    public var level: ClientLogLevel = .warning

    private let osLogger: OSLog

    public init(withLogger osLogger: OSLog) {
        self.osLogger = osLogger
    }

    public convenience init(subsystem: String = "com.azure", category: String = "Pipeline") {
        self.init(withLogger: OSLog(subsystem: subsystem, category: category))
    }

    public func log(_ message: String, atLevel messageLevel: ClientLogLevel) {
        os_log("%@", log: osLogger, type: osLogTypeFor(messageLevel), message)
    }

    private func osLogTypeFor(_ level: ClientLogLevel) -> OSLogType {
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
