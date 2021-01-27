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

import SwiftUI

import AzureCore
import AzureIdentity
import AzureStorageBlob
import MSAL
import Photos

struct BlobDownloadView: View {
    @ObservedObject var data = BlobListObservable()
    @State private var blobClinet: StorageBlobClient?
    
    var body: some View {
        NavigationView {
            List(data.items, id: \.name) { item in
                
            }
        }
        .onAppear(perform: initialize)
    }
    
    private func initialize() {
        // Create refresh control
    }
    
    private func initBlobClient() {
        blobClinet = try? AppState.blobClient()
        
    }
    
    private func authorizePhotoLib() {
        PHPhotoLibrary.authorizationStatus()
    }
}

struct BlobRow: View {
    var blob: BlobItem
    var transferId: UUID
    @State var progress = Float(0)

    init(blob: BlobItem, transferId: UUID) {
        self.blob = blob
        self.transferId = transferId
        let blobClient = try? AppState.blobClient()
        
        if let transfer = blobClient?.transfers[transferId]  {
            self.progress = transfer.progress.asFloat
        }
    }

    var body: some View {
        return VStack {
            HStack {
                Text(blob.name)
                    .font(.subheadline)
                Spacer()
                Text(blob.properties?.blobType?.rawValue ?? "Unknown")
            }
            ProgressView(progress: $progress)
        }
    }
}

struct ProgressView: UIViewRepresentable {
    @Binding var progress: Float

    func makeUIView(context _: Context) -> UIProgressView {
        UIProgressView(progressViewStyle: .bar)
    }

    func updateUIView(_ uiView: UIProgressView, context _: Context) {
        uiView.progress = progress
    }
}

struct BlobDownloadView_Previews: PreviewProvider {
    static var previews: some View {
        BlobDownloadView()
    }
}

class BlobListObservable: ObservableObject {
    @Published var items = [BlobItem]()
    @Published var transfers = [String: BlobTransfer]()

    init() {
        loadBlobData()
    }

    func loadBlobData() {
        guard let blobClient = try? AppState.blobClient() else { return }
        blobClient.listBlobs(inContainer: "videos") { result, _ in
            switch result {
            case let .success(paged):
                self.items = paged.items ?? [BlobItem]()
            case let .failure(error):
                print(error.localizedDescription)
            }
        }
    }
}
