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

class CreateNewThreadViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participantsToBeSelected.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = participantsToBeSelected[indexPath.row].name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          print("You selected \(participantsToBeSelected[indexPath.row].name)!")
          selectedParticipants.append(participantsToBeSelected[indexPath.row])
      }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("You deselected \(participantsToBeSelected[indexPath.row].name)!")
        selectedParticipants.removeAll(where: {user in user.name == participantsToBeSelected[indexPath.row].name})
    }
    
    var participantsToBeSelected: [User] = users.filter{ user in
        return user.id != currentUser?.id
    }
    
    var selectedParticipants: [User] = []

    @IBOutlet var participantsTableView: UITableView!
    
    @IBOutlet var createNewThreadButton: UIButton!
    
    @IBOutlet var topicNameInputArea: UITextInput!
    
    @IBAction func didTapCreateNewThreadButton()
    {
        if selectedParticipants.isEmpty
        {
            showAlert(message: "you need to select at least one participant", viewController: self)
            return
        }
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
        var participants: [Participant] = [Participant(from: ChatParticipant(
            id: currentUser!.id,
            displayName: currentUser?.name,
            
            shareHistoryTime: Iso8601Date(string: "2020-10-30T10:50:50Z")!
        ))]
        selectedParticipants.map{user in
            participants.append(Participant(from: ChatParticipant(id: user.id, displayName: user.name, shareHistoryTime: Iso8601Date(string: "2020-10-30T10:50:50Z")!)))}

        let request = CreateThreadRequest(
            topic: topicName,
            participants: participants
            
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
        participantsTableView.delegate = self
        participantsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        participantsTableView.dataSource = self
        participantsTableView.allowsMultipleSelection = true
        participantsTableView.allowsMultipleSelectionDuringEditing = true
    }
    
}
