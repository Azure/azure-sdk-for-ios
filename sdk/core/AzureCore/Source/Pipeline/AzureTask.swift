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

/// A handle for an asynchronous operation that can be canceled.
public protocol Cancellable {
    /// Cancel this operation.
    func cancel()
}

public enum TaskState {
    /// The task is currently in progress.
    case inProgress
    /// The task completed successfully.
    case complete
    /// The task failed. This failure may or may not be retryable.
    case failed
    /// The task was explicitly canceled.
    case canceled

    /// A string representation of the task state.
    public var label: String {
        switch self {
        case .inProgress:
            return "In Progress"
        case .complete:
            return "Complete"
        case .failed:
            return "Failed"
        case .canceled:
            return "Canceled"
        }
    }
}

public class AzureTask: Cancellable {
    public internal(set) var id: UUID

    public internal(set) var state: TaskState

    public internal(set) var error: Error?

    public func cancel() {
        guard state == .inProgress else { return }
        AzureTaskManager.shared[id]?.state = .canceled
    }

    // MARK: Initializers

    init(request: HTTPRequest? = nil, error: AzureError? = nil) {
        if let clientRequestId = request?.headers[.clientRequestId], let uuid = UUID(uuidString: clientRequestId) {
            self.id = uuid
        } else {
            self.id = UUID()
        }
        if let error = error {
            self.error = error
            self.state = .failed
        } else {
            self.state = .inProgress
        }
    }

    // MARK: Static methods

    public static func `for`(request: HTTPRequest) -> AzureTask {
        let task = AzureTask(request: request)
        AzureTaskManager.shared[task.id] = task
        return task
    }

    public static func `for`(error: String) -> AzureTask {
        let azureError = AzureError.general(error)
        let task = AzureTask(error: azureError)
        AzureTaskManager.shared[task.id] = task
        return task
    }

    public static func `for`(error: AzureError) -> AzureTask {
        let task = AzureTask(error: error)
        AzureTaskManager.shared[task.id] = task
        return task
    }
}
