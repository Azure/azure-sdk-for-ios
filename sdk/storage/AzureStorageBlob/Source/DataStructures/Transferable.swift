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

public struct TransferProgress {
    var bytesTransferred: Int
    var totalBytesToTransfer: Int
    var percentTransferred: Float {
        return Float(bytesTransferred) * 100.0 / Float(totalBytesToTransfer)
    }
}

public protocol ProgressListener: AnyObject {
    // TODO: Implementation
    func progressChanged()
}

public protocol Transferable {
//    func add(progressListener listener: ProgressListener)
//    func remove(progressListener listener: ProgressListener)

    func waitForCompletion()
    func waitForException() -> Error

//    var description: String { get }
    var isDone: Bool { get }
    var state: TransferState { get }
    var progress: TransferProgress { get }
}

// public class CopyTransfer: Transferable {
//
//    // MARK: Properties
//
//    internal var downloadTask: URLSessionDownloadTask
//    internal var uploadTask: URLSessionUploadTask
//
//    // MARK: Initializers
//
//    public init(withDownloadTask downloadTask: URLSessionDownloadTask, andUploadTask uploadTask: URLSessionUploadTask) {
//        self.downloadTask = downloadTask
//        self.uploadTask = uploadTask
//    }
// }

internal class DownloadTransferDelegate: NSObject, URLSessionDownloadDelegate {
    func urlSession(
        _: URLSession,
        downloadTask _: URLSessionDownloadTask,
        didWriteData _: Int64,
        totalBytesWritten _: Int64,
        totalBytesExpectedToWrite _: Int64
    ) {
        // TODO: Implmentation
    }

    func urlSession(_: URLSession, downloadTask _: URLSessionDownloadTask, didFinishDownloadingTo _: URL) {
        // TODO: Implmentation
    }

    func urlSession(_: URLSession, didBecomeInvalidWithError _: Error?) {
        // TODO: Implmentation
    }

    func urlSession(_: URLSession, taskIsWaitingForConnectivity _: URLSessionTask) {
        // TODO: Implementation
    }

    func urlSession(_: URLSession, task _: URLSessionTask, didCompleteWithError _: Error?) {
        // TODO: Implmentation
    }
}

public class DownloadTransfer: Transferable {
    public var isDone: Bool {
        // TODO: Implmentation
        return false
    }

    public var state: TransferState

    public var progress: TransferProgress

    // MARK: Properties

    internal var task: URLSessionDownloadTask

    // MARK: Initializers

    public init(withTask task: URLSessionDownloadTask) {
        // TODO: Implmentation
        self.task = task
        self.state = .inProgress
        self.progress = TransferProgress(bytesTransferred: 0, totalBytesToTransfer: Int.max)
    }

    // MARK: Transferable Methods

    public func waitForCompletion() {
        // TODO: Implmentation
    }

    public func waitForException() -> Error {
        // TODO: Implmentation
        return AzureError.general("TODO: implement!")
    }
}

// TODO: Implement
// public class MultiDownloadTransfer: Transferable {
//
// }

// public class UploadTransfer: Transferable {
//
//    // MARK: Properties
//
//    internal var task: URLSessionUploadTask
//
//    // MARK: Initializers
//
//    public init(withTask task: URLSessionUploadTask) {
//        self.task = task
//    }
// }

// TODO: Implement
// public class MultiUploadTransfer: Transferable {
//
// }
