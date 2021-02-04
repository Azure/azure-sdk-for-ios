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

class LogInViewController: UIViewController {
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var userNameInputArea: UITextInput!
    
    @IBAction func connectButtonTapped(){
        let range = userNameInputArea.textRange(from: userNameInputArea.beginningOfDocument, to: userNameInputArea.endOfDocument)!
        let userName = userNameInputArea.text(in:range )
        if let unwrappedUserName = userName{
            if unwrappedUserName.trimmingCharacters(in: .whitespaces).isEmpty
            {
                showAlert(message: "user name cannot be empty", viewController: self)
                return
            }
            
            if let index = users.firstIndex(where: {user in user.name == unwrappedUserName}){
                currentUser = users[index]
                userNameInputArea.replace(range, withText: "")
                performSegue(withIdentifier: "SegueToThreadsViewController", sender: self)
            }
            else
            {
                showAlert(message: "user does not exist", viewController: self)
                return
            }
        }
        else {
            showAlert(message: "user name cannot be empty", viewController: self)
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
