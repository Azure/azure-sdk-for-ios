//
//  ViewController.swift
//  SignalingTestApp
//
//  Created by Gloria Li on 2021-01-11.
//

// COMMENT EVERYTHING OUT UNTIL TROUTER INTEGRATION IS UNBLOCKED

import UIKit
import AzureCommunicationChat
import AzureCommunication
import AzureCore
import AzureCommunicationSignaling

struct Constants {
    static let endpoint =  "https://chat-sdktester-e2e.int.communication.azure.net/"
    static let id1 = "8:acs:46849534-eb08-4ab7-bde7-c36928cd1547_00000006-f3dd-7f8c-1655-373a0d000426"
    static let skypeToken = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwMl9pbnQiLCJ4NXQiOiJnMTROVjRoSzJKUklPYk15YUUyOUxFU1FKRk0iLCJ0eXAiOiJKV1QifQ.eyJza3lwZWlkIjoiYWNzOjQ2ODQ5NTM0LWViMDgtNGFiNy1iZGU3LWMzNjkyOGNkMTU0N18wMDAwMDAwNi1mM2RkLTdmOGMtMTY1NS0zNzNhMGQwMDA0MjYiLCJzY3AiOjE3OTIsImNzaSI6IjE2MTI4NDQ1NzYiLCJpYXQiOjE2MTI4NDQ1NzYsImV4cCI6MTYxMjkzMDk3NiwiYWNzU2NvcGUiOiJjaGF0IiwicmVzb3VyY2VJZCI6IjQ2ODQ5NTM0LWViMDgtNGFiNy1iZGU3LWMzNjkyOGNkMTU0NyJ9.Ku6P0sbIyfuUnDS9wc9JN_Jgm5_NqBF1RhrOaI0Ms3hOH__iW9HCHFQT78wY6sxhLj9g8u3-Flxcxet81HqnP1z5NN9NUSsgsLq_BaZGZapGplEfp6WlgqLqZXQ04-ZaeaS-0FC1o1ZBZsJljY9rveQ6x5Pd1SAsHzfPgG-PNv_1POeihIYwfSoAOLZG4PdJk1D6di2aFfvYNQwxVUDrtsq2x9EGTG6owpE4kpfibGKNVaoK56LQb9Fdhl54VnVewYbJE-cPqa6O5mIkJvGkA29uLSA4qVoJLl9yrDxAqv1f63jKs4ltLkyxw7ID6NJwuY_Cn12xBzgUfHM7OyzqEQ"
    static let id2 = "8:acs:46849534-eb08-4ab7-bde7-c36928cd1547_00000007-fc40-73d6-b0b7-3a3a0d002613"
    static let skypeToken2 = "eyJhbGciOiJSUzI1NiIsImtpZCI6IjEwMl9pbnQiLCJ4NXQiOiJnMTROVjRoSzJKUklPYk15YUUyOUxFU1FKRk0iLCJ0eXAiOiJKV1QifQ.eyJza3lwZWlkIjoiYWNzOjQ2ODQ5NTM0LWViMDgtNGFiNy1iZGU3LWMzNjkyOGNkMTU0N18wMDAwMDAwNy1mYzQwLTczZDYtYjBiNy0zYTNhMGQwMDI2MTMiLCJzY3AiOjE3OTIsImNzaSI6IjE2MTI4NDQ1OTUiLCJpYXQiOjE2MTI4NDQ1OTUsImV4cCI6MTYxMjkzMDk5NSwiYWNzU2NvcGUiOiJjaGF0IiwicmVzb3VyY2VJZCI6IjQ2ODQ5NTM0LWViMDgtNGFiNy1iZGU3LWMzNjkyOGNkMTU0NyJ9.UkqPKmMOfsnvtUlhBblaTRoCVQgyLGCr5YDlYnr0r2NUeOhOss80jbNhg4b_vAeAjGgl0b1Q5V4LPYrfTtfqNxiIfbJ694DIY7R346EDejsIu94yhqRp0LCqsnr6EvTti74a2fpxztMadVPqa4p12m86Yf2iw6Fyi7UrPjNDdd_Z3vJF_SnrvJaV7xLAMa4zA7rcJKl_R2L8HF69Ff5lxPbcAFf-7PVgq46NUtRBPx3dai2woH2LqtK2wQAYvDvBEyeE1LrndTTkcQWSiw0OU4Utz8EEK6oPTcc6EBOovyfSl2EvR62-EJzfsFA9GlZnvbNiduA5yG0MLLDDSHlVBQ"
    
}

