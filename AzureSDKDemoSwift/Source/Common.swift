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
import MSAL

struct AppConstants {
    // read-only connection string
    static let appConfigConnectionString = "Endpoint=https://tjpappconfig.azconfig.io;Id=2-l0-s0:zSvXZtO9L9bv9s3QVyD3;Secret=FzxmbflLwAt5+2TUbnSIsAuATyY00L+GFpuxuJZRmzI="

    static let storageAccountUrl = "https://iosdemostorage1.blob.core.windows.net/"

    static let tenant = "7e6c9611-413e-47e4-a054-a389854dd732"

    static let clientId = "6f2c62dd-d6b2-444a-8dff-c64380e7ac76"

    static let redirectUri = "msauth.com.azure.demo.AzureSDKDemoSwifty://auth"

    static let authority = "https://login.microsoftonline.com/7e6c9611-413e-47e4-a054-a389854dd732"
}

struct AppState {
    static var application: MSALPublicClientApplication?

    static var account: MSALAccount?

    static let scopes = [
        "https://storage.azure.com/.default"
    ]

    static func currentAccount() -> MSALAccount? {
        if let account = AppState.account {
            return account
        }
        guard let application = AppState.application else { return nil }
        // We retrieve our current account by getting the first account from cache
        // In multi-account applications, account should be retrieved by home account identifier or username instead
        do {
            let cachedAccounts = try application.allAccounts()

            if !cachedAccounts.isEmpty {
                return cachedAccounts.first
            }
        } catch let error as NSError {
            print("Didn't find any accounts in cache: \(error)")
        }
        return nil
    }
}

extension UIViewController {

    internal func getBlobClient() -> StorageBlobClient? {
        guard let application = AppState.application else { return nil }
        do {
            let credential = StorageOAuthCredential(
                tenant: AppConstants.tenant, clientId: AppConstants.clientId, application: application,
                account: AppState.currentAccount())
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
                NSAttributedString.Key.foregroundColor: UIColor.red
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
            let imageView = UIImageView(
                frame: CGRect(x: padding, y: padding, width: alertBounds.width - padding, height: 100)
            )
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            alertController.view.addSubview(imageView)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self?.present(alertController, animated: true)
        }
    }
}
