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

import CoreData
import Foundation

public enum TransferState: Int16 {
    case pending, inProgress, paused, complete, failed, canceled, deleted

    public var label: String {
        switch self {
        case .pending:
            return "Pending"
        case .inProgress:
            return "In Progress"
        case .paused:
            return "Paused"
        case .complete:
            return "Complete"
        case .failed:
            return "Failed"
        case .canceled:
            return "Canceled"
        case .deleted:
            return "Deleted"
        }
    }

    public var pauseable: Bool {
        switch self {
        case .pending, .inProgress:
            return true
        case .paused, .complete, .canceled, .deleted, .failed:
            return false
        }
    }

    public var resumable: Bool {
        switch self {
        case .paused, .failed:
            return true
        case .pending, .inProgress, .complete, .canceled, .deleted:
            return false
        }
    }
}

public enum TransferType: Int16 {
    case upload, download

    public var label: String {
        switch self {
        case .upload:
            return "upload"
        case .download:
            return "download"
        }
    }
}

public protocol ResumableOperationDelegate: AnyObject {
    func operation(_ operation: ResumableOperation?, didChangeState state: TransferState)
}

open class ResumableOperation: Operation {
    // MARK: Properties

    internal var internalState: TransferState
    public var state: TransferState {
        return internalState
    }

    public weak var transfer: Transfer?
    public weak var delegate: ResumableOperationDelegate?
    public weak var queue: ResumableOperationQueue?

    open var isPaused: Bool {
        return internalState == .paused
    }

    public var debugString: String {
        return "Operation \(type(of: self)) \(hash): Status \(internalState.label)"
    }

    // MARK: Initializers

    public init(state: TransferState = .pending, delegate: ResumableOperationDelegate? = nil) {
        self.internalState = state
        self.delegate = delegate
    }

    // MARK: Public Methods

    open override func main() {
        if isCancelled || isPaused { return }
        internalState = .complete
    }

    open override func start() {
        if internalState == .pending {
            internalState = .inProgress
        }
        super.start()
    }

    open override func cancel() {
        internalState = .canceled
        super.cancel()
    }

    open func pause() {
        internalState = .paused
        super.cancel()
    }

    // MARK: Internal Methods

    internal func notifyDelegate(withTransfer transfer: Transfer) {
        switch transfer {
        case let transfer as BlockTransfer:
            if let parent = transfer.parent?.operation?.transfer {
                notifyDelegate(withTransfer: parent)
                return
            }
        case let transfer as BlobTransfer:
            if let parent = transfer.parent?.operation?.transfer {
                notifyDelegate(withTransfer: parent)
                return
            }
        default:
            break
        }
        delegate?.operation(self, didChangeState: transfer.state)
    }

    internal func notifyDelegate(withTransfer transfer: BlockTransfer) {
        // Notify the delegate of the block change AND the parent change.
        // This allows the developer to decide which events to respond to.
        delegate?.operation(self, didChangeState: transfer.state)
        if let parent = transfer.parent?.operation, let parentState = parent.transfer?.state {
            delegate?.operation(parent, didChangeState: parentState)
        }
    }
}
