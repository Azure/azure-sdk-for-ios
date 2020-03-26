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

public protocol ResumableOperationQueueDelegate: ResumableOperationDelegate {
    func operation(_ operation: ResumableOperation?, didChangeState state: TransferState)
    func operations(_ operations: [ResumableOperation]?, didChangeState state: TransferState)
}

open class ResumableOperationQueue {
    // MARK: Properties

    internal lazy var operations: [ResumableOperation] = []

    internal lazy var operationQueue: OperationQueue = OperationQueue()

    public weak var delegate: ResumableOperationQueueDelegate?

    public var name: String? {
        get {
            return operationQueue.name
        }

        set {
            operationQueue.name = newValue
        }
    }

    public var maxConcurrentOperationCount: Int {
        get {
            return operationQueue.maxConcurrentOperationCount
        }

        set {
            operationQueue.maxConcurrentOperationCount = newValue
        }
    }

    public var count: Int {
        return operations.count
    }

    public var queueCount: Int {
        return operationQueue.operationCount
    }

    public let removeOnCompletion: Bool

    // MARK: Initializers

    public init(name: String, delegate: ResumableOperationQueueDelegate? = nil, removeOnCompletion: Bool = false) {
        self.removeOnCompletion = removeOnCompletion
        self.name = name
        self.delegate = delegate
    }

    // MARK: Public Methods

    public func add(_ operation: ResumableOperation) {
        add([operation])
    }

    public func add(_ operations: [ResumableOperation]) {
        let states = operations.map { $0.state.rawValue }
        for state in Set(states) {
            let filteredOps = operations.filter { $0.state.rawValue == state }
            var transferState = TransferState(rawValue: state)!
            let allowed: [TransferState] = [.pending, .inProgress]
            if allowed.contains(transferState) {
                // reset inProgress back to pending since they may be scheduled differently
                transferState = .pending

                // For Pending or InProgress operations, need to requeue the operations
                for operation in filteredOps {
                    operation.delegate = operation.delegate ?? delegate
                    let operationClosure = operation.completionBlock
                    operation.completionBlock = {
                        operationClosure?()
                        if operation.isCancelled {
                            return
                        }
                        operation.internalState = .complete
                    }
                    self.operations.append(operation)
                }
                operationQueue.addOperations(filteredOps, waitUntilFinished: false)
            }
        }
    }

    public func cancel(_ operation: ResumableOperation) {
        operation.cancel()
    }

    public func clear() {
        operationQueue.cancelAllOperations()
        operations.removeAll()
    }

    internal func removeFromDataStore(_ operation: ResumableOperation) {
        guard let index = operations.firstIndex(of: operation) else { return }
        operations.remove(at: index)
    }

    public func pause(_ operation: ResumableOperation) {
        operation.pause()
        removeFromDataStore(operation)
    }

    public func remove(_ operation: ResumableOperation) {
        removeFromDataStore(operation)

        // Cancel the operation.
        if !operation.isFinished {
            operation.cancel()
        }
    }

    public func replace(old oldOperation: ResumableOperation, withNew newOperation: ResumableOperation) {
        guard let index = operations.firstIndex(of: oldOperation) else { fatalError("Index error.") }
        operations[index] = newOperation
        operationQueue.addOperation(newOperation)
    }
}