func generateId () -> String
{
    var place = 1
    var finalNumber = 0;
    for _ in 1...12 {
        finalNumber += Int(arc4random_uniform(10)) * place
        place *= 10
   }
    return "8:acs:46849534-eb08-4ab7-bde7-c36928cd1547_00000006-f3dd-7f8c-1655-"+String(finalNumber)
}

extension ViewController: MyTableViewCellDelegate {
    func showErrorWindow(with message: String)
    {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func didTapButton(with title: String) {
        switch title {
        case "Subscribe to Thread Creation":
            chatClient?.on(event: "chatThreadCreated", listener:{
                (response, eventId)
                in
                self.handleChatEvents(response: response, eventId: eventId)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Subscribed to Thread Creation"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Subscribe to Message":
            chatClient?.on(event: "chatMessageReceived", listener:{
                (response, eventId)
                in
                self.handleChatEvents(response: response, eventId: eventId)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Subscribed to Message"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Subscribe to Typing Indicator":
            chatClient?.on(event: "typingIndicatorReceived", listener:{
                (response, eventId)
                in
                self.handleChatEvents(response: response, eventId: eventId)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Subscribed to Typing Indicator"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Subscribe to Read Receipt":
            chatClient?.on(event: "readReceiptReceived", listener:{
                (response, eventId)
                in
                self.handleChatEvents(response: response, eventId: eventId)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Subscribed to Read Receipt"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Subscribe to Message Update":
            chatClient?.on(event: "chatMessageEdited", listener:{
                (response, eventId)
                in
                self.handleChatEvents(response: response, eventId: eventId)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Subscribed to Message Update"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Subscribe to Message Deletion":
            chatClient?.on(event: "chatMessageDeleted", listener:{
                (response, eventId)
                in
                self.handleChatEvents(response: response, eventId: eventId)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Subscribed to Message Deletion"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Subscribe to Thread Topic Update":
            chatClient?.on(event: "chatThreadPropertiesUpdated", listener:{
                (response, eventId)
                in
                self.handleChatEvents(response: response, eventId: eventId)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Subscribed to Thread Topic Update"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Subscribe to Participant Addition":
            chatClient?.on(event: "participantsAdded", listener:{
                (response, eventId)
                in
                self.handleChatEvents(response: response, eventId: eventId)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Subscribed to Participant Addition"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Subscribe to Participant Removal":
            chatClient?.on(event: "participantsRemoved", listener:{
                (response, eventId)
                in
                self.handleChatEvents(response: response, eventId: eventId)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Participant Removal"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Subscribe to Thread Deletion":
            chatClient?.on(event: "chatThreadDeleted", listener:{
                (response, eventId)
                in
                self.handleChatEvents(response: response, eventId: eventId)
            })
            DispatchQueue.main.async {
                self.logArea.text += "\n------> Subscribed to Thread Deletion"
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        case "Create Thread":
            let participant = Participant(from: ChatParticipant(
                id: Constants.id1,
                displayName: "Bob",
                                            shareHistoryTime: Iso8601Date(string: "2020-10-30T10:50:50Z"))
            )
            let participant2 = Participant(from: ChatParticipant(
                id: Constants.id2,
                displayName: "Alice",
                                            shareHistoryTime: Iso8601Date(string: "2020-10-30T10:50:50Z"))
            )
            let request = CreateThreadRequest(
                topic: "Lunch Thread",
                participants: [
                    participant,participant2
                ]
            )
            chatClient?.create(thread: request) { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    DispatchQueue.main.async {
                        self.logArea.text += "\n------> Created a Thread"
                        let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                        self.logArea.scrollRangeToVisible(range)
                    }
                    guard let thread = response.thread else {
                        print("Failed to extract chatThread from response")
                        return
                    }
                    do {
                        self.chatThreadClient = try self.chatClient?.createClient(forThread: thread.id)
                        self.chatThreadClient2 = try self.chatClient2?.createClient(forThread: thread.id)
                    } catch _ {
                        print("Failed to initialize ChatThreadClient")
                    }
                case let .failure(error):
                    print("Unexpected failure happened in Create Thread")
                    print("\(error)")
                }
            }
        case "Send Message":
            if chatThreadClient == nil{
                showErrorWindow(with: "You need to creat a thread before you can send a message")
                return
            }
            let messageRequest = SendChatMessageRequest(
                content: "This is a message from Bob!",
                senderDisplayName: "Bob"
            )
            chatThreadClient?.send(message: messageRequest, completionHandler: { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    self.chatMessageId = response.id
                    DispatchQueue.main.async {
                        self.logArea.text += "\n------> Sent a Message"
                        let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                        self.logArea.scrollRangeToVisible(range)
                    }
                case .failure:
                    print("Unexpected failure happened in send message")
                }
            })
            
        case "Send Typing Indicator":
            if chatThreadClient == nil{
                showErrorWindow(with: "You need to creat a thread before you can send a typing indicator")
                return
            }
            chatThreadClient?.sendTypingNotification(completionHandler: { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    DispatchQueue.main.async {
                        self.logArea.text += "\n------> Sent a Typing Indicator"
                        let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                        self.logArea.scrollRangeToVisible(range)
                    }
                    
                case .failure:
                    print("Unexpected failure happened in send typing notification")
                }
            })
        case "Send Read Receipt":
            if chatThreadClient == nil{
                showErrorWindow(with: "You need to creat a thread before you can send a read receipt")
                return
            }
            else if chatMessageId == nil{
                showErrorWindow(with: "You need to send a message before you can send a read receipt")
                return
            }
            
            chatThreadClient2?.sendReadReceipt(forMessage: chatMessageId!, completionHandler: { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    DispatchQueue.main.async {
                        self.logArea.text += "\n------> Sent a Read Receipt"
                        let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                        self.logArea.scrollRangeToVisible(range)
                    }
                    
                case .failure:
                    print("Unexpected failure happened in send read receipt")
                }
            })
        case "Edit Message":
            if chatThreadClient == nil{
                showErrorWindow(with: "You need to creat a thread before you can edit a message")
                return
            }
            else if chatMessageId == nil{
                showErrorWindow(with: "You need to send a message before you can edit the message")
                return
            }
            
            let updateChatMessageRequest = UpdateChatMessageRequest(content: "Updated Message")
            chatThreadClient?.update(message: updateChatMessageRequest, messageId: chatMessageId!, completionHandler: { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    DispatchQueue.main.async {
                        self.logArea.text += "\n------> Edited a Message"
                        let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                        self.logArea.scrollRangeToVisible(range)
                    }
                    
                case .failure:
                    print("Unexpected failure happened in update chat message")
                }
            })
        case "Delete Message":
            if chatThreadClient == nil{
                showErrorWindow(with: "You need to creat a thread before you can delete a message")
                return
            }
            else if chatMessageId == nil{
                showErrorWindow(with: "You need to send a message before you can delete the message")
                return
            }
            
            chatThreadClient?.delete(message: chatMessageId!, completionHandler: { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    self.chatMessageId = nil
                    DispatchQueue.main.async {
                        self.logArea.text += "\n------> Deleted a Message"
                        let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                        self.logArea.scrollRangeToVisible(range)
                    }
                    
                case .failure:
                    print("Unexpected failure happened in delete message")
                }
            })
        case "Edit Thread Topic":
            if chatThreadClient == nil{
                showErrorWindow(with: "You need to creat a thread before you can change its topic name")
                return
            }
            chatThreadClient?.update(topic: "updated topic", completionHandler: { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    DispatchQueue.main.async {
                        self.logArea.text += "\n------> Updated Thread Topic"
                        let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                        self.logArea.scrollRangeToVisible(range)
                    }
                    
                case .failure:
                    print("Unexpected failure happened in update chat thread properties")
                }
                
            })
        case "Add Participant":
            if chatThreadClient == nil{
                showErrorWindow(with: "You need to creat a thread before you can add a participant")
                return
            }
            let participant = Participant(from: ChatParticipant(
                id: generateId(),
                displayName: "William",
                shareHistoryTime: Iso8601Date(string: "2020-10-30T10:50:50Z"))
            )
            chatThreadClient?.add(participants: [participant], completionHandler: { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    DispatchQueue.main.async {
                        self.logArea.text += "\n------> Added a Participant"
                        let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                        self.logArea.scrollRangeToVisible(range)
                    }
                    
                case .failure:
                    print("Unexpected failure happened in Add participant")
                }
            })
        case "Remove Participant":
            if chatThreadClient == nil{
                showErrorWindow(with: "You need to creat a thread before you can remove a participant")
                return
            }
            chatThreadClient?.listParticipants(completionHandler: { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    var existLoop = false
                    while (existLoop == false)
                    {
                        response.nextItem { result in
                            switch result {
                            case let .success(participant):
                                if participant.user.identifier == Constants.id1 || participant.user.identifier == Constants.id2
                                {
                                    return
                                }
                                existLoop = true
                                self.chatThreadClient?.remove(participant: participant.user.identifier, completionHandler: { result, _ in
                                    switch result {
                                    case let .success(response):
                                        print(response)
                                        DispatchQueue.main.async {
                                            self.logArea.text += "\n------> Removed a Participant"
                                            let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                                            self.logArea.scrollRangeToVisible(range)
                                        }
                                    case .failure:
                                        print("Unexpected failure happened in remove participant")
                                    }
                                })
                            case .failure:
                                print("Unexpected failure happened in list participants")
                                existLoop = true
                                self.showErrorWindow(with: "You need to add a participant before you can remove the participant")
                            }
                        }
                    }
                case .failure:
                    print("Unexpected failure happened in list participants")
                }
            })
        case "Delete Thread":
            if chatThreadClient == nil{
                showErrorWindow(with: "You need to creat a thread before you can delete the thread")
                return
            }
            chatClient?.delete(thread: chatThreadClient!.threadId, completionHandler:  { result, _ in
                switch result {
                case let .success(response):
                    print(response)
                    DispatchQueue.main.async {
                        self.logArea.text += "\n------> Deleted a Thread"
                        let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                        self.logArea.scrollRangeToVisible(range)
                    }
                case .failure:
                    print("Unexpected failure happened in Delete Thread")
                }
            })
            
        default:
            print("Nothing")
        }
    }
}

class ViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet var chatEventTable: UITableView!
    @IBOutlet var subscribeToChatEventTable: UITableView!
    @IBOutlet var logArea: UITextView!
    
    let chatEvents = [
        "Create Thread",
        "Send Message",
        "Send Typing Indicator",
        "Send Read Receipt",
        "Edit Message",
        "Delete Message",
        "Edit Thread Topic",
        "Add Participant",
        "Remove Participant",
        "Delete Thread"
    ]
    
    let subscribeToChatEvents = [
        "Subscribe to Thread Creation",
        "Subscribe to Message",
        "Subscribe to Typing Indicator",
        "Subscribe to Read Receipt",
        "Subscribe to Message Update",
        "Subscribe to Message Deletion",
        "Subscribe to Thread Topic Update",
        "Subscribe to Participant Addition",
        "Subscribe to Participant Removal",
        "Subscribe to Thread Deletion"
    ]
    
    var chatClient: ChatClient? = nil
    var chatClient2: ChatClient? = nil
    var chatThreadClient: ChatThreadClient? = nil
    var chatThreadClient2: ChatThreadClient? = nil
    var chatMessageId: String? = nil
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == chatEventTable{
            let cell = tableView.dequeueReusableCell(withIdentifier: MyTableViewCell.identifier, for: indexPath) as! MyTableViewCell
            cell.configure(with: chatEvents[indexPath.row])
            cell.delegate = self
            return cell
        } else if tableView == subscribeToChatEventTable{
            let cell = tableView.dequeueReusableCell(withIdentifier: MyTableViewCell.identifier, for: indexPath) as! MyTableViewCell
            cell.configure(with: subscribeToChatEvents[indexPath.row])
            cell.delegate = self
            return cell
        }
        return UITableViewCell()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logArea.isScrollEnabled = true
        chatEventTable.register(MyTableViewCell.nib(), forCellReuseIdentifier: MyTableViewCell.identifier)
        chatEventTable.dataSource = self
        subscribeToChatEventTable.register(MyTableViewCell.nib(), forCellReuseIdentifier: MyTableViewCell.identifier)
        subscribeToChatEventTable.dataSource = self
        onStart(skypeToken: Constants.skypeToken)
    }
    
    func onStop()
    {
        chatClient?.stopRealTimeNotifications()
    }
    
    func onStart (skypeToken: String)
    {
        let communicationUserCredential: CommunicationTokenCredential
        do {
            communicationUserCredential = try CommunicationTokenCredential(token:skypeToken)
        } catch {
            fatalError(error.localizedDescription)
        }
        
        let communicationUserCredential2: CommunicationTokenCredential
        do {
            communicationUserCredential2 = try CommunicationTokenCredential(token:Constants.skypeToken2)
        } catch {
            fatalError(error.localizedDescription)
        }
        chatClient = getClient(credential:communicationUserCredential)
        chatClient2 = getClient(credential:communicationUserCredential2)
        chatClient?.startRealTimeNotifications()
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
    
    func handleChatEvents (response:Any, eventId: ChatEventId)
    {
        if (eventId == ChatEventId.chatMessageReceived)
        {
            let response = response as! ChatMessageReceivedEvent
            print("\n------> ChatMessageReceivedEvent Received: ", response)
            print("\n------> threadId is: ", response.threadId)
            print("\n------> id is: ", response.id)
            print("\n------> content is: ", response.content)
            
            DispatchQueue.main.async {
                self.logArea.text += "\n------> ChatMessageReceivedEvent Received: "
                self.logArea.text += "\n threadId is: " + String(response.threadId)
                self.logArea.text += "\n id is: " + String(response.id)
                self.logArea.text += "\n content is: " + String(response.content)
                self.logArea.text += "\n"
                
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        }
        else if(eventId == ChatEventId.typingIndicatorReceived)
        {
            let response = response as! TypingIndicatorReceivedEvent
            print("\n------> TypingIndicatorReceivedEvent Received: ", response)
            print("\n------> threadId is: ", response.threadId)
            print("\n------> receivedOn is: ", response.receivedOn)
            print("\n------> version is: ", response.version)
            
            DispatchQueue.main.async {
                self.logArea.text += "\n------> TypingIndicatorReceivedEvent Received: "
                self.logArea.text += "\n threadId is: " + String(response.threadId)
                self.logArea.text += "\n receivedOn is: " + String(response.receivedOn)
                self.logArea.text += "\n version is: " + String(response.version)
                self.logArea.text += "\n"
                
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        }
        else if(eventId == ChatEventId.readReceiptReceived)
        {
            let response = response as! ReadReceiptReceivedEvent
            print("\n------> ReadReceiptReceivedEvent Received: ", response)
            print("\n------> threadId is: ", response.threadId)
            print("\n------> readOn is: ", response.readOn)
            print("\n------> chatMessageId is: ", response.chatMessageId)
            
            DispatchQueue.main.async {
                self.logArea.text += "\n------> ReadReceiptReceivedEvent Received: "
                self.logArea.text += "\n threadId is: " + String(response.threadId)
                self.logArea.text += "\n readOn is: " + String(response.readOn)
                self.logArea.text += "\n chatMessageId is: " + String(response.chatMessageId)
                self.logArea.text += "\n"
                
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        }
        else if(eventId == ChatEventId.chatMessageEdited)
        {
            let response = response as! ChatMessageEditedEvent
            print("\n------> ChatMessageEditedEvent Received: ", response)
            print("\n------> threadId is: ", response.threadId)
            print("\n------> editedOn is: ", response.editedOn)
            print("\n------> content is: ", response.content)
            
            DispatchQueue.main.async {
                self.logArea.text += "\n------> ChatMessageEditedEvent Received: "
                self.logArea.text += "\n threadId is: " + String(response.threadId)
                self.logArea.text += "\n editedOn is: " + String(response.editedOn)
                self.logArea.text += "\n content is: " + String(response.content)
                self.logArea.text += "\n"
                
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        }
        else if(eventId == ChatEventId.chatMessageDeleted)
        {
            let response = response as! ChatMessageDeletedEvent
            print("\n------> ChatMessageDeletedEvent Received: ", response)
            print("\n------> threadId is: ", response.threadId)
            print("\n------> deletedOn is: ", response.deletedOn)
            
            DispatchQueue.main.async {
                self.logArea.text += "\n------> ChatMessageDeletedEvent Received: "
                self.logArea.text += "\n threadId is: " + String(response.threadId)
                self.logArea.text += "\n deletedOn is: " + String(response.deletedOn)
                self.logArea.text += "\n"
                
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        }
        else if(eventId == ChatEventId.chatThreadCreated)
        {
            let response = response as! ChatThreadCreatedEvent
            print("\n------> ChatThreadCreatedEvent Received: ", response)
            print("\n------> threadId is: ", response.threadId)
            print("\n------> createdOn is: ", response.createdOn)
            
            DispatchQueue.main.async {
                self.logArea.text += "\n------> ChatThreadCreatedEvent Received: "
                self.logArea.text += "\n threadId is: " + String(response.threadId)
                self.logArea.text += "\n createdOn is: " + String(response.createdOn)
                self.logArea.text += "\n"
                
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        }
        else if(eventId == ChatEventId.chatThreadPropertiesUpdated)
        {
            let response = response as! ChatThreadPropertiesUpdatedEvent
            print("\n------> ChatThreadPropertiesUpdatedEvent Received: ", response)
            print("\n------> threadId is: ", response.threadId)
            print("\n------> updatedOn is: ", response.updatedOn)
            
            DispatchQueue.main.async {
                self.logArea.text += "\n------> ChatThreadPropertiesUpdatedEvent Received: "
                self.logArea.text += "\n threadId is: " + String(response.threadId)
                self.logArea.text += "\n updatedOn is: " + String(response.updatedOn)
                self.logArea.text += "\n"
                
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        }
        else if(eventId == ChatEventId.chatThreadDeleted)
        {
            let response = response as! ChatThreadDeletedEvent
            print("\n------> ChatThreadDeletedEvent Received: ", response)
            print("\n------> threadId is: ", response.threadId)
            print("\n------> deletedOn is: ", response.deletedOn)
            
            DispatchQueue.main.async {
                self.logArea.text += "\n------> ChatThreadDeletedEvent Received: "
                self.logArea.text += "\n threadId is: " + String(response.threadId)
                self.logArea.text += "\n deletedOn is: " + String(response.deletedOn)
                self.logArea.text += "\n"
                
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        }
        else if(eventId == ChatEventId.participantsAdded)
        {
            let response = response as! ParticipantsAddedEvent
            print("\n------> ParticipantsAddedEvent Received: ", response)
            print("\n------> threadId is: ", response.threadId)
            print("\n------> addedOn is: ", response.addedOn)
            
            DispatchQueue.main.async {
                self.logArea.text += "\n------> ParticipantsAddedEvent Received: "
                self.logArea.text += "\n threadId is: " + String(response.threadId)
                self.logArea.text += "\n addedOn is: " + String(response.addedOn)
                self.logArea.text += "\n shareHistoryTime is: " + String(((response.participantsAdded?[0].shareHistoryTime!)!))
                self.logArea.text += "\n"
                
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        }
        else if(eventId == ChatEventId.participantsRemoved)
        {
            let response = response as! ParticipantsRemovedEvent
            print("\n------> ParticipantsRemovedEvent Received: ", response)
            print("\n------> threadId is: ", response.threadId)
            print("\n------> removedOn is: ", response.removedOn)
            
            DispatchQueue.main.async {
                self.logArea.text += "\n------> ParticipantsRemovedEvent Received: "
                self.logArea.text += "\n threadId is: " + String(response.threadId)
                self.logArea.text += "\n removedOn is: " + String(response.removedOn)
                self.logArea.text += "\n shareHistoryTime is: " + String(((response.participantsRemoved?[0].shareHistoryTime!)!))
                self.logArea.text += "\n"
                
                let range = NSRange(location: self.logArea.text.count - 1, length: 0)
                self.logArea.scrollRangeToVisible(range)
            }
        }
    }
    
}
