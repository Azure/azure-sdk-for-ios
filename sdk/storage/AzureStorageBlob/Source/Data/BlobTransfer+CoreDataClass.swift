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
//

import AzureCore
import CoreData
import Foundation

/// A blob transfer operation.
public class BlobTransfer: NSManagedObject, Transfer {
    // MARK: Properties

    internal var operation: TransferOperation?
    internal var downloader: BlobStreamDownloader?
    internal var uploader: BlobStreamUploader?
    internal var progressHandler: ((BlobTransfer) -> Void)?

    internal var transfers: [BlockTransfer] {
        guard let blockSet = blocks else { return [BlockTransfer]() }
        return blockSet.map { $0 as? BlockTransfer }.filter { $0 != nil }.map { $0! }
    }

    /// The number of blocks remaining to be transfered.
    public var incompleteBlocks: Int64 {
        return Int64(transfers.filter { $0.state != .complete }.count)
    }

    /// The current progress of the transfer, calculated as the number of completed blocks divided by the total number
    /// of blocks that comprise the blob transfer.
    public var progress: TransferProgress {
        return TransferProgress(bytes: Int(bytesTransferred), totalBytes: Int(totalBytesToTransfer))
    }

    /// A debug representation of the transfer.
    public var debugString: String {
        var string = "\tTransfer \(type(of: self)) \(hash): Status \(state.label)"
        for block in transfers {
            string += "\n\(block.debugString)"
        }
        return string
    }

    /// The current state of the transfer.
    public internal(set) var state: TransferState {
        get {
            let currState = TransferState(rawValue: rawState)!
            var state = currState
            for item in transfers {
                switch item.state {
                case .canceled, .failed, .paused, .inProgress:
                    state = item.state
                default:
                    continue
                }
            }
            return state
        }

        set {
            rawState = newValue.rawValue
        }
    }

    internal var previousState: TransferState?

    /// The source of the transfer. For uploads, this is the absolute local path on the device of the file being
    /// uploaded. For downloads, this is the URL of the blob being downloaded.
    public var sourceUrl: URL? {
        guard let url = source else { return nil }
        return transferType == .upload ? LocalURL(fromAbsoluteUrl: url).resolvedUrl : url
    }

    /// The destination of the transfer. For uploads, this is the blob URL where the file is being uploaded. For
    /// downloads, this is the absolute local path on the device to which the blob is being downloaded.
    public var destinationUrl: URL? {
        guard let url = destination else { return nil }
        return transferType == .download ? LocalURL(fromAbsoluteUrl: url).resolvedUrl : url
    }

    // FIXME: The fact that BlobProperties, DownloadBlobOptions, and UploadBlobOptions are structs causes serious
    // problems here. It will always return nil if allowed to be optional.
    private var cachedProperties: BlobProperties?
    internal var properties: BlobProperties {
        get {
            guard cachedProperties == nil else { return cachedProperties! }
            guard let propertiesString = rawProperties,
                let jsonData = propertiesString.data(using: .utf8)
            else {
                cachedProperties = BlobProperties()
                return cachedProperties!
            }
            do {
                cachedProperties = try StorageJSONDecoder().decode(BlobProperties.self, from: jsonData)
            } catch {
                cachedProperties = BlobProperties()
            }
            return cachedProperties!
        }

        set {
            guard newValue != cachedProperties else { return }
            if let newJson = try? StorageJSONEncoder().encode(newValue) {
                rawProperties = String(data: newJson, encoding: .utf8)
                cachedProperties = newValue
            }
        }
    }

    private var cachedUploadOptions: UploadBlobOptions?
    internal var uploadOptions: UploadBlobOptions {
        get {
            guard cachedUploadOptions == nil else { return cachedUploadOptions! }
            guard transferType == .upload,
                let options = rawOptions,
                let jsonData = options.data(using: .utf8)
            else {
                cachedUploadOptions = UploadBlobOptions()
                return cachedUploadOptions!
            }
            do {
                cachedUploadOptions = try StorageJSONDecoder().decode(UploadBlobOptions.self, from: jsonData)
            } catch {
                cachedUploadOptions = UploadBlobOptions()
            }
            return cachedUploadOptions!
        }

        set {
            guard transferType == .upload else { return }
            guard newValue != cachedUploadOptions else { return }
            if let newJson = try? StorageJSONEncoder().encode(newValue) {
                rawOptions = String(data: newJson, encoding: .utf8)
                cachedUploadOptions = newValue
            }
        }
    }

    private var cachedDownloadOptions: DownloadBlobOptions?
    internal var downloadOptions: DownloadBlobOptions {
        get {
            guard cachedDownloadOptions == nil else { return cachedDownloadOptions! }
            guard transferType == .download,
                let options = rawOptions,
                let jsonData = options.data(using: .utf8)
            else {
                cachedDownloadOptions = DownloadBlobOptions()
                return cachedDownloadOptions!
            }
            do {
                cachedDownloadOptions = try StorageJSONDecoder().decode(DownloadBlobOptions.self, from: jsonData)
            } catch {
                cachedDownloadOptions = DownloadBlobOptions()
            }
            return cachedDownloadOptions!
        }

        set {
            guard transferType == .download else { return }
            guard newValue != cachedDownloadOptions else { return }
            if let newJson = try? StorageJSONEncoder().encode(newValue) {
                rawOptions = String(data: newJson, encoding: .utf8)
                cachedDownloadOptions = newValue
            }
        }
    }

    internal var debugStates: String {
        var dict = [String: String]()
        for transfer in transfers {
            dict[String(transfer.id.hashValue % 99)] = transfer.state.label
        }
        var sortedLines = [String]()
        for key in dict.keys.sorted() {
            guard let value = dict[key] else { continue }
            sortedLines.append("\(key): \(value)")
        }
        return sortedLines.joined(separator: ", ")
    }

    /// The type of the transfer.
    public internal(set) var transferType: TransferType {
        get {
            return TransferType(rawValue: rawType)!
        }

        set {
            rawType = newValue.rawValue
        }
    }
}

internal extension BlobTransfer {
    static func with(
        viewContext: NSManagedObjectContext,
        clientRestorationId: String,
        localUrl: LocalURL,
        remoteUrl: URL,
        type: TransferType,
        startRange: Int64,
        endRange: Int64,
        parent: MultiBlobTransfer? = nil,
        progressHandler: ((BlobTransfer) -> Void)? = nil
    ) -> BlobTransfer {
        guard let transfer = NSEntityDescription.insertNewObject(
            forEntityName: "BlobTransfer",
            into: viewContext
        ) as? BlobTransfer else {
            fatalError("Unable to create BlobTransfer object.")
        }

        switch type {
        case .download:
            transfer.source = remoteUrl
            transfer.destination = localUrl.rawUrl
        case .upload:
            transfer.source = localUrl.rawUrl
            transfer.destination = remoteUrl
        }
        transfer.parent = parent
        transfer.startRange = startRange
        transfer.endRange = endRange
        transfer.currentProgress = 0
        transfer.state = .pending
        transfer.transferType = type
        transfer.id = UUID()
        transfer.clientRestorationId = clientRestorationId
        transfer.progressHandler = progressHandler
        return transfer
    }
}

/// :nodoc:
extension BlobTransfer: TransferImpl {}
