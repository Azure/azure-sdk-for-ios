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
import AzureCommunicationChat
import AzureCore

class CreateNewThreadViewController: UIViewController {
    
    @IBOutlet var createNewThreadButton: UIButton!
    
    @IBOutlet var topicNameInputArea: UITextInput!
    
    @IBAction func didTapCreateNewThreadButton()
    {
        let range = topicNameInputArea.textRange(from: topicNameInputArea.beginningOfDocument, to: topicNameInputArea.endOfDocument)!
        let topicName = topicNameInputArea.text(in:range )
        if let unwrappedTopicName = topicName {
            if unwrappedTopicName.trimmingCharacters(in: .whitespaces).isEmpty
            {
                showAlert(message: "topic name cannot be empty", viewController: self)
                return
            }
            createNewThread(topicName: unwrappedTopicName)
            topicNameInputArea.replace(range, withText: "")
            performSegue(withIdentifier: "SegueToChatViewController", sender: self)
        }
        else {
            showAlert(message: "user name cannot be empty", viewController: self)
            return
        }
    }
    
    func createNewThread(topicName: String)
    {
        let participant = Participant(from: ChatParticipant(
            id: currentUser!.id,
            displayName: currentUser?.name,
            
            shareHistoryTime: Iso8601Date(string: "2020-10-30T10:50:50Z")!
        ))
        let request = CreateThreadRequest(
            topic: topicName,
            participants: [
                participant
            ]
        )
        chatClient?.create(thread: request) { result, _ in
            switch result {
            case let .success(response):
                print(response)
                
                guard let thread = response.thread else {
                    print("Failed to extract chatThread from response")
                    return
                }
                do {
                    chatThreadClient = try chatClient?.createClient(forThread: thread.id)
                } catch _ {
                    print("Failed to initialize ChatThreadClient")
                }
            case let .failure(error):
                print("Unexpected failure happened in Create Thread")
                print("\(error)")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}
