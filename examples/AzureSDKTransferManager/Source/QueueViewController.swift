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
import AzureStorageBlob
import CoreData
import UIKit

class QueueViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!

    internal var fileId: Int64 = 0

    internal var transferManager: URLSessionTransferManager {
        return URLSessionTransferManager.shared
    }

    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    // MARK: Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = self
        self.tableView.dataSource = self
        transferManager.delegate = self
        transferManager.loadContext()
        transferManager.reachability?.startListening()
    }

    override func viewWillDisappear(_ animated: Bool) {
        transferManager.reachability?.stopListening()
    }

    internal func reloadTableView() {
        DispatchQueue.main.async { [weak self] in
            guard let parent = self else { return }
            parent.tableView.reloadData()
        }
    }

    // MARK: Actions

    @IBAction func didPressClear(_ sender: UIBarButtonItem) {
        transferManager.removeAll()
    }

    @IBAction func didPressEnqueueMulti(_ sender: UIBarButtonItem) {
        guard let context = transferManager.persistentContainer?.viewContext else { return }
        fileId += 1
        // TODO: This is artificial
        let uri = URL(string: "www.contoso.com")
        let transfer = BlobTransfer.with(context: context, baseUrl: "www.test.com", blobName: "Blob\(fileId)", containerName: "test", uri: uri, startRange: 0, endRange: 1)
        transferManager.add(transfer: transfer)
    }

    @IBAction func didPressEnqueue(_ sender: UIBarButtonItem) {
        guard let context = transferManager.persistentContainer?.viewContext else { return }
        fileId += 1
        let transfer = BlockTransfer.with(context: context, startRange: 0, endRange: 1)
        transferManager.add(transfer: transfer)
    }

    // MARK: UITableViewDelegate Methods

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: QueueTableViewCell.identifier, for: indexPath) as! QueueTableViewCell
        let details = transferManager[indexPath.row]
        cell.statusLabel?.text = details.state.string()
        switch details {
        case let details as BlockTransfer:
            cell.idLabel?.text = "\(indexPath.row)"
            cell.contentLabel?.text = String(data: details.data ?? Data(), encoding: .utf8)
            cell.backgroundColor = UIColor.white
        case let details as BlobTransfer:
            cell.idLabel?.text = "Blob \(details.blobName ?? "Unknown")"
            let total = details.totalBlocks
            let complete = total - details.incompleteBlocks
            cell.contentLabel?.text = "Transfer: \(complete)/\(total)"
            cell.backgroundColor = UIColor.systemTeal
        default:
            fatalError("Unhandled operation type. \(details.self)")
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transferManager.count
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let transfer = transferManager[indexPath.row]

        let pause = UITableViewRowAction(style: .normal, title: "Pause") { _, index in
            self.transferManager.pause(transfer: transfer)
        }
        pause.backgroundColor = .orange

        let resume = UITableViewRowAction(style: .normal, title: "Resume") { _, index in
            self.transferManager.resume(transfer: transfer)
        }
        resume.backgroundColor = .green

        let cancel = UITableViewRowAction(style: .destructive, title: "Cancel") { _, index in
            self.transferManager.cancel(transfer: transfer)
        }

        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { _, index in
            self.transferManager.remove(transfer: transfer)
        }

        // return the correct buttons
        var actions = [UITableViewRowAction]()
        switch transfer.state {
        case .paused:
            actions = [cancel, resume]
        case .pending:
            actions = [cancel, pause]
        case .inProgress:
            actions = [cancel]
        case .complete, .canceled:
            actions = [delete]
        default:
            break
        }
        return actions
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) { return }
}

extension QueueViewController: TransferManagerDelegate {
    func transferManager<T>(_ manager: T, didUpdateTransfer transfer: Transfer, withState state: TransferState, andProgress progress: TransferProgress?) where T : TransferManager {
        reloadTableView()
    }

    func transferManager<T>(_ manager: T, didUpdateTransfers transfers: [Transfer], withState state: TransferState) where T : TransferManager {
        reloadTableView()
    }

    func transferManager<T>(_ manager: T, didCompleteTransfer transfer: Transfer) where T : TransferManager {
        reloadTableView()
    }

    func transferManager<T>(_ manager: T, didFailTransfer transfer: Transfer, withError: Error) where T : TransferManager {
        reloadTableView()
    }

    func transferManager<T>(_ manager: T, didUpdateWithState state: TransferState) where T : TransferManager {
        reloadTableView()
    }
}
