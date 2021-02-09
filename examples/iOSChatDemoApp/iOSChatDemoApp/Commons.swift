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

import UIKit
import Foundation
import AzureCommunicationChat

var chatMessages: [Message] = []
var participants: [Participant] = []
var chatThreads: [AzureCommunicationChat.Thread] = []

var chatClient: ChatClient? = nil
var chatThreadClient: ChatThreadClient? = nil
var currentUser: User? = nil
var loggedIn = false

struct Constants {
    static let endpoint =  Bundle.main.object(forInfoDictionaryKey: "endpoint") as! String
}

struct User
{
    var name: String
    var id: String
    var token: String
}

var users: [User] = [
    User(name: "Gloria",
         id: Bundle.main.object(forInfoDictionaryKey: "idForGloria") as! String,
         token:  Bundle.main.object(forInfoDictionaryKey: "tokenForGloria") as! String),
    User(name: "UserA",
         id: Bundle.main.object(forInfoDictionaryKey: "idForUserA") as! String,
         token:  Bundle.main.object(forInfoDictionaryKey: "tokenForUserA") as! String)
]

func showAlert(message: String, viewController: UIViewController)
{
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
    viewController.present(alert, animated: true)
}
