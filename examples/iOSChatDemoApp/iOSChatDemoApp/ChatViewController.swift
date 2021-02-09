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
import AzureCommunication
import AzureCommunicationSignaling

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var messagesTableView: UITableView!
    @IBOutlet var sendMessageButton: UIButton!
    @IBOutlet var messageInputArea: UITextInput!
    
    @IBAction func didTapButton()
    {
        print("Sending Message...")
        let range = messageInputArea.textRange(from: messageInputArea.beginningOfDocument, to: messageInputArea.endOfDocument)!
        let message = messageInputArea.text(in:range )
        if let unwrappedMessage = message{
            if unwrappedMessage.trimmingCharacters(in: .whitespaces).isEmpty
            {
                showAlert(message: "Can't send empty messages", viewController: self)
                return
            }
            
            let messageRequest = SendChatMessageRequest(
                content: unwrappedMessage,
                senderDisplayName: currentUser?.name
            )
            chatThreadClient?.send(message: messageRequest, completionHandler: { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    
                case .failure:
                    print("Unexpected failure happened in send message")
                }
            })
        }
        else {
            showAlert(message: "Can't send empty messages", viewController: self)
            return
        }
        
        messageInputArea.replace(range, withText: "")
    }

    @IBAction func typingMessage()
    {
        print("Typing...")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == messagesTableView{
            return chatMessages.count
        } 
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == messagesTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            
            let displayName: String? = chatMessages[indexPath.row].senderDisplayName
            let message: String? = chatMessages[indexPath.row].content?.message
            
            cell.textLabel?.text = [displayName,message]
                .compactMap { $0 }
                .joined(separator: ": ")
            
            return cell
        }
        return UITableViewCell()
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated);
        if self.isMovingFromParent
        {
            chatMessages = []
            participants = []
            chatThreadClient = nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        messagesTableView.delegate = self
        messagesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        messagesTableView.dataSource = self
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMessages), name:  Notification.Name(rawValue: "newMessage"), object: nil)
        listMessages()
    }
    
    func listMessages()
    {
        chatThreadClient?.listMessages(completionHandler: { result, _ in
            switch result {
            case let .success(messages):
                for message in messages.items?.reversed() ?? []
                {
                    if message.type == ChatMessageType.text && message.deletedOn == nil
                    {
                        chatMessages.append(message)
                    }
                }
                self.reloadMessages()
            case .failure:
                print("Unexpected failure happened in list chat threads")
            }
        })
    }
    
    @objc func reloadMessages() {
        DispatchQueue.main.async(execute: {
            self.messagesTableView.reloadData()
        })
    }
}
