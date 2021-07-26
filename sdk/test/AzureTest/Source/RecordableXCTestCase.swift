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

import AzureCore
import XCTest

open class RecordableXCTestCase<SettingsType: TestSettingsProtocol>: XCTestCase {
    public let settings = {
        SettingsType.loadFromPlist()
    }()

    public var transportOptions: TransportOptions {
        return TransportOptions(transport: transport)
    }

    private var transport: TransportStage!

    private var mode = environmentVariable(forKey: "TEST_MODE", default: "playback")

    override public final func setUp() {}

    override public final func setUpWithError() throws {
        let fullname = name
        var testName = fullname.split(separator: " ")[1]
        testName.removeLast()
        transport = mode != "live" ? DVRSessionTransport(cassetteName: String(testName)) : URLSessionTransport()
        try setUpTestWithError()
        transport?.open()
    }

    /// Method which the test author can override to configure setup
    open func setUpTestWithError() throws {}

    override public final func tearDownWithError() throws {}

    override public final func tearDown() {
        transport?.close()
    }

    /// Method which the test author can override to configure setup
    open func tearDownTestWithError() throws {}
}
