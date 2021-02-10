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

class ChangeTopicNameViewController: UIViewController {
    @IBOutlet var topicNameInputArea: UITextInput!
    
    @IBOutlet var changeTopicNameButton: UIButton!
    
    @IBAction func didTapChangeTopicNameButton()
    {
        
        let range = topicNameInputArea.textRange(from: topicNameInputArea.beginningOfDocument, to: topicNameInputArea.endOfDocument)!
        let topicName = topicNameInputArea.text(in:range )
        if let unwrappedTopicName = topicName {
            if unwrappedTopicName.trimmingCharacters(in: .whitespaces).isEmpty
            {
                showAlert(message: "topic name cannot be empty", viewController: self)
                return
            }
            changeTopicName(topicName: unwrappedTopicName)
            topicNameInputArea.replace(range, withText: "")
        }
        else {
            showAlert(message: "topic name cannot be empty", viewController: self)
            return
        }
    }
    
    func changeTopicName (topicName: String){
        chatThreadClient?.update(topic: topicName, completionHandler: { result, _ in
            switch result {
            case let .success(response):
                print(response)

            case .failure:
                print("Unexpected failure happened in update topic")
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

}
