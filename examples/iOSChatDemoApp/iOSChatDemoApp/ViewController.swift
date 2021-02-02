//
//  ViewController.swift
//  iOSChatDemoApp
//
//  Created by Gloria Li on 2021-02-01.
//

import UIKit
import AzureCommunicationChat
import AzureCore
import AzureCommunication
import AzureCommunicationSignaling

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var messagesTableView: UITableView!
    @IBOutlet var sendMessageButton: UIButton!
    @IBOutlet var messageInputArea: UITextInput!
    
    @IBAction func didTapButton()
    {
        print("Sending Message...")
        let range = messageInputArea.textRange(from: messageInputArea.beginningOfDocument, to: messageInputArea.endOfDocument)!
        let trimmedText = messageInputArea.text(in: range)
        if let unwrappedTrimmedText = trimmedText{
            if unwrappedTrimmedText.trimmingCharacters(in: .whitespaces).isEmpty
            {
                emptyMessageWarning()
                return
            }

            messages.append(ChatMessage(id: "", type: ChatMessageType.text, sequenceId: "", version: "", content:ChatMessageContent(message: trimmedText, topic: nil, participants: nil, initiator: nil), senderDisplayName:"bob" , createdOn: Iso8601Date(), senderId: "", deletedOn: nil, editedOn: nil))
            messagesTableView.reloadData()
            
        }
        else {
            emptyMessageWarning()
            return
        }
        messageInputArea.replace(range, withText: "")
    }

    @IBAction func typingMessage()
    {
        print("Typing...")
    }

    var messages: [ChatMessage] = [
        ChatMessage(id: "", type: ChatMessageType.text, sequenceId: "", version: "", content:ChatMessageContent(message: "Message 1", topic: nil, participants: nil, initiator: nil), senderDisplayName:"bob" , createdOn: Iso8601Date(), senderId: "", deletedOn: nil, editedOn: nil),
        ChatMessage(id: "", type: ChatMessageType.text, sequenceId: "", version: "", content:ChatMessageContent(message: "Message 2", topic: nil, participants: nil, initiator: nil), senderDisplayName:"bob" , createdOn: Iso8601Date(), senderId: "", deletedOn: nil, editedOn: nil),
        ChatMessage(id: "", type: ChatMessageType.text, sequenceId: "", version: "", content:ChatMessageContent(message: "Message 3", topic: nil, participants: nil, initiator: nil), senderDisplayName:"bob" , createdOn: Iso8601Date(), senderId: "", deletedOn: nil, editedOn: nil),
        ChatMessage(id: "", type: ChatMessageType.text, sequenceId: "", version: "", content:ChatMessageContent(message: "Message 4", topic: nil, participants: nil, initiator: nil), senderDisplayName:"bob" , createdOn: Iso8601Date(), senderId: "", deletedOn: nil, editedOn: nil),
        ChatMessage(id: "", type: ChatMessageType.text, sequenceId: "", version: "", content:ChatMessageContent(message: "Message 5", topic: nil, participants: nil, initiator: nil), senderDisplayName:"bob" , createdOn: Iso8601Date(), senderId: "", deletedOn: nil, editedOn: nil),
    ]

    var participants: [AzureCommunicationChat.ChatParticipant] = []

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = messages[indexPath.row].content?.message
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        messagesTableView.deselectRow(at: indexPath, animated: true)
//        let vc = ChatViewController()
//        vc.title="Chat"
//        navigationController?.pushViewController(vc, animated: true)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesTableView.delegate = self
        messagesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        messagesTableView.dataSource = self
    }
    
    func emptyMessageWarning ()
    {
        let alert = UIAlertController(title: "Error", message: "Can't send empty messages", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }


}

