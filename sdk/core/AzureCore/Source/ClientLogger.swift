// --------------------------------------------------------------------------
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//
// The MIT License (MIT)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the ""Software""), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
// sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED *AS IS*, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
// IN THE SOFTWARE.
//
// --------------------------------------------------------------------------

import Foundation
import os.log

public enum ClientLogLevel: Int {
    case error, warning, info, debug
}

public protocol ClientLogger {
    // MARK: Required Properties

    var level: ClientLogLevel { get set }

    // MARK: Required Methods

    func debug(_: @autoclosure @escaping () -> String?)
    func info(_: @autoclosure @escaping () -> String?)
    func warning(_: @autoclosure @escaping () -> String?)
    func error(_: @autoclosure @escaping () -> String?)

    func log(_: () -> String?, atLevel: ClientLogLevel)
}

public extension ClientLogger {
    func debug(_ message: @escaping () -> String?) {
        log(message, atLevel: .debug)
    }

    func info(_ message: @escaping () -> String?) {
        log(message, atLevel: .info)
    }

    func warning(_ message: @escaping () -> String?) {
        log(message, atLevel: .warning)
    }

    func error(_ message: @escaping () -> String?) {
        log(message, atLevel: .error)
    }
}

// MARK: - Constants

public enum ClientLoggers {
    // MARK: Properties

    public static let none: ClientLogger = NullClientLogger()

    // MARK: Static Methods

    public static func `default`(tag: String, level: ClientLogLevel = .info) -> ClientLogger {
        if #available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
            return OSLogger(category: tag, level: level)
        } else {
            return NSLogger(tag: tag, level: level)
        }
    }
}

// MARK: - Implementations

public class NullClientLogger: ClientLogger {
    // MARK: Properties

    // Force the least verbose log level so consumers can check & avoid calling the logger entirely if desired
    public var level: ClientLogLevel {
        get { return .error }
        set { _ = newValue }
    }

    // MARK: Public Methods

    public func log(_: () -> String?, atLevel _: ClientLogLevel) {}
}

public class PrintLogger: ClientLogger {
    // MARK: Properties

    public var level: ClientLogLevel

    private let tag: String

    // MARK: Initializers

    public init(tag: String, level: ClientLogLevel = .info) {
        self.tag = tag
        self.level = level
    }

    // MARK: Public Methods

    public func log(_ message: () -> String?, atLevel messageLevel: ClientLogLevel) {
        if messageLevel.rawValue <= level.rawValue, let msg = message() {
            let levelString = String(describing: messageLevel).uppercased()
            print("[\(levelString)] \(tag): \(msg)")
        }
    }
}

public class NSLogger: ClientLogger {
    // MARK: Properties

    public var level: ClientLogLevel

    private let tag: String

    // MARK: Initializers

    public init(tag: String, level: ClientLogLevel = .info) {
        self.tag = tag
        self.level = level
    }

    // MARK: Public Methods

    public func log(_ message: () -> String?, atLevel messageLevel: ClientLogLevel) {
        if messageLevel.rawValue <= level.rawValue, let msg = message() {
            let levelString = String(describing: messageLevel).uppercased()
            NSLog("[%@] %@: %@", levelString, tag, msg)
        }
    }
}

@available(macOS 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *)
public class OSLogger: ClientLogger {
    // MARK: Properties

    public var level: ClientLogLevel

    private let osLogger: OSLog

    // MARK: Initializers

    public init(withLogger osLogger: OSLog, level: ClientLogLevel = .info) {
        self.level = level
        self.osLogger = osLogger
    }

    public init(
        subsystem: String = "com.azure",
        category: String,
        level: ClientLogLevel = .info
    ) {
        self.osLogger = OSLog(subsystem: subsystem, category: category)
        self.level = level
    }

    // MARK: Public Methods

    public func log(_ message: () -> String?, atLevel messageLevel: ClientLogLevel) {
        if messageLevel.rawValue <= level.rawValue, let msg = message() {
            os_log("%@", log: osLogger, type: osLogTypeFor(messageLevel), msg)
        }
    }

    // MARK: Private Methods

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
