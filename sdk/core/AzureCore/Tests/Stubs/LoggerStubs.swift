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

@testable import AzureCore
import Foundation

extension ClientLoggers {
    public static func `default`() -> ClientLogger {
        return ClientLoggers.default(tag: defaultTag())
    }

    static func defaultTag() -> String {
        let regex = NSRegularExpression("^\\d*\\s*([a-zA-Z]*)\\s")
        let defaultTag = regex.firstMatch(in: Thread.callStackSymbols[1])
        return defaultTag ?? "AzureCore"
    }
}

class TestClientLogger: ClientLogger {
    struct Message {
        var level: ClientLogLevel
        var text: String
    }

    var level: ClientLogLevel
    var messages: [Message] = []

    public init(_ logLevel: ClientLogLevel = .info) {
        self.level = logLevel
    }

    public func log(_ message: () -> String?, atLevel messageLevel: ClientLogLevel) {
        if messageLevel.rawValue <= level.rawValue, let msg = message() {
            messages.append(Message(level: messageLevel, text: msg))
        }
    }
}
