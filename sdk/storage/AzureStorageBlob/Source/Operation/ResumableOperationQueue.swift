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

internal protocol ResumableOperationQueueDelegate: ResumableOperationDelegate {
    func operation(_ operation: ResumableOperation?, didChangeState state: TransferState)
    func operations(_ operations: [ResumableOperation]?, didChangeState state: TransferState)
}

internal class ResumableOperationQueue {
    // MARK: Properties

    lazy var operationQueue: OperationQueue = OperationQueue()

    weak var delegate: ResumableOperationQueueDelegate?

    var name: String? {
        get {
            return operationQueue.name
        }

        set {
            operationQueue.name = newValue
        }
    }

    var maxConcurrentOperationCount: Int {
        get {
            return operationQueue.maxConcurrentOperationCount
        }

        set {
            operationQueue.maxConcurrentOperationCount = newValue
        }
    }

    public var count: Int {
        return operationQueue.operationCount
    }

    let removeOnCompletion: Bool

    // MARK: Initializers

    init(name: String, delegate: ResumableOperationQueueDelegate? = nil, removeOnCompletion: Bool = false) {
        self.removeOnCompletion = removeOnCompletion
        self.name = name
        self.delegate = delegate
    }

    // MARK: Public Methods

    func add(_ operation: ResumableOperation) {
        add([operation])
    }

    func add(_ operations: [ResumableOperation]) {
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
                }
                operationQueue.addOperations(filteredOps, waitUntilFinished: false)
            }
        }
    }

    func cancel(_ operation: ResumableOperation) {
        operation.cancel()
    }

    func clear() {
        operationQueue.cancelAllOperations()
    }

    func pause(_ operation: ResumableOperation) {
        operation.pause()
    }
}
