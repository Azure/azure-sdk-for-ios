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
import AzureCore
import AzureStorageBlob
import Foundation
import MSAL

struct AppConstants {
    // read-only connection string
    static let appConfigConnectionString =
        // swiftlint:disable:next line_length
        "Endpoint=https://tjpappconfig.azconfig.io;Id=2-l0-s0:zSvXZtO9L9bv9s3QVyD3;Secret=FzxmbflLwAt5+2TUbnSIsAuATyY00L+GFpuxuJZRmzI="

    static let storageAccountUrl = "https://iosdemostorage1.blob.core.windows.net/"

    static let tenant = "7e6c9611-413e-47e4-a054-a389854dd732"

    static let clientId = "6f2c62dd-d6b2-444a-8dff-c64380e7ac76"

    static let redirectUri = "msauth.com.azure.examples.AzureSDKDemoSwifty://auth"

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

class ActivtyViewController: UIViewController {
    internal var spinner = UIActivityIndicatorView(style: .white)

    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.7)

        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)

        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
}

extension UIViewController {
    internal func showAlert(error: Error) {
        DispatchQueue.main.async { [weak self] in
            guard self?.presentedViewController == nil else { return }
            var errorString: String
            if let pipelineError = error as? PipelineError {
                errorString = pipelineError.innerError.localizedDescription
            } else {
                errorString = error.localizedDescription
            }
            self?.hideActivitySpinner()
            let alertController = UIAlertController(title: "Error!", message: errorString, preferredStyle: .alert)
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
            guard self?.presentedViewController == nil else { return }
            let alertController = UIAlertController(title: "Blob Contents", message: message, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Close", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            self?.present(alertController, animated: true)
        }
    }

    internal func showActivitySpinner() {
        let child = ActivtyViewController()
        DispatchQueue.main.async { [weak self] in
            guard let parent = self else { return }
            parent.addChild(child)
            child.view.frame = parent.view.frame
            parent.view.addSubview(child.view)
            child.didMove(toParent: parent)
        }
    }

    internal func hideActivitySpinner() {
        DispatchQueue.main.async { [weak self] in
            guard let parent = self else { return }
            let filtered = parent.children.filter { $0 is ActivtyViewController }
            for child in filtered {
                child.willMove(toParent: nil)
                child.view.removeFromSuperview()
                child.removeFromParent()
            }
        }
    }
}
