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

struct Constants {
    static let endpoint =  "https://chat-sdktester-e2e.int.communication.azure.net/"
    static let id = "8:acs:46849534-eb08-4ab7-bde7-c36928cd1547_00000006-f3dd-7f8c-1655-373a0d000426"
    static let skypeToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwMl9pbnQiLCJ4NXQiOiJnMTROVjRoSzJKUklPYk15YUUyOUxFU1FKRk0iLCJ0eXAiOiJKV1QifQ.eyJza3lwZWlkIjoiYWNzOjQ2ODQ5NTM0LWViMDgtNGFiNy1iZGU3LWMzNjkyOGNkMTU0N18wMDAwMDAwNi1mM2RkLTdmOGMtMTY1NS0zNzNhMGQwMDA0MjYiLCJzY3AiOjE3OTIsImNzaSI6IjE2MTIzMDMwNzMiLCJpYXQiOjE2MTIzMDMwNzQsImV4cCI6MTYxMjM4OTQ3MywiYWNzU2NvcGUiOiJjaGF0IiwicmVzb3VyY2VJZCI6IjQ2ODQ5NTM0LWViMDgtNGFiNy1iZGU3LWMzNjkyOGNkMTU0NyJ9.3ZPE-f9xYtVDtKAdBObHNS36TGq0bh6vHfSXCbPxfdmExnLqp7wSEYq2Q8grORdeXUxDvRUm9K3LVN8ClNkk_2DwOFsZjH77v-VvMSLMVjhHREi21TgGfjYLpQ9Rd8wXd9NDZlC8Rrt0aNrQLu4PsQSxPNdurli12tqngSWXhj5L9lRdy5WTpnHPgWAptd5EvYNKQ_-eV0eAHytUpDLpzeHvZ7zgJijnC4x0xHvGMx39tllksiNNEtXmduAYq-7Jch5UNTtVxzR5yU0gd3kd14691Oky7L2vFut7ba9yTQTZixKE6DGlNSZDrWa9Yb_ze1geDeOW1302rGcdHAAvRw"
}

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
            
            let messageRequest = SendChatMessageRequest(
                content: unwrappedTrimmedText,
                senderDisplayName: "Bob"
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
            emptyMessageWarning()
            return
        }
        
        messageInputArea.replace(range, withText: "")
    }

    @IBAction func typingMessage()
    {
        print("Typing...")
    }

    var messages: [ChatMessage] = []

    var participants: [AzureCommunicationChat.ChatParticipant] = []

    var chatClient: ChatClient? = nil
    var chatThreadClient: ChatThreadClient? = nil
    
    func onStart (skypeToken: String)
    {
        let communicationUserCredential: CommunicationTokenCredential
        do {
            communicationUserCredential = try CommunicationTokenCredential(token:skypeToken)
        } catch {
            fatalError(error.localizedDescription)
        }
        chatClient = getClient(credential:communicationUserCredential)
        chatClient?.startRealTimeNotifications()
        
            let participant = ChatParticipant(
                id: Constants.id,
                displayName: "Bob",
                shareHistoryTime: Iso8601Date(string: "2020-10-30T10:50:50Z")!
            )
            let request = CreateChatThreadRequest(
                topic: "Lunch Thread",
                participants: [
                    participant
                ]
            )
            chatClient?.create(thread: request) { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    
                    guard let thread = response.chatThread else {
                        print("Failed to extract chatThread from response")
                        return
                    }
                    do {
                        self.chatThreadClient = try self.chatClient?.createClient(forThread: thread.id)
                    } catch _ {
                        print("Failed to initialize ChatThreadClient")
                    }
                case let .failure(error):
                    print("Unexpected failure happened in Create Thread")
                    print("\(error)")
                }
            }
        
        chatClient?.on(event: "chatMessageReceived", listener:{
                (response, eventId)
                in
            let response = response as! ChatMessageReceivedEvent
            self.messages.append(ChatMessage(id: "", type: ChatMessageType.text, sequenceId: "", version: "", content:ChatMessageContent(message:response.content, topic: nil, participants: nil, initiator: nil), senderDisplayName:"bob" , createdOn: Iso8601Date(), senderId: "", deletedOn: nil, editedOn: nil))
            DispatchQueue.main.async(execute: {
                self.messagesTableView.reloadData()
            })
            }
        )
    }
    func getClient(credential: CommunicationTokenCredential? = nil) -> ChatClient {
        let scope = Constants.endpoint
        do {
            let options = AzureCommunicationChatClientOptions(logger: ClientLoggers.none)
            return try ChatClient(endpoint: scope, credential: credential!, withOptions: options)
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
       
        let displayName: String? = messages[indexPath.row].senderDisplayName
        let message: String? = messages[indexPath.row].content?.message
        
        cell.textLabel?.text = [displayName,message]
            .compactMap { $0 }
            .joined(separator: ": ")
        
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
        onStart(skypeToken: Constants.skypeToken)
    }
    
    func emptyMessageWarning ()
    {
        let alert = UIAlertController(title: "Error", message: "Can't send empty messages", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }


}

