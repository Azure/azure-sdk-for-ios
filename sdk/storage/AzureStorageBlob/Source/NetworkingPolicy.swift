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
import Foundation

/// Describes the type of network connection
public enum NetworkType {
    case wifiOrEthernet
    case cellular
}

internal enum NetworkTypeInternal {
    case unknown
    case disconnected
    case wifiOrEthernet
    case cellular

    public var publicValue: NetworkType? {
        switch self {
        case .cellular:
            return .cellular
        case .wifiOrEthernet:
            return .wifiOrEthernet
        default:
            return nil
        }
    }
}

/// Describes the network state
public struct NetworkState {
    var type: NetworkType
}

public struct TransferNetworkPolicy {
    /// Permit transfers only on permitted values of `NetworkType`.
    public let transferOver: [NetworkType]

    public let enableAutoResume: Bool

    /// Method to determine whether a transfer should proceed
    public func shouldTransfer(withStatus status: NetworkType?) -> Bool {
        guard let networkStatus = status else { return false }
        return transferOver.contains(networkStatus)
    }

    public init(transferOver: [NetworkType], enableAutoResume: Bool) {
        self.transferOver = transferOver
        self.enableAutoResume = enableAutoResume
    }
}
