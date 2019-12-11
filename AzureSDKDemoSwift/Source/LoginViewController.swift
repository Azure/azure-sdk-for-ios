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

import MSAL
import UIKit

class LoginViewController: UIViewController {

    // MARK: Outlets

    @IBOutlet weak var logInButton: UIBarButtonItem!

    @IBOutlet weak var logOutButton: UIBarButtonItem!

    @IBOutlet weak var userLabel: UILabel!

    // MARK: Actions

    @IBAction func didSelectLogIn(_ sender: Any) {
        if let currentAccount = self.currentAccount() {
            acquireTokenSilently(forAccount: currentAccount) { result, error in
                self.tokenAcquisitionDidFinish(withResult: result, orError: error)
            }

        } else {
            // We check to see if we have a current logged in account.
            // If we don't, then we need to sign someone in.
            acquireTokenInteractively { result, error in
                self.tokenAcquisitionDidFinish(withResult: result, orError: error)
            }
        }
    }

    @IBAction func didSelectLogOut(_ sender: Any) {
        guard let application = AppState.application else { return }
        guard let account = AppState.account else { return }
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
        let msalConfiguration = MSALPublicClientApplicationConfig(clientId: AppConstants.clientId, redirectUri: nil,
                                                                  authority: authority)
        AppState.application = try? MSALPublicClientApplication(configuration: msalConfiguration)
        AppState.account = currentAccount()
        updateLogOutButton(enabled: AppState.account != nil)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUserLabel()
    }

    internal func tokenAcquisitionDidFinish(withResult result: MSALResult?, orError error: Error?) {
        if let error = error {
            self.showAlert(error: String(describing: error))
            return
        }
        AppState.account = result?.account
        let loginView = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            loginView.performSegue(withIdentifier: "didSignIn", sender: loginView)
        }
        updateUserLabel()
    }

    internal func currentAccount() -> MSALAccount? {
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
            self.showAlert(error: "Didn't find any accounts in cache: \(error)")
        }
        return nil
    }

    internal func acquireTokenInteractively(then completion: @escaping (MSALResult?, Error?) -> Void) {
        guard let application = AppState.application else { return }
        let webViewParameters = MSALWebviewParameters(parentViewController: self)

        let parameters = MSALInteractiveTokenParameters(scopes: AppState.scopes, webviewParameters: webViewParameters)
        application.acquireToken(with: parameters) { (result, error) in
            if let error = error {
                self.showAlert(error: String(describing: error))
                return
            }

            guard let result = result else {
                self.showAlert(error: "Could not acquire token: no result returned.")
                return
            }
            AppState.account = result.account
            self.updateLogOutButton(enabled: true)
            completion(result, error)
        }
    }

    internal func acquireTokenSilently(forAccount account: MSALAccount,
                                       then completion: @escaping (MSALResult?, Error?) -> Void) {
        guard let application = AppState.application else { return }
        let parameters = MSALSilentTokenParameters(scopes: AppState.scopes, account: account)
        application.acquireTokenSilent(with: parameters) { (result, error) in
            if let error = error {
                let nsError = error as NSError

                // interactionRequired means we need to ask the user to sign-in. This usually happens
                // when the user's Refresh Token is expired or if the user has changed their password
                // among other possible reasons.
                if nsError.domain == MSALErrorDomain {
                    if nsError.code == MSALError.interactionRequired.rawValue {
                        self.acquireTokenInteractively { result, error in
                            self.tokenAcquisitionDidFinish(withResult: result, orError: error)
                        }
                        return
                    }
                }
                self.showAlert(error: "Could not acquire token silently: \(error)")
                return
            }

            guard let result = result else {
                self.showAlert(error: "Could not acquire token: No result returned")
                return
            }
            completion(result, error)
        }
    }

    internal func updateLogOutButton(enabled: Bool) {
        if Thread.isMainThread {
            self.logOutButton.isEnabled = enabled
        } else {
            DispatchQueue.main.async {
                self.logOutButton.isEnabled = enabled
            }
        }
        updateUserLabel()
    }

    internal func updateUserLabel() {
        if let account = AppState.account {
            userLabel.text = account.username ?? "Unknown"
        } else {
            userLabel.text = "Please log in"
        }
    }
}
