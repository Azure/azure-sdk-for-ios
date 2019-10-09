//
//  BlobTableViewController.swift
//  AzureSDKDemoSwift
//
//  Created by Travis Prescott on 10/7/19.
//  Copyright © 2019 Azure SDK Team. All rights reserved.
//

import AzureCore
import AzureStorageBlob
import os.log
import UIKit

class BlobTableViewController: UITableViewController {
    internal var containerName: String?
    private var dataSource: PagedCollection<BlobItem>?
    private var noMoreData = false

    override func viewDidLoad() {
        super.viewDidLoad()
        loadInitialSettings()
    }

    // MARK: Private Methods

    /// Constructs the PagedCollection and retrieves the first page of results to initalize the table view.
    private func loadInitialSettings() {
        guard let containerName = containerName else { return }
        guard let blobClient = getBlobClient() else { return }
        let options = ListBlobsOptions()
        options.maxResults = 20
        blobClient.listBlobs(in: containerName, withOptions: options) { result, _ in
            switch result {
            case let .success(paged):
                self.dataSource = paged
                self.reloadTableView()
            case let .failure(error):
                self.showAlert(error: String(describing: error))
                self.noMoreData = true
            }
        }
    }

    /// Uses asynchronous "nextPage" method to fetch the next page of results and update the table view.
    private func loadMoreSettings() {
        guard noMoreData == false else { return }
        dataSource?.nextPage { result in
            switch result {
            case .success:
                self.reloadTableView()
            case let .failure(error):
                self.showAlert(error: String(describing: error))
                self.noMoreData = true
            }
        }
    }

    /// Reload the table view on the UI thread.
    private func reloadTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }

    private func showAlert(message: String) {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: "Blob Contents", message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Close", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self?.present(alertController, animated: true)
        }
    }

    private func showAlert(image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: "Blob Contents", message: "", preferredStyle: .alert)
            let alertBounds = alertController.view.frame
            let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: alertBounds.width - 20, height: 100))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            alertController.view.addSubview(imageView)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self?.present(alertController, animated: true)
        }
    }

    private func showAlert(error: String) {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: "Error!", message: error, preferredStyle: .alert)
            let title = NSAttributedString(string: "Error!", attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.red,
            ])
            alertController.setValue(title, forKey: "attributedTitle")
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self?.present(alertController, animated: true)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        guard let data = dataSource?.items else { return 0 }
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = dataSource?.items else {
            fatalError("No data found to construct cell.")
        }
        let cellIdentifier = "CustomTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CustomTableViewCell else {
            fatalError("The dequeued cell is not an instance of CustomTableViewCell")
        }
        // configure the cell
        let blobItem = data[indexPath.row]
        cell.keyLabel.text = blobItem.name
        cell.valueLabel.text = "???"
        if let blobType = blobItem.properties.blobType {
            cell.valueLabel.text = blobType.rawValue
        }

        // load next page if at the end of the current list
        if indexPath.row == data.count - 1, noMoreData == false {
            loadMoreSettings()
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell else { return }
        guard let blobName = cell.keyLabel.text else { return }
        guard let containerName = containerName else { return }
        guard let blobClient = getBlobClient() else { return }
        blobClient.download(blob: blobName, fromContainer: containerName) { result, _ in
            switch result {
            case let .success(data):
                let options = [
                    NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.rtf,
                ]
                if let attributedString = try? NSAttributedString(data: data, options: options,
                                                                  documentAttributes: nil) {
                    self.showAlert(message: attributedString.string)
                } else if let rawString = String(data: data, encoding: .utf8) {
                    self.showAlert(message: rawString)
                } else if let image = UIImage(data: data) {
                    self.showAlert(image: image)
                } else {
                    self.showAlert(error: "Unable to display the downloaded content.")
                }
            case let .failure(error):
                self.showAlert(error: String(describing: error))
            }
            DispatchQueue.main.async { [weak self] in
                self?.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
    }
}
