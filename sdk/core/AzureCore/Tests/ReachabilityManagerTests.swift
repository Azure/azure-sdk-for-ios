// --------------------------------------------------------------------------
//
//  Copyright (c) 2014-2018 Alamofire Software Foundation (http://alamofire.org/)
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
import SystemConfiguration
import XCTest

class ReachabilityManagerTests: XCTestCase {
    let timeout: TimeInterval = 30.0

    // MARK: - Tests - Initialization

    func test_Manager_CanBeInitializedFromHost() {
        // Given, When
        let manager = ReachabilityManager(host: "localhost")

        // Then
        XCTAssertNotNil(manager)
    }

    func test_ManagerCanBeInitializedFromAddress() {
        // Given, When
        let manager = ReachabilityManager()

        // Then
        XCTAssertNotNil(manager)
    }

    func test_HostManager_IsReachableOnWiFi() {
        // Given, When
        let manager = ReachabilityManager(host: "localhost")

        // Then
        XCTAssertEqual(manager?.networkReachabilityStatus, .reachable(.ethernetOrWiFi))
        XCTAssertEqual(manager?.isReachable, true)
        XCTAssertEqual(manager?.isReachableOnWWAN, false)
        XCTAssertEqual(manager?.isReachableOnEthernetOrWiFi, true)
    }

    func test_HostManager_StartsWithReachableStatus() {
        // Given, When
        let manager = ReachabilityManager(host: "localhost")

        // Then
        XCTAssertEqual(manager?.networkReachabilityStatus, .reachable(.ethernetOrWiFi))
        XCTAssertEqual(manager?.isReachable, true)
        XCTAssertEqual(manager?.isReachableOnWWAN, false)
        XCTAssertEqual(manager?.isReachableOnEthernetOrWiFi, true)
    }

    func test_AddressManager_StartsWithReachableStatus() {
        // Given, When
        let manager = ReachabilityManager()

        // Then
        XCTAssertEqual(manager?.networkReachabilityStatus, .reachable(.ethernetOrWiFi))
        XCTAssertEqual(manager?.isReachable, true)
        XCTAssertEqual(manager?.isReachableOnWWAN, false)
        XCTAssertEqual(manager?.isReachableOnEthernetOrWiFi, true)
    }

    func test_HostManager_CanBeDeinitialized() {
        // Given
        var manager: ReachabilityManager? = ReachabilityManager(host: "localhost")

        // When
        manager = nil

        // Then
        XCTAssertNil(manager)
    }

    func test_AddressManager_CanBeDeinitialized() {
        // Given
        var manager: ReachabilityManager? = ReachabilityManager()

        // When
        manager = nil

        // Then
        XCTAssertNil(manager)
    }

    // MARK: - Tests - Listener

    func test_HostManager_IsNotifiedWhenStartListeningIsCalled() {
        // Given
        guard let manager = ReachabilityManager(host: "store.apple.com") else {
            XCTFail("manager should NOT be nil")
            return
        }

        let expectation = self.expectation(description: "listener closure should be executed")
        var networkReachabilityStatus: NetworkReachabilityStatus?

        manager.listener = { status in
            guard networkReachabilityStatus == nil else { return }
            networkReachabilityStatus = status
            expectation.fulfill()
        }

        // When
        manager.startListening()
        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(networkReachabilityStatus, .reachable(.ethernetOrWiFi))
    }

    func test_AddressManager_IsNotifiedWhenStartListeningIsCalled() {
        // Given
        let manager = ReachabilityManager()
        let expectation = self.expectation(description: "listener closure should be executed")

        var networkReachabilityStatus: NetworkReachabilityStatus?

        manager?.listener = { status in
            networkReachabilityStatus = status
            expectation.fulfill()
        }

        // When
        manager?.startListening()
        waitForExpectations(timeout: timeout, handler: nil)

        // Then
        XCTAssertEqual(networkReachabilityStatus, .reachable(.ethernetOrWiFi))
    }

    // MARK: - Tests - Network ReachabilityManager Status

    func test_Manager_ReturnsNotReachableStatusWhenReachableFlagIsAbsent() {
        // Given
        let manager = ReachabilityManager()
        let flags: SCNetworkReachabilityFlags = [.connectionOnDemand]

        // When
        let networkReachabilityStatus = manager?.networkReachabilityStatusForFlags(flags)

        // Then
        XCTAssertEqual(networkReachabilityStatus, .notReachable)
    }

    func test_Manager_ReturnsNotReachableStatusWhenConnectionIsRequired() {
        // Given
        let manager = ReachabilityManager()
        let flags: SCNetworkReachabilityFlags = [.reachable, .connectionRequired]

        // When
        let networkReachabilityStatus = manager?.networkReachabilityStatusForFlags(flags)

        // Then
        XCTAssertEqual(networkReachabilityStatus, .notReachable)
    }

    func test_Manager_ReturnsNotReachableStatusWhenInterventionIsRequired() {
        // Given
        let manager = ReachabilityManager()
        let flags: SCNetworkReachabilityFlags = [.reachable, .connectionRequired, .interventionRequired]

        // When
        let networkReachabilityStatus = manager?.networkReachabilityStatusForFlags(flags)

        // Then
        XCTAssertEqual(networkReachabilityStatus, .notReachable)
    }

    func test_Manager_ReturnsReachableOnWiFiStatusWhenConnectionIsNotRequired() {
        // Given
        let manager = ReachabilityManager()
        let flags: SCNetworkReachabilityFlags = [.reachable]

        // When
        let networkReachabilityStatus = manager?.networkReachabilityStatusForFlags(flags)

        // Then
        XCTAssertEqual(networkReachabilityStatus, .reachable(.ethernetOrWiFi))
    }

    func test_Manager_ReturnsReachableOnWiFiStatusWhenConnectionIsOnDemand() {
        // Given
        let manager = ReachabilityManager()
        let flags: SCNetworkReachabilityFlags = [.reachable, .connectionRequired, .connectionOnDemand]

        // When
        let networkReachabilityStatus = manager?.networkReachabilityStatusForFlags(flags)

        // Then
        XCTAssertEqual(networkReachabilityStatus, .reachable(.ethernetOrWiFi))
    }

    func test_Manager_ReturnsReachableOnWiFiStatusWhenConnectionIsOnTraffic() {
        // Given
        let manager = ReachabilityManager()
        let flags: SCNetworkReachabilityFlags = [.reachable, .connectionRequired, .connectionOnTraffic]

        // When
        let networkReachabilityStatus = manager?.networkReachabilityStatusForFlags(flags)

        // Then
        XCTAssertEqual(networkReachabilityStatus, .reachable(.ethernetOrWiFi))
    }

    #if os(iOS)
        func test_Manager_ReturnsReachableOnWWANStatusWhenIsWWAN() {
            // Given
            let transferManager = ReachabilityManager()
            let flags: SCNetworkReachabilityFlags = [.reachable, .isWWAN]

            // When
            let networkReachabilityStatus = transferManager?.networkReachabilityStatusForFlags(flags)

            // Then
            XCTAssertEqual(networkReachabilityStatus, .reachable(.wwan))
        }

        func test_Manager_ReturnsNotReachableOnWWANStatusWhenIsWWANAndConnectionIsRequired() {
            // Given
            let transferManager = ReachabilityManager()
            let flags: SCNetworkReachabilityFlags = [.reachable, .isWWAN, .connectionRequired]

            // When
            let networkReachabilityStatus = transferManager?.networkReachabilityStatusForFlags(flags)

            // Then
            XCTAssertEqual(networkReachabilityStatus, .notReachable)
        }
    #endif
}
