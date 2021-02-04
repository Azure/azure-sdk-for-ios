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

var users: [String: String] = [
        "Gloria": "8:acs:46849534-eb08-4ab7-bde7-c36928cd1547_00000006-f3dd-7f8c-1655-373a0d000426"
    ]

var messages: [ChatMessage] = []
var participants: [AzureCommunicationChat.ChatParticipant] = []
var chatThreads: [ChatThread] = []

var chatClient: ChatClient? = nil
var currentThread: ChatThread? = nil
var chatThreadClient: ChatThreadClient? = nil
var currentUser: String? = nil
var loggedIn = false
//
//let vc = ChatViewController()

struct Constants {
    static let endpoint =  "https://chat-sdktester-e2e.int.communication.azure.net/"
    static let id =  "8:acs:46849534-eb08-4ab7-bde7-c36928cd1547_00000006-f3dd-7f8c-1655-373a0d000426"
    static let skypeToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwMl9pbnQiLCJ4NXQiOiJnMTROVjRoSzJKUklPYk15YUUyOUxFU1FKRk0iLCJ0eXAiOiJKV1QifQ.eyJza3lwZWlkIjoiYWNzOjQ2ODQ5NTM0LWViMDgtNGFiNy1iZGU3LWMzNjkyOGNkMTU0N18wMDAwMDAwNi1mM2RkLTdmOGMtMTY1NS0zNzNhMGQwMDA0MjYiLCJzY3AiOjE3OTIsImNzaSI6IjE2MTIzOTgxNzUiLCJpYXQiOjE2MTIzOTgxNzUsImV4cCI6MTYxMjQ4NDU3NSwiYWNzU2NvcGUiOiJjaGF0IiwicmVzb3VyY2VJZCI6IjQ2ODQ5NTM0LWViMDgtNGFiNy1iZGU3LWMzNjkyOGNkMTU0NyJ9.eg4S_J4XNpZtxM_OMLTAsUAw7qFAiKOAN82C0yzdywxJeB3gLYZX4C1CKhy_FAdOlyJHjl4OZNi9xnSXoeNmcfZUD-PgcwcyKJWg21D-CE6IUm1qmKYM90YNwnpbVhlV-gHCDpwHJ-Cjz6HaKsvDlvBOJkyQdjQImnF3qBDKGm821FTsESFWgDES-KsXoGt9Lsgu3Kjg-O_PuVWsFYTj5g4KV4ucCgngqdqdpeMXbPyR0jf1op91eMqoj-OFHkIr5Ga6bU_QECONMqhOTt1r5eZBoRXU_dGNZOLNrfxu7JVrwFKuMDR9WtKIMS471LVSgRZRddnet8d9vgKUQgx7sA"
}

class ThreadsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var threadsTableView: UITableView!
    
    func onStart (skypeToken: String)
    {
        currentUser = "Gloria"
        let communicationUserCredential: CommunicationTokenCredential
        do {
            communicationUserCredential = try CommunicationTokenCredential(token:skypeToken)
        } catch {
            fatalError(error.localizedDescription)
        }
        chatClient = getClient(credential:communicationUserCredential)
        
        chatClient?.listThreads { result, _ in
            switch result {
            case let .success(threads):
                for thread in threads.items ?? []
                {
                    if thread.deletedOn == nil
                    {chatThreads.append(ChatThread(id: thread.id, topic: thread.topic, createdOn: Iso8601Date(), createdBy: "", deletedOn: thread.deletedOn))}
                }
                DispatchQueue.main.async(execute: {
                    self.threadsTableView.reloadData()
                })
            case .failure:
                print("Unexpected failure happened in list chat threads")
            }
        }
    
        chatClient?.startRealTimeNotifications()
        
            let participant = ChatParticipant(
                id: Constants.id,
                displayName: currentUser,

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
                        chatThreadClient = try chatClient?.createClient(forThread: thread.id)
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
            messages.append(ChatMessage(id: "", type: ChatMessageType.text, sequenceId: "", version: "", content:ChatMessageContent(message:response.content, topic: nil, participants: nil, initiator: nil), senderDisplayName: response.senderDisplayName , createdOn: Iso8601Date(), senderId: "", deletedOn: nil, editedOn: nil))

            NotificationCenter.default.post(Notification(name: Notification.Name(rawValue: "newMessage")))
            }
        )
        chatClient?.on(event: "chatThreadCreated", listener:{
            (response, eventId)
            in
            let response = response as! ChatThreadCreatedEvent
        })
        
        chatClient?.on(event: "participantsAdded", listener:{
            (response, eventId)
            in
            let response = response as! ParticipantsAddedEvent
        })
        
        chatClient?.on(event: "participantsRemoved", listener:{
            (response, eventId)
            in
            let response = response as! ParticipantsRemovedEvent
        })
        
        chatClient?.on(event: "typingIndicatorReceived", listener:{
            (response, eventId)
            in
            let response = response as! TypingIndicatorReceivedEvent
        })
        chatClient?.on(event: "readReceiptReceived", listener:{
            (response, eventId)
            in
            let response = response as! ReadReceiptReceivedEvent
        })
        chatClient?.on(event: "chatMessageEdited", listener:{
            (response, eventId)
            in
            let response = response as! ChatMessageEditedEvent
        })
        chatClient?.on(event: "chatMessageDeleted", listener:{
            (response, eventId)
            in
            let response = response as! ChatMessageDeletedEvent
        })
        chatClient?.on(event: "chatThreadPropertiesUpdated", listener:{
            (response, eventId)
            in
            let response = response as! ChatThreadPropertiesUpdatedEvent
        })
        chatClient?.on(event: "chatThreadDeleted", listener:{
            (response, eventId)
            in
            let response = response as! ChatThreadDeletedEvent
        })
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
        return chatThreads.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = chatThreads[indexPath.row].topic
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        threadsTableView.deselectRow(at: indexPath, animated: true)
        currentThread = chatThreads[indexPath.row]
        performSegue(withIdentifier: "SegueToChatViewController", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        threadsTableView.delegate = self
        threadsTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        threadsTableView.dataSource = self
        onStart(skypeToken: Constants.skypeToken)
    }
}

