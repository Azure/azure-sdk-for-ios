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

import Foundation

#if !os(watchOS) && canImport(SystemConfiguration)

    import SystemConfiguration

    /// Defines the various connection types detected by reachability flags.
    ///
    /// - ethernetOrWiFi: The connection type is either over Ethernet or WiFi.
    /// - wwan:           The connection type is a WWAN connection.
    public enum ConnectionType {
        case ethernetOrWiFi
        case wwan
    }

    /// Defines the various states of network reachability.
    ///
    /// - unknown:      It is unknown whether the network is reachable.
    /// - notReachable: The network is not reachable.
    /// - reachable:    The network is reachable.
    public enum NetworkReachabilityStatus {
        case unknown
        case notReachable
        case reachable(ConnectionType)
    }

    /// A closure executed when the network reachability status changes. The closure takes a single argument: the
    /// network reachability status.
    public typealias ReachabilityStatusListener = (NetworkReachabilityStatus) -> Void

    /// The `ReachabilityManagerType` describes entities that listen for reachability changes of hosts
    /// and addresses for both WWAN and WiFi network interfaces.
    ///
    /// They can be used to determine background information about why a network operation failed, or to retry
    /// network requests when a connection is established. It should not be used to prevent a user from initiating
    /// a network request, as it's possible that an initial request may be required to establish reachability.
    public protocol ReachabilityManagerType {
        /// The current network reachability status.
        var networkReachabilityStatus: NetworkReachabilityStatus { get }

        /// Sets a closure executed when the network reachability status changes.
        func registerListener(_ listener: @escaping ReachabilityStatusListener)

        /// Starts listening for changes in network reachability status.
        ///
        /// - returns: `true` if listening was started successfully, `false` otherwise.
        @discardableResult
        func startListening() -> Bool

        /// Stops listening for changes in network reachability status.
        func stopListening()
    }

    public extension ReachabilityManagerType {
        /// Whether the network is currently reachable.
        var isReachable: Bool {
            return isReachableOnWWAN || isReachableOnEthernetOrWiFi
        }

        /// Whether the network is currently reachable over the WWAN interface.
        var isReachableOnWWAN: Bool {
            return networkReachabilityStatus == .reachable(.wwan)
        }

        /// Whether the network is currently reachable over Ethernet or WiFi interface.
        var isReachableOnEthernetOrWiFi: Bool {
            return networkReachabilityStatus == .reachable(.ethernetOrWiFi)
        }
    }

    // MARK: -

    extension NetworkReachabilityStatus: Equatable {}

    /// Returns whether the two network reachability status values are equal.
    ///
    /// - parameter lhs: The left-hand side value to compare.
    /// - parameter rhs: The right-hand side value to compare.
    ///
    /// - returns: `true` if the two values are equal, `false` otherwise.
    public func == (
        lhs: NetworkReachabilityStatus,
        rhs: NetworkReachabilityStatus
    )
        -> Bool
    {
        switch (lhs, rhs) {
        case (.unknown, .unknown):
            return true
        case (.notReachable, .notReachable):
            return true
        case let (.reachable(lhsConnectionType), .reachable(rhsConnectionType)):
            return lhsConnectionType == rhsConnectionType
        default:
            return false
        }
    }

#endif
