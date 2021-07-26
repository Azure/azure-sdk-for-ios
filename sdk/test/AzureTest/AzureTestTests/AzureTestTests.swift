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

@testable import AzureTest
import DVR
import Foundation
import XCTest

// swiftlint:disable force_try force_cast line_length
class AzureTestTests: XCTestCase {
    var fakeData: Data!

    var fakeRequest: URLRequest!

    var fakeResponse: URLResponse!

    var fakeResponseData: Data!

    let insertedGUID = "72f988bf-86f1-41af-91ab-2d7cd011db47"

    override func setUpWithError() throws {
        let testBundle = Bundle(for: type(of: self))
        let path = testBundle.path(forResource: "TestData", ofType: "json")
        fakeData = try! Data(contentsOf: URL(fileURLWithPath: path!))
    }

    func test_scrubbingRequest_removeSubscriptionIDs() throws {
        let dirtyURLString =
            "https://management.azure.com/subscriptions/\(insertedGUID)/resourceGroups/rgname/providers/Microsoft.KeyVault/vaults/myValtZikfikxz?api-version=2019-09-01"

        let cleanedURLString = SubscriptionIDFilter().scrubSubscriptionId(from: dirtyURLString)
        let shouldPass = !cleanedURLString.contains(regex: insertedGUID)
        XCTAssert(shouldPass)
    }

    func test_scrubbingResponse_removeSubscriptionIDs() throws {
        let dirtyHeaders =
            [
                "location": "[\"https://management.azure.com/subscriptions/\(insertedGUID)/providers/Microsoft.KeyVault/locations/eastus/operationResults/VVR8MDYzNzU0NDA3MTY0MzE2NTczMnwwNjZENTEwRTA4N0U0MTY5ODc1MDhDRDY3QUJDMzdGOQ?api-version=2019-09-01\"]"
            ]

        let dirtyBody = """
            "string": "{\"id\":\"/subscriptions/\(insertedGUID)/providers/Microsoft.KeyVault/locations/eastus/deletedVaults/myValtZikfikxz\",\"name\":\"myValtZikfikxz\",\"type\":\"Microsoft.KeyVault/deletedVaults\",\"properties\":{\"vaultId\":\"/subscriptions/72f988bf-86f1-41af-91ab-2d7cd011db47/resourceGroups/rgname/providers/Microsoft.KeyVault/vaults/myValtZikfikxz\",\"location\":\"eastus\",\"tags\":{},\"deletionDate\":\"2021-04-19T05:32:42Z\",\"scheduledPurgeDate\":\"2021-07-18T05:32:42Z\"}}"
        """

        let cleanLocation = SubscriptionIDFilter().scrubSubscriptionId(from: dirtyHeaders["location"]!)
        let cleanBody = SubscriptionIDFilter().scrubSubscriptionId(from: dirtyBody)

        let shouldPass = !cleanLocation.contains(regex: insertedGUID) && !cleanBody.contains(regex: insertedGUID)

        XCTAssert(shouldPass)
    }
}

private extension String {
    func dictionaryFromString() -> [String: Any] {
        let data = self.data(using: .utf8)
        return try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
    }

    func contains(
        regex pattern: String,
        regexOptions: NSRegularExpression.Options = [],
        matchingOptions: NSRegularExpression.MatchingOptions = []
    ) -> Bool {
        let regularExpression = try! NSRegularExpression(pattern: pattern, options: regexOptions)
        let range = NSRange(location: 0, length: utf8.count)
        return regularExpression.numberOfMatches(in: self, options: matchingOptions, range: range) > 0
    }
}
