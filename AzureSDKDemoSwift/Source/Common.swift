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

import AzureAppConfiguration
import AzureStorageBlob
import Foundation

struct AppConstants {
    // read-only connection string
    static let appConfigConnectionString = "Endpoint=https://tjpappconfig.azconfig.io;Id=2-l0-s0:zSvXZtO9L9bv9s3QVyD3;Secret=FzxmbflLwAt5+2TUbnSIsAuATyY00L+GFpuxuJZRmzI="

    static let storageAccountUrl = "https://tjpstorage1.blob.core.windows.net/"

    static let tenant = "72f988bf-86f1-41af-91ab-2d7cd011db47"
    static let clientId = "b449abba-5b1f-41d9-88e1-8ebfab7b3de0"

    // read-only blob connection string using a SAS token
//    static let blobConnectionString = "BlobEndpoint=https://tjpstorage1.blob.core.windows.net/;QueueEndpoint=https://tjpstorage1.queue.core.windows.net/;FileEndpoint=https://tjpstorage1.file.core.windows.net/;TableEndpoint=https://tjpstorage1.table.core.windows.net/;SharedAccessSignature=sv=2018-03-28&ss=b&srt=sco&sp=rl&se=2020-10-03T07:45:02Z&st=2019-10-02T23:45:02Z&spr=https&sig=L7zqOTStAd2o3Mp72MW59GXM1WbL9G2FhOSXHpgrBCE%3D"
}

extension UIViewController {

    internal func getBlobClient() -> StorageBlobClient? {
        do {
            // return try StorageBlobClient.from(connectionString: AppConstants.blobConnectionString)
            let credential = StorageOAuthCredential(tenant: AppConstants.tenant, clientId: AppConstants.clientId)
            return try StorageBlobClient(accountUrl: AppConstants.storageAccountUrl, credential: credential)
        } catch {
            self.showAlert(error: String(describing: error))
            return nil
        }
    }

    internal func getAppConfigClient() -> AppConfigurationClient? {
        do {
            return try AppConfigurationClient.from(connectionString: AppConstants.appConfigConnectionString)
        } catch {
            self.showAlert(error: String(describing: error))
            return nil
        }
    }

    internal func showAlert(error: String) {
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

    internal func showAlert(message: String) {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: "Blob Contents", message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Close", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self?.present(alertController, animated: true)
        }
    }

    internal func showAlert(image: UIImage) {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController(title: "Blob Contents", message: "", preferredStyle: .alert)
            let alertBounds = alertController.view.frame
            let padding = alertBounds.width * 0.01
            let imageView = UIImageView(frame: CGRect(x: padding, y: padding, width: alertBounds.width - padding, height: 100))
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            alertController.view.addSubview(imageView)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self?.present(alertController, animated: true)
        }
    }
}
