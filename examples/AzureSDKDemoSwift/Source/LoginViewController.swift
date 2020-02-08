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
import MSAL
import UIKit

class LoginViewController: UIViewController, MSALInteractiveDelegate {
    // MARK: Outlets

    @IBOutlet var logInButton: UIBarButtonItem!

    @IBOutlet var logOutButton: UIBarButtonItem!

    @IBOutlet var userLabel: UILabel!

    // MARK: Actions

    @IBAction func didSelectLogOut(_: Any) {
        guard let application = AppState.application else { return }
        guard let account = AppState.currentAccount() else { return }
        do {
            try application.remove(account)
            AppState.account = nil
            updateLogOutButton(enabled: false)
        } catch let error as NSError {
            showAlert(error: "Error signing out: \(error)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let authorityURL = URL(string: AppConstants.authority) else { return }
        guard let authority = try? MSALAADAuthority(url: authorityURL) else { return }
        let msalConfiguration = MSALPublicClientApplicationConfig(
            clientId: AppConstants.clientId,
            redirectUri: nil,
            authority: authority
        )
        AppState.application = try? MSALPublicClientApplication(configuration: msalConfiguration)
        AppState.account = AppState.currentAccount()
        updateLogOutButton(enabled: AppState.currentAccount() != nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateLogOutButton(enabled: AppState.currentAccount() != nil)
    }

    internal func updateLogOutButton(enabled: Bool) {
        if Thread.isMainThread {
            logOutButton.isEnabled = enabled
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.logOutButton.isEnabled = enabled
            }
        }
        updateUserLabel()
    }

    internal func updateUserLabel() {
        if let account = AppState.currentAccount() {
            userLabel.text = account.username ?? "Unknown"
        } else {
            userLabel.text = "Please log in"
        }
    }

    // MARK: MSALInteractiveDelegate

    func didCompleteMSALRequest(withResult result: MSALResult) {
        AppState.account = result.account
        updateLogOutButton(enabled: true)
    }
}
