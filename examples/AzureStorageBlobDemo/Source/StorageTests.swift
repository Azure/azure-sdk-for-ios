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

func testDeleteContainer(_ idx: Int) {
    print("-> Testing container.delete API")

    let options = DeleteContainerOptions()
    blobClient.containers.delete(container: containerName, withOptions: options) { result, _ in
        switch result {
        case .success:
            self.dataSource[idx].result = .success
            self.dataSource[idx].status = "\(self.containerName) deleted"
            print("  SUCCESS")
        case let .failure(error):
            self.dataSource[idx].result = .failure
            self.dataSource[idx].status = error.message
            print("  FAILURE: \(error.message)")
        }
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .automatic)
        }
    }
}

func testCreateContainer(_ idx: Int) {
    print("-> Testing container.create API")

    let options = CreateContainerOptions()
    blobClient.containers.create(container: containerName, withOptions: options) { result, _ in
        switch result {
        case let .success(properties):
            self.dataSource[idx].result = .success
            self.dataSource[idx].status = "\(self.containerName) created: \(properties.eTag)"
            print("  SUCCESS")
        case let .failure(error):
            self.dataSource[idx].result = .failure
            self.dataSource[idx].status = error.message
            print("  FAILURE: \(error.message)")
        }
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .automatic)
        }
    }
}

func testListContainer(_ idx: Int) {
    print("-> Testing container.list API")

    let options = ListContainersOptions()
    blobClient.containers.list(withOptions: options) { result, _ in
        switch result {
        case let .success(containers):
            self.dataSource[idx].result = .success
            self.dataSource[idx].status = "\(containers.underestimatedCount) containers"
            print("  SUCCESS")
        case let .failure(error):
            self.dataSource[idx].result = .failure
            self.dataSource[idx].status = error.message
            print("  FAILURE: \(error.message)")
        }
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .automatic)
        }
    }
}

func testGetContainer(_ idx: Int) {
    print("-> Testing container.get API")

    let options = GetContainerOptions()
    blobClient.containers.get(container: containerName, withOptions: options) { result, _ in
        switch result {
        case let .success(properties):
            self.dataSource[idx].result = .success
            self.dataSource[idx].status = "\(self.containerName): \(properties.eTag)"
            print(properties)
            print("  SUCCESS")
        case let .failure(error):
            self.dataSource[idx].result = .failure
            self.dataSource[idx].status = error.message
            print("  FAILURE: \(error.message)")
        }
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [IndexPath(row: idx, section: 0)], with: .automatic)
        }
    }
}
