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
import MSAL

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var isShowingMedia = false
    
    @State private var isError = false
    
    @State private var userLabel: String = "Please log in"
    @State private var errorMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Image("logo")
                    .scaledToFit()
                Text(userLabel)
            }.navigationBarItems(
                leading:
                    Button("Log Out") {
                        guard let application = AppState.application else { return }
                        guard let account = AppState.currentAccount else { return }
                        
                        do {
                            try application.remove(account)
                            AppState.account = nil
                            isLoggedIn = false
                        } catch {
                            errorMessage = parseErrorMessage(using: error)
                            isError = true
                        }
                    }.font(.title3)
                    .disabled(!isLoggedIn)
                    .alert(isPresented: $isError) {
                        Alert(title: Text("Error!"),
                              message: Text(errorMessage),
                              dismissButton: .cancel())
                    },
                trailing:
                    NavigationLink(
                        destination: MediaView(),
                        isActive: $isShowingMedia,
                        label: {
                            Button("Media") {
                                isShowingMedia.toggle()
                            }.font(.title3)
                        })
            )
        }.onAppear(perform: loadAuthority)
    }
    
    private func loadAuthority() {
        guard let authorityURL = URL(string: AppConstants.authority) else { return }
        guard let authority = try? MSALAADAuthority(url: authorityURL) else { return }
        let msalConfiguration = MSALPublicClientApplicationConfig(
            clientId: AppConstants.clientId,
            redirectUri: AppConstants.redirectUri,
            authority: authority
        )
        msalConfiguration.bypassRedirectURIValidation = true // Why do I need to do this
        AppState.application = try? MSALPublicClientApplication(configuration: msalConfiguration)
        AppState.account = AppState.currentAccount
        
        updateLoggedInState(enabled: AppState.currentAccount != nil)
        updateUserName(with: AppState.currentAccount)
    }
    
    private func updateLoggedInState(enabled: Bool) {
        isLoggedIn = enabled
    }
    
    private func updateUserName(with account: MSALAccount?) {
        if let account = account {
            userLabel = account.username ?? "Unknown"
        } else {
            userLabel = "Please log in"
        }
    }
    
    private func parseErrorMessage(using error: Error?) -> String {
        var errorString: String = ""
        if let err = error {
            switch error {
            case let azureError as AzureError:
                errorString = azureError.message
            default:
                let errorInfo = (err as NSError).userInfo
                errorString = errorInfo[NSDebugDescriptionErrorKey] as? String ?? err.localizedDescription
            }
        } else {
            errorString = "An error occurred."
        }
        
        return errorString
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
