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

class ParticipantsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var participantsTableView: UITableView!
    @IBOutlet var goToAddParticipantButton: UIButton!
    
    @IBAction func didTapOnGoToAddParticipantButton()
    {
        performSegue(withIdentifier: "SegueToAddParticipantsViewController", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatParticipants.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = chatParticipants[indexPath.row].displayName
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            removeParticipant(userId: chatParticipants[indexPath.row].user.identifier)
        }
    }
    
    func removeParticipant(userId: String)
    {
        chatThreadClient?.remove(participant: userId, completionHandler: { result, _ in
            switch result {
            case let .success(response):
                print(response)
                showInfo(message: "Participant has been removed", viewController: self)
            case .failure:
                print("Unexpected failure happened in remove participant")
                showAlert(message: "Unexpected failure happened in remove participant", viewController: self)
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated);
        if self.isMovingFromParent
        {
            chatParticipants = []
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        participantsTableView.delegate = self
        participantsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        participantsTableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(reloadParticipants), name:  Notification.Name(rawValue: "reloadParticipants"), object: nil)
        listParticipants ()
    }
    
    func listParticipants () {
        chatThreadClient?.listParticipants(completionHandler: { result, _ in
            switch result {
            case let .success(participants):
                for participant in participants.items ?? []
                {
                    chatParticipants.append(Participant(from: ChatParticipant(id: participant.user.identifier, displayName: participant.displayName, shareHistoryTime: participant.shareHistoryTime)))
                    
                }
                self.reloadParticipants()
               
            case .failure:
                print("Unexpected failure happened in list participants")
            }
        })
    }
    
    @objc func reloadParticipants() {
        DispatchQueue.main.async(execute: {
            self.participantsTableView.reloadData()
        })
    }
}
