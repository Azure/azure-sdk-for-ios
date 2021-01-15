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
import AzureIdentity
import AzureStorageBlob
import MSAL
import os.log

import UIKit

// swiftlint:disable force_cast

enum TestResult: String {
    case notRun
    case success
    case failure
    case inProgress

    var color: UIColor {
        switch self {
        case .notRun:
            return UIColor.gray
        case .success:
            return UIColor.green
        case .failure:
            return UIColor.red
        case .inProgress:
            return UIColor.lightGray
        }
    }
}

class TestResultTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var runButton: UIButton!

    var dataSource: [
        (name: String, result: TestResult, status: String, method: (Int) -> Void)
    ]!

    // MARK: Actions

    @IBAction func didPressRun(_ sender: AnyObject) {
        guard let cell = sender.superview?.superview as? TestResultTableViewCell,
            let tableView = cell.superview as? UITableView,
            let indexPath = tableView.indexPath(for: cell) else {
            fatalError()
        }
        var data = dataSource[indexPath.row]
        data.result = .inProgress
        DispatchQueue.main.async {
            tableView.reloadRows(at: [indexPath], with: .automatic)
            data.method(indexPath.row)
        }
    }
}

class MainViewController: UITableViewController, MSALInteractiveDelegate {
    private var blobClient: StorageBlobClient!
    private let containerName = "testa"

    private var dataSource: [
        (name: String, result: TestResult, status: String, method: (Int) -> Void)
    ]!

    // MARK: Internal Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        blobClient = try? AppState.blobClient()
        dataSource = [
            ("container.delete", TestResult.notRun, "", testDeleteContainer),
            ("container.create", TestResult.notRun, "", testCreateContainer),
            ("container.get", TestResult.notRun, "", testGetContainer),
            ("container.list", TestResult.notRun, "", testListContainer)
        ]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    // MARK: MSALInteractiveDelegate

    func didCompleteMSALRequest(withResult result: MSALResult) {
        AppState.account = result.account
    }

    func parentForWebView() -> UIViewController {
        return self
    }

    // MARK: - TableViewDataSource

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return dataSource.count
    }

    override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TestResultTableViewCell") as! TestResultTableViewCell
        let test = dataSource[indexPath.row]
        cell.nameLabel?.text = test.name
        cell.statusLabel?.text = "(\(test.result.rawValue)) \(test.status)"
        cell.backgroundColor = test.result.color
        cell.dataSource = dataSource
        return cell
    }
}
