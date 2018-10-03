//
//  Logger.swift
//  AzureCore
//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Foundation
import Willow


public class Log {

    public static var willowLogger: Willow.Logger = Willow.Logger(logLevels: [.all], writers: [OSLogWriter(subsystem: "com.azure.core", category: "azure")])
    
    // MARK: - Log String Messages

    /// Writes out the given message using the logger if the debug log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    public static func debug(_ message: @autoclosure @escaping () -> String) {
        willowLogger.logMessage(message, with: LogLevel.debug)
    }

    /// Writes out the given message using the logger if the debug log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    public static func debug(_ message: @escaping () -> String) {
        willowLogger.logMessage(message, with: LogLevel.debug)
    }

    /// Writes out the given message using the logger if the info log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    public static func info(_ message: @autoclosure @escaping () -> String) {
        willowLogger.logMessage(message, with: LogLevel.info)
    }

    /// Writes out the given message using the logger if the info log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    public static func info(_ message: @escaping () -> String) {
        willowLogger.logMessage(message, with: LogLevel.info)
    }

    /// Writes out the given message using the logger if the event log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    public static func event(_ message: @autoclosure @escaping () -> String) {
        willowLogger.logMessage(message, with: LogLevel.event)
    }

    /// Writes out the given message using the logger if the event log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    public static func event(_ message: @escaping () -> String) {
        willowLogger.logMessage(message, with: LogLevel.event)
    }

    /// Writes out the given message using the logger if the warn log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    public static func warn(_ message: @autoclosure @escaping () -> String) {
        willowLogger.logMessage(message, with: LogLevel.warn)
    }

    /// Writes out the given message using the logger if the warn log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    public static func warn(_ message: @escaping () -> String) {
        willowLogger.logMessage(message, with: LogLevel.warn)
    }

    /// Writes out the given message using the logger if the error log level is set.
    ///
    /// - Parameter message: An autoclosure returning the message to log.
    public static func error(_ message: @autoclosure @escaping () -> String) {
        willowLogger.logMessage(message, with: LogLevel.error)
    }

    /// Writes out the given message using the logger if the error log level is set.
    ///
    /// - Parameter message: A closure returning the message to log.
    public static func error(_ message: @escaping () -> String) {
        willowLogger.logMessage(message, with: LogLevel.error)
    }
}
